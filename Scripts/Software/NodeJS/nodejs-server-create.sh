#!/bin/bash

###################### NODEJS INSTALL WITH APT ######################

source ../main.sh 

# cx21  =  2 CPU 4GB Ram
# cpx21 =  3 CPU 4GB Ram
# cx31  =  2 CPU 8GB Ram
# cpx31 =  4 CPU 8GB Ram

SERVER_NAME=ubuntu-NodeJS-Server
SERVER_IMAGE=ubuntu-22.04
SERVER_TYPE=cx21
SERVER_LOCATION=hel1
SERVER_SSHKEY=mac

create_server "$SERVER_NAME" "$SERVER_IMAGE" "$SERVER_TYPE" "$SERVER_LOCATION" "$SERVER_SSHKEY"

echo "${separator// /-} Install NodeJS ${separator// /-}"
ssh root@$ip "apt install nodejs -y"

echo "${separator// /-} Install npm ${separator// /-}"
ssh root@$ip "apt install npm -y"

delete_server "$SERVER_NAME"