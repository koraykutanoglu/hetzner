#!/bin/bash

#machine oluşturuluyor
echo "machine oluşturuluyor"
ip=$(hcloud server create --name k3s --image ubuntu-20.04 --type cx11 --without-ipv6 --location hel1 --ssh-key mac | grep "IPv4:" | awk '{print $2}')
echo "Oluşturulan IP: $ip"

while ! nc -z $ip 22; do
    echo "Machine'nin açılması bekleniyor"
    sleep 1
done

echo "Sunucu known_hosts'a ekleniyor"
ssh-keyscan -H "$ip" -p 22 >> /Users/koraykutanoglu/.ssh/known_hosts

echo "uzak sunucuya komut gönderiliyor"
ssh root@$ip "sudo -E apt update;sudo -E apt upgrade -y;curl -sfL https://get.k3s.io | sudo sh -;kubectl get nodes"

echo "sunucuya bağlanılıyor"
ssh root@$ip

read -p "Sunucuyu silmek için entere basın"
hcloud server delete k3s