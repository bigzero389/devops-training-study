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
terraform init // *.tf 파일에 의한 초기화
terraform valiate // 검증
terraform apply [--auto-approve]
cat terraform.tfstate // read state
terraform show // view json info
terraform state list // view resource list
terraform destroy [-target RESOURCE_TYPE.NAME] // destroy
terraform show | grep -i public_ip // get public ip


## init script user data
sudo yum install update
echo "NVM install"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install v14.18.0
echo "Check Node Version"
node -v
echo "HelloWorld App Download to Home"
wget https://raw.githubusercontent.com/yogeshraheja/Effective-DevOps-with-AWS/master/Chapter02/helloworld.js -O /home/ec2-user/helloworld.js

## Amazon Linux 2 epel enable
sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm



