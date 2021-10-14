#!/usr/bin/env bash

## service make & setting
HOME_DIR="/home/ec2-user/"
APP_NAME="helloworld.js"
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
