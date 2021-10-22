## 사용자정보조회
aws iam list-users

## amazon linux 찾기  
aws ec2 describe-images \
--owners amazon \
--filters "Name=description,Values=Amazon*" "Name=platform-details, Values=Linux/UNIX" \
--query 'Images[*].[CreationDate, Description, ImageId]' --output text | sort -k 1 | tail

###=>
2021-10-05T18:18:38.000Z	Amazon Linux 2 AMI 2.0.20211001.1 x86_64 HVM gp2	ami-0e4a9ad2eb120e054

## vpc 조회
aws ec2 describe-vpcs 
####=> "VpcId": "vpc-0a420c9e9abb406d2",

## tag 검색, Name 뒤에 소문자 주의
aws ec2 describe-tags --filters Name=value,Values=t-dyheo-vpc

## SG 생성
aws ec2 create-security-group \
--group-name HelloWorld \
--description "Hello World" \
--vpc-id vpc-0a420c9e9abb406d
###=>"GroupId": "sg-08210a767e39439ac"

## SG 삭제
aws ec2 delete-security-group \
--group-id sg-07b33c0d3039814f6

## aws security group ingress setting, 그룹ID 로 지정하고 Name 빼서 성공함
aws ec2 authorize-security-group-ingress \
--group-id sg-08210a767e39439ac \
--protocol tcp \
--port 3000 \
--cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
--group-id sg-08210a767e39439ac \
--protocol tcp \
--port 22 \
--cidr 125.177.68.23/32

aws ec2 authorize-security-group-ingress \
--group-id sg-08210a767e39439ac \
--protocol tcp \
--port 3000 \
--cidr 125.177.68.23/32

## security group info
aws ec2 describe-security-groups \
--group-id sg-08210a767e39439ac

## key pair 조회
aws ec2 describe-key-pairs \
--key-name dyheo-histech-2

## key pair 생성 및 파일 다운
aws ec2 create-key-pair \
--key-name dyheo-histech-2 \
--query 'KeyMaterial' \
--output text > ./dyheo-histech-2.pem

## ec2 생성
aws ec2 run-instances \
--instance-type t2.micro \
--key-name dyheo-histech-2 \
--security-group-ids sg-08210a767e39439ac \
--image-id ami-0e4a9ad2eb120e054 \
--subnet-id subnet-0b92fd86f003a4680 \
--associate-public-ip-address

###=> instance id : i-075d8daa53e648f32

## get instance status
aws ec2 describe-instance-status --instance-ids i-075d8daa53e648f32

## get instance public dns 
aws ec2 describe-instances --instance-ids i-075d8daa53e648f32 \
--query "Reservations[*].Instances[*].PublicDnsName"

###=> ec2-3-34-142-155.ap-northeast-2.compute.amazonaws.com

## Amazon Linux 2 epel 활성화
sudo amazon-linux-extras install epel -y

## Content download from github
wget https://raw.githubusercontent.com/yogeshraheja/Effective-DevOps-with-AWS/master/Chapter02/helloworld.js -O /home/ec2-user/helloworld.js

## Start service # 
sudo vi /etc/systemd/system/helloworld.service
```
[Unit]
Description=Hello World

[Install]
WantedBy=multi-user.target

[Service]
# Type=forking # 자식 프로세스 생성 후 실행이 필요할 경우 지정
ExecStart=/home/ec2-user/.nvm/versions/node/v14.18.0/bin/node /home/ec2-user/helloworld.js"
```

sudo systemctl enable helloworld 
sudo systemctl daemon-reload
sudo systemctl helloworld start/stop

SERVICE_NAME="helloworld" \
&& sudo systemctl stop $SERVICE_NAME \
&& sudo systemctl disable $SERVICE_NAME \
&& sudo rm /etc/systemd/system/$SERVICE_NAME.service \
&& sudo systemctl daemon-reload \
&& sudo systemctl reset-failed

## journal log check
journalctl -u helloworld -f


# TerraForm
```
terraform init // *.tf 파일에 의한 초기화
terraform valiate // 검증
terraform apply [--auto-approve]
cat terraform.tfstate // read state
terraform show // view json info
terraform state list // view resource list
terraform destroy [-target RESOURCE_TYPE.NAME] // destroy
terraform show | grep -i public_ip // get public ip
```

## init script user data
```
sudo yum install update
echo "NVM install"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install v14.18.0
echo "Check Node Version"
node -v
echo "HelloWorld App Download to Home"
wget https://raw.githubusercontent.com/yogeshraheja/Effective-DevOps-with-AWS/master/Chapter02/helloworld.js -O /home/ec2-user/helloworld.js
```
## Amazon Linux 2 epel enable
https://thecodecloud.in/ansible-installation-configuration-amazon-linux-ec2-instance-aws/  
```
sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

$ wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
$ sudo yum install epel-release-latest-7.noarch.rpm -y
$ sudo yum update -y
$ sudo yum install python python-devel python-pip openssl ansible -y
$ sudo amazon-linux-extras install ansible2 -y
```

## Ansible note
ansible-galaxy init [project_name]  
ansible-galaxy collection install amazon.aws # ansible amazon install ##?  
ansible --private-key ~/.ssh/dyheo-histech-2.pem ansible-test -m ping  
sudo vi /etc/ansible/host ## [ansible-test] ip등록  
ansible --private-key ~/.ssh/dyheo-histech-2.pem '3.36.115.214' -a 'df -h'  
ansible-playbook helloworld.yml --private-key ~/.ssh/dyheo-histech-2.pem --user ec2-user -e target='3.36.115.214' --list-hosts  
ansible-playbook helloworld.yml --private-key ~/.ssh/dyheo-histech-2.pem --user ec2-user -e target='3.36.115.214' --check  
ansible-playbook helloworld.yml --private-key ~/.ssh/dyheo-histech-2.pem --user ec2-user -e target='3.36.115.214' # 실행.  
ansible-playbook helloworld.yml --private-key ~/.ssh/dyheo-histech-2.pem --user ec2-user -e target=ansible-test  

### ansible.cfg 기본설정 예제
sudo vi /etc/ansible/ansible.cfg  
```
[defaults]		//기본 셋팅
inventory = ./inventory	//현재 디렉토리에 inventory라는 파일을 읽어온다.
remote_user = hwan		//접속하려는 계정 이름
ask_pass = false		//접근할때 패스워드를 입력할 것인지

[privilege_escalation]		//root로 접근해야할 경우 설정
become = true				//sudo = true 라고 생각하시면 됩니다.
become_method = sudo
become_user = root
become_ask_pass = false

[all:vars]		//전역 변수식으로 모든 host들에게 적용할 때
ansible_user: admin
ansible_password: password
ansible_connection: httpapi  # REST API connection method, ssh 인 경우 안 넣어도 된다.

[webserver]		//하나의 호스트에만 적용시킬 때
ansible_host: 10.0.0.1
ansible_user: admin
ansible_password: password
ansible_connection: network_cli
```

### ./inventory 설정 예제
```
mail.example.com	//이렇게 하면 Ad-hoc이나 Playbook에서 해당 호스트 네임으로 명령어 실행가능

//호스트 네임과 IP주소로 설정 가능

[webservers]
192.168.0.5
192.168.0.6

[dbservers]
one.example.com
two.example.com
three.example.com

[nossh]
nossh.example.com:5050	//기본 ssh포트를 사용하지 않는다면 이런식으로도 설정 가능

[webservers2]
www[01:50].example.com	//저런식으로 for문 처리를 통해 01 ~ 50 번까지의 이름을 묶을 수 있다.

[databases2]
db-[a:f].example.com	//알파벳 또한 가능

//호스트 변수
[atlanta]
host1 http_port=80 maxRequestsPerChild=808
//해당 호스트 네임에 이런식으로 정의해줄 수 있다.

host2 http_port=303 maxRequestsPerChild=909
//이렇게 정의한 호스트들을 atlanta라는 묶음으로 사용한다는 뜻


//그룹 변수
[atlanta]
host1
host2

[atlanta:vars]	//그룹 자체를 기준으로 변수를 부여한다.
ntp_server=ntp.atlanta.example.com
proxy=proxy.atlanta.example.com


//그룹 그룹 묶기
[atlanta]
host1
host2

[raleigh]
host2
host3

[southeast:children] // :children 키워드를 이용해 그룹끼리 묶을 수 있다.
atlanta
raleigh
```


