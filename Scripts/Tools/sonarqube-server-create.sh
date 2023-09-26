#!/bin/bash

source ../Content/main.sh 

# cx21  =  2 CPU 4GB Ram
# cpx21 =  3 CPU 4GB Ram
# cx31  =  2 CPU 8GB Ram
# cpx31 =  4 CPU 8GB Ram

SERVER_NAME=SonarQube
SERVER_IMAGE=ubuntu-22.04
SERVER_TYPE=cx21
SERVER_LOCATION=hel1
SERVER_SSHKEY=mac

create_server "$SERVER_NAME" "$SERVER_IMAGE" "$SERVER_TYPE" "$SERVER_LOCATION" "$SERVER_SSHKEY"

echo "${separator// /-} Install Docker ${separator// /-}"
ssh root@$ip <<EOF
sudo apt-get update && apt-get upgrade -y; curl -fsSL https://get.docker.com -o get-docker.sh; sudo sh get-docker.sh
EOF

echo "${separator// /-} Install Docker Compose ${separator// /-}"
ssh root@$ip <<EOF
apt install docker-compose -y
EOF

echo "${separator// /-} Sysctl Config ${separator// /-}"
ssh root@$ip <<EOF
sysctl -w vm.max_map_count=262144
EOF

echo "${separator// /-} Creating Folders And Setting Permission ${separator// /-}"
ssh root@$ip <<EOF
mkdir -p /data/sonarqube/logs
mkdir -p /data/sonarqube/data
mkdir -p /data/sonarqube/extensions
mkdir -p /data/postgresql/postgresql
mkdir -p /data/postgresql/data
chmod 777 /data/sonarqube/logs
chmod 777 /data/sonarqube/data
chmod 777 /data/sonarqube/extensions
chmod 777 /data/postgresql/postgresql
chmod 777 /data/postgresql/data
EOF

echo "${separator// /-} Docker Compose File is Transferring ${separator// /-}"
scp scp ../Content/SonarQube/sonarqube-docker-compose.yml root@$ip:/root

ssh root@$ip <<EOF
cp sonarqube-docker-compose.yml docker-compose.yml
docker-compose up -d
EOF

delete_server "$SERVER_NAME"