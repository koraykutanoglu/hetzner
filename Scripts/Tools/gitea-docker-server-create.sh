#!/bin/bash

source ../Content/main.sh 

# cx21  =  2 CPU 4GB Ram
# cpx21 =  3 CPU 4GB Ram
# cx31  =  2 CPU 8GB Ram
# cpx31 =  4 CPU 8GB Ram

SERVER_NAME=Gitea
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

echo "${separator// /-} Transfering Gitea Docker Compose File ${separator// /-}"
scp ../Content/Gitea/Docker-Compose/docker-compose.yaml root@$ip:/root

echo "${separator// /-} Install Helm v3 ${separator// /-}"
ssh root@$ip "docker-compose up -d"

delete_server "$SERVER_NAME"


# https://docs.gitea.com/installation/install-with-docker