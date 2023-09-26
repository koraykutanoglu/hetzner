#!/bin/bash

source ../Content/main.sh 

# cx21  =  2 CPU 4GB Ram
# cpx21 =  3 CPU 4GB Ram
# cx31  =  2 CPU 8GB Ram
# cpx31 =  4 CPU 8GB Ram

SERVER_NAME=k3s
SERVER_IMAGE=ubuntu-20.04
SERVER_TYPE=cx21
SERVER_LOCATION=hel1
SERVER_SSHKEY=mac

create_server "$SERVER_NAME" "$SERVER_IMAGE" "$SERVER_TYPE" "$SERVER_LOCATION" "$SERVER_SSHKEY"

echo "${separator// /-} Install K3S ${separator// /-}"
ssh root@$ip "sudo -E apt update;sudo -E apt upgrade -y;curl -sfL https://get.k3s.io | sudo sh -;kubectl get nodes"

delete_server "$SERVER_NAME"