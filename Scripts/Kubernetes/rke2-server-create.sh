#!/bin/bash

source ../main.sh 

# cx21  =  2 CPU 4GB Ram
# cpx21 =  3 CPU 4GB Ram
# cx31  =  2 CPU 8GB Ram
# cpx31 =  4 CPU 8GB Ram

# create_server "$server_name" "$server_image" "$server_type" "$server_location" "$server_sshkey"
create_server "k3s" "ubuntu-20.04" "cx21" "hel1" "mac"

echo "${separator// /-} Install RKE2 ${separator// /-}"
ssh root@$ip "curl -sfL https://get.rke2.io | sudo sh -;sudo systemctl start rke2-server.service;"

echo "${separator// /-} Install Kubectl And Configuration ${separator// /-}"
ssh root@$ip "curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl";sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl;chmod +x kubectl;mkdir -p ~/.local/bin/kubectl;mv ./kubectl ~/.local/bin/kubectl;source /usr/share/bash-completion/bash_completion;echo 'source <(kubectl completion bash)' >>~/.bashrc;kubectl completion bash >/etc/bash_completion.d/kubectl;echo 'alias k=kubectl' >>~/.bashrc;echo 'complete -F __start_kubectl k' >>~/.bashrc;mkdir -p .kube;cp /etc/rancher/rke2/rke2.yaml /root/.kube/config;chmod 400 .kube/config"

delete_server