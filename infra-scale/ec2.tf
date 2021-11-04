# AWS용 프로바이더 구성
provider "aws" {
  profile = "default"
  region = "ap-northeast-2"
}

locals {
  svc_nm = "dyheo"
  #pem_file = "dyheo-histech-2"
  pem_file = "dyheo-histech"

  ## EC2 를 만들기 위한 로컬변수 선언
  ami = "ami-0e4a9ad2eb120e054" ## AMAZON LINUX 2
  instance_type = "t2.micro"
}

## TAG NAME 으로 vpc id 를 가져온다.
data "aws_vpc" "this" {
  filter {
    name = "tag:Name"
    values = ["${local.svc_nm}-vpc"]
  }
}

## TAG NAME 으로 security group 을 가져온다.
data "aws_security_group" "security-group" {
  filter {
    name = "tag:Name"
    values = ["${local.svc_nm}-sg"]
  }
}

## TAG NAME 으로 subnet 을 가져온다.
data "aws_subnet" "public" {
  filter {
    name = "tag:Name"
    values = ["${local.svc_nm}-sb-public"]
  }
}

# AWS EC2
resource "aws_instance" "dyheo-tf-ec2-01" {
  ami = "${local.ami}"
  #associate_public_ip_address = true
  instance_type = "${local.instance_type}"
  key_name = "${local.pem_file}"
  vpc_security_group_ids = ["${data.aws_security_group.security-group.id}"]
  subnet_id = "${data.aws_subnet.public.id}"
  tags = {
    Name = "dyheo-tf-ec2"
  }

# HelloWorld App Code
  provisioner "remote-exec" {
    connection {
      host = self.public_ip
      user = "ec2-user"
      private_key = "${file("~/.ssh/${local.pem_file}.pem")}"
    }
    inline = [
      "echo 'repository set'",
      "sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y",
      "sudo yum update -y"
    ]
  }
  ## ANSIBLE inventory 생성.
  provisioner "local-exec" {
    command = "echo '[ec2] \n${self.public_ip} \n\n[jenkins_port] \n8080' > ./inventory"
  }
  ## ANSIBLE playbook 을 삽입하는 경우 여기를 수정한다.
  provisioner "local-exec" {
    command = "ansible-playbook --private-key='~/.ssh/dyheo-histech-2.pem' --user ec2-user -i inventory jenkins.yml"
  }
}

## EC2 를 만들면 public ip 를 print 해준다.
output "instance-public-ip" {
  value = "${aws_instance.dyheo-tf-ec2-01.public_ip}"
}

