#!/bin/bash

source ../main.sh 

# cx21  =  2 CPU 4GB Ram
# cpx21 =  3 CPU 4GB Ram
# cx31  =  2 CPU 8GB Ram
# cpx31 =  4 CPU 8GB Ram

SERVER_NAME=rke2
SERVER_IMAGE=ubuntu-20.04
SERVER_TYPE=cx21
SERVER_LOCATION=hel1
SERVER_SSHKEY=mac

create_server "$SERVER_NAME" "$SERVER_IMAGE" "$SERVER_TYPE" "$SERVER_LOCATION" "$SERVER_SSHKEY"

echo "${separator// /-} Install RKE2 ${separator// /-}"
ssh root@$ip "curl -sfL https://get.rke2.io | sudo sh -;sudo systemctl start rke2-server.service;"

echo "${separator// /-} Install Kubectl And Configuration ${separator// /-}"
ssh root@$ip "curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl";sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl;chmod +x kubectl;mkdir -p ~/.local/bin/kubectl;mv ./kubectl ~/.local/bin/kubectl;source /usr/share/bash-completion/bash_completion;echo 'source <(kubectl completion bash)' >>~/.bashrc;kubectl completion bash >/etc/bash_completion.d/kubectl;echo 'alias k=kubectl' >>~/.bashrc;echo 'complete -F __start_kubectl k' >>~/.bashrc;mkdir -p .kube;cp /etc/rancher/rke2/rke2.yaml /root/.kube/config;chmod 400 .kube/config"

delete_server "$SERVER_NAME"