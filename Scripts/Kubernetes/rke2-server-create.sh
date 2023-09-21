#!/bin/bash

source ../main.sh 

# cx21  =  2 CPU 4GB Ram
# cpx21 =  3 CPU 4GB Ram
# cx31  =  2 CPU 8GB Ram
# cpx31 =  4 CPU 8GB Ram

# create_server "$server_name" "$server_image" "$server_type" "$server_location" "$server_sshkey"
create_server "k3s" "ubuntu-20.04" "cx21" "hel1" "mac"

echo "uzak sunucuya komut gönderiliyor"
ssh root@$ip "sudo -E apt update;sudo -E apt upgrade -y;curl -sfL https://get.k3s.io | sudo sh -;kubectl get nodes"

delete_server