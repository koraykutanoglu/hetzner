#!/bin/bash

#machine oluşturuluyor

# cx21  =  2 CPU 4GB Ram
# cpx21 =  3 CPU 4GB Ram
# cx31  =  2 CPU 8GB Ram
# cpx31 =  4 CPU 8GB Ram

echo "machine oluşturuluyor"
ip=$(hcloud server create --name k3s --image ubuntu-20.04 --type cpx31 --without-ipv6 --location hel1 --ssh-key mac | grep "IPv4:" | awk '{print $2}')
echo "Oluşturulan IP: $ip"

while ! nc -z $ip 22; do
    echo "Machine'nin açılması bekleniyor"
    sleep 1
done

echo "Sunucu known_hosts'a ekleniyor"
ssh-keyscan -H "$ip" -p 22 >> /Users/koraykutanoglu/.ssh/known_hosts

echo "Güncellemeler Yapılıyor"
ssh root@$ip "sudo -E apt update;sudo -E apt upgrade -y"

echo "sunucuya bağlanılıyor"
ssh root@$ip

read -p "Sunucuyu silmek için entere basın"
hcloud server delete k3s

echo "açık sunucu varmı kontrol et"
hcloud server list