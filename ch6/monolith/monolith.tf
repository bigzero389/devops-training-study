# AWS용 프로바이더 구성
provider "aws" {
  profile = "default"
  region = "ap-northeast-2"
}

## Set VPC INFO : vpc-0a420c9e9abb406d2
data "aws_vpc" "selected" {
  filter {
    name = "tag:Name"
    values = ["t-dyheo-vpc"]
  }
}

## Set SUBNET INFO : subnet-0b92fd86f003a4680
data "aws_subnet" "selected" {
  filter {
    name = "tag:Name"
    values = ["public-t-dyheo-vpc"]
  }
}

# AWS Security Group
resource "aws_security_group" "monolith" {
  name        = "allow_ssh"
  description = "Allow TLS inbound traffic"
  vpc_id      = "${data.aws_vpc.selected.id}"

  ingress = [
    {
      description      = "OPEN HTTP"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["125.177.68.23/32"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self = false
    },
    {
      description      = "TLS from VPC"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["125.177.68.23/32"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self = false
    },
    {
      description      = "Tomcat"
      from_port        = 3000
      to_port          = 3000
      protocol         = "tcp"
      cidr_blocks      = ["125.177.68.23/32"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self = false
    },
    {
      description      = "SSH from home"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      type             = "ssh"
      cidr_blocks      = ["125.177.68.23/32"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self = false
    }
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self = false
      description = "monolith"
    }
  ]

  tags = {
    Name = "dyheo-monolith"
  }
}

# AWS EC2
resource "aws_instance" "dyheo-monolith" {
  ami = "ami-0e4a9ad2eb120e054"
  associate_public_ip_address = true
  instance_type = "t2.micro"
  #availability_zone = "ap-northeast-2a"
  key_name = "dyheo-histech-2"
  vpc_security_group_ids = ["${aws_security_group.monolith.id}"]
  subnet_id = "${data.aws_subnet.selected.id}"
  tags = {
    Name = "dyheo-monolith"
  }

# HelloWorld App Code
  provisioner "remote-exec" {
    connection {
      host = self.public_ip
      user = "ec2-user"
      private_key = "${file("~/.ssh/dyheo-histech-2.pem")}"
    }
    inline = [
      "echo 'repository set'",
      "sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y",
      "sudo yum update -y"
    ]
  }
  provisioner "local-exec" {
    command = "echo '[inventory] \n${self.public_ip}' > ./inventory"
  }
  provisioner "local-exec" {
    command = "ansible-playbook --private-key='~/.ssh/dyheo-histech-2.pem' -i inventory monolith.yml"
  }
}

output "dyheo-monolith" {
  value = "${aws_instance.dyheo-monolith.public_ip}"
}

