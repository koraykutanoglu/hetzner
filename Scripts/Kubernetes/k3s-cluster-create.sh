#!/bin/bash

source ../Content/main.sh 

# cx21  =  2 CPU 4GB Ram
# cpx21 =  3 CPU 4GB Ram
# cx31  =  2 CPU 8GB Ram
# cpx31 =  4 CPU 8GB Ram

SERVER_NAME=k3s-main
SERVER_IMAGE=ubuntu-20.04
SERVER_TYPE=cx21
SERVER_LOCATION=hel1
SERVER_SSHKEY=mac

create_server "$SERVER_NAME" "$SERVER_IMAGE" "$SERVER_TYPE" "$SERVER_LOCATION" "$SERVER_SSHKEY"

echo "${separator// /-} Install K3S ${separator// /-}"
ssh root@$ip <<EOF
  curl -sfL https://get.k3s.io | sudo sh -
  kubectl get nodes
EOF

echo "${separator// /-} Get Agent Token ${separator// /-}" 
token=$(ssh root@$ip "cat /var/lib/rancher/k3s/server/node-token")


echo "${separator// /-} Creating Kubernetes Agent ${separator// /-}"  
worker1ip=$(hcloud server create --name k3s-worker01 --image $SERVER_IMAGE --type $SERVER_TYPE --without-ipv6 --location $SERVER_LOCATION --ssh-key $SERVER_SSHKEY | grep "IPv4:" | awk '{print $2}')
  
echo "${separator// /-} Worker IP: $worker1ip ${separator// /-}"

while ! nc -z $worker1ip 22; do
  echo "${separator// /-} Waiting for The Machine to Turn On ${separator// /-}"
  sleep 1
done
    
echo "${separator// /-} Adding Server to known_hosts ${separator// /-}"
ssh-keyscan -H "$worker1ip" -p 22 >> /Users/koraykutanoglu/.ssh/known_hosts

echo "${separator// /-} Server Update & Upgrade Process ${separator// /-}"
ssh root@$worker1ip <<EOF
  sudo -E apt update
  sudo -E apt upgrade -y
  curl -sfL https://get.k3s.io | K3S_URL=https://$ip:6443 K3S_TOKEN="$token" sh -
  systemctl enable --now k3s-agent
EOF

echo "${separator// /-} Creating Kubernetes Agent ${separator// /-}"  
worker02ip=$(hcloud server create --name k3s-worker02 --image $SERVER_IMAGE --type $SERVER_TYPE --without-ipv6 --location $SERVER_LOCATION --ssh-key $SERVER_SSHKEY | grep "IPv4:" | awk '{print $2}')
  
echo "${separator// /-} Worker02 IP: $worker02ip ${separator// /-}"

while ! nc -z $worker02ip 22; do
  echo "${separator// /-} Waiting for The Machine to Turn On ${separator// /-}"
  sleep 1
done
    
echo "${separator// /-} Adding Server to known_hosts ${separator// /-}"
ssh-keyscan -H "$worker02ip" -p 22 >> /Users/koraykutanoglu/.ssh/known_hosts

echo "${separator// /-} Server Update & Upgrade Process ${separator// /-}"
ssh root@$worker02ip <<EOF
  sudo -E apt update
  sudo -E apt upgrade -y
  curl -sfL https://get.k3s.io | K3S_URL=https://$ip:6443 K3S_TOKEN="$token" sh -
  systemctl enable --now k3s-agent
EOF


echo "${separator// /-} Set Label Kubernetes Nodes ${separator// /-}"
ssh root@$ip <<EOF
  kubectl label nodes k3s-worker01 node-role.kubernetes.io/master=true
  kubectl label nodes k3s-worker01 node-role.kubernetes.io/worker=true
  kubectl label nodes k3s-worker01 node-role.kubernetes.io/control-plane=true

  kubectl label nodes k3s-worker02 node-role.kubernetes.io/master=true
  kubectl label nodes k3s-worker02 node-role.kubernetes.io/worker=true
  kubectl label nodes k3s-worker02 node-role.kubernetes.io/control-plane=true

  kubectl label nodes k3s-main node-role.kubernetes.io/worker=true
EOF

delete_server "$SERVER_NAME"

hcloud server delete k3s-worker01
hcloud server delete k3s-worker02