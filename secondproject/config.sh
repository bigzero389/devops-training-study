#!/usr/bin/env bash

## yum update
sudo yum install update

## add epel on Amazon Linux 2
sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

## application download
HOME_DIR="/home/ec2-user/"
APP_NAME="helloworld.js"
wget https://raw.githubusercontent.com/yogeshraheja/Effective-DevOps-with-AWS/master/Chapter02/helloworld.js -O ${HOME_DIR}${APP_NAME}

## nvm download & install
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

## nvm path setting
source ~/.bashrc

## node install 
NODE_VERSION="v14.18.0"
nvm install ${NODE_VERSION}
echo "$(node -v)"

## service make & setting
SERVICE_NAME="helloworld"
SERVICE_FILE="${SERVICE_NAME}.service"
NODE_HOME="$(which node)"
echo "NODE HOME is ${NODE_HOME}"

cat <<EOF > ${HOME_DIR}${SERVICE_FILE}
[Unit]
Description=Hello World

[Service]
ExecStart=${NODE_HOME} ${HOME_DIR}${APP_NAME}
Restart=always

[Install]
WantedBy=multi-user.target
EOF

## service link
sudo systemctl link ${HOME_DIR}${SERVICE_FILE}

## service setting & restart
sudo systemctl daemon-reload
sudo systemctl start ${SERVICE_NAME}
sudo systemctl enable ${SERVICE_NAME}
echo "$(sudo systemctl status helloworld)"
