#!/usr/bin/env bash

## NVM & NODEJS install
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
NODE_VERSION="v14.18.0"
nvm install ${NODE_VERSION}
echo "$(node -v)"

## yarn install
npm install -g yarn
echo "$(yarn --version)"

## service make & setting
HOME_DIR="/home/ec2-user/"

## httpd setting
sudo echo "<VirtualHost *>" > /etc/httpd/conf.d/tomcat-proxy.conf
sudo echo "        ProxyPass              /      http://localhost:3000/" >> /etc/httpd/conf.d/tomcat-proxy.conf
sudo echo "        ProxyPassReverse       /      http://localhost:3000/" >> /etc/httpd/conf.d/tomcat-proxy.conf
sudo echo "</VirtualHost>" >> /etc/httpd/conf.d/tomcat-proxy.conf
sudo systemctl status httpd
sudo systemctl restart httpd

## run postres db
sudo systemctl start docker
sudo docker run -d -p 15432:5432 --name postgres -e POSTGRES_PASSWORD=nest1234 -v pgdata:/var/lib/postgresql/data postgres

## app download
cd ${HOME_DIR}
git clone https://github.com/largezero/nestjs-core-sample.git
sudo chown -R ec2-user:ec2-user ${HOME_DIR}nestjs-core-sample/
cd ${HOME_DIR}nestjs-core-sample
yarn global add @nestjs/cli
yarn install
yarn build
#nohup yarn start 1> /dev/null 2>&1 &

# movie api service setting
NODE="$(which node)"
YARN="$(which yarn)"
sudo cat <<EOF > ${HOME_DIR}movieapi.service
[Unit]
Description=Movie API Service

[Service]
ExecStart=${NODE} ${YARN} start
Restart=always
WorkingDirectory=${HOME_DIR}nestjs-core-sample

[Install]
WantedBy=multi-user.target
EOF

## service link
sudo systemctl link ${HOME_DIR}movieapi.service
sudo systemctl restart movieapi
