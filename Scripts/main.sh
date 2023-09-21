#!/bin/bash

separator=$(printf "%-20s" "-")

create_server() {

  local server_name=$1
  local server_image=$2
  local server_type=$3
  local server_location=$4
  local server_sshkey=$5
  
  echo "${separator// /-} Creating Server ${separator// /-}"
  
  ip=$(hcloud server create --name $server_name --image $server_image --type $server_type --without-ipv6 --location $server_location --ssh-key $server_sshkey | grep "IPv4:" | awk '{print $2}')
  
  echo "${separator// /-} Server IP: $ip ${separator// /-}"

  while ! nc -z $ip 22; do
    echo "${separator// /-} Waiting for The Machine to Turn On ${separator// /-}"
    sleep 1
  done
    
  echo "${separator// /-} Adding Server to known_hosts ${separator// /-}"
  ssh-keyscan -H "$ip" -p 22 >> /Users/koraykutanoglu/.ssh/known_hosts

  echo "${separator// /-} Server Update & Upgrade Process ${separator// /-}"
  ssh root@$ip "sudo -E apt update;sudo -E apt upgrade -y"

}

delete_server() {
  
  local server_name=$1
  
  echo "${separator// /-} Connecting to Server ${separator// /-}"
  ssh root@$ip

  echo "${separator// /-} Server Deletion ${separator// /-}"
  hcloud server delete $server_name

}

install_k3s() {

  echo "${separator// /-} Install K3S ${separator// /-}"
  ssh root@$ip "sudo -E apt update;sudo -E apt upgrade -y;curl -sfL https://get.k3s.io | sudo sh -;kubectl get nodes"

}