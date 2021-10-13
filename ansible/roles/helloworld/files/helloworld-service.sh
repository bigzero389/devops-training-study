#!/usr/bin/env bash

## application download
HOME_DIR="/home/ec2-user/"
APP_NAME="helloworld.js"
wget https://raw.githubusercontent.com/yogeshraheja/Effective-DevOps-with-AWS/master/Chapter02/helloworld.js -O ${HOME_DIR}${APP_NAME}

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
