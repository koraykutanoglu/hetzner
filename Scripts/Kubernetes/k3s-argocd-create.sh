#!/bin/bash

#machine oluşturuluyor

# cx21  =  2 CPU 4GB Ram
# cpx21 =  3 CPU 4GB Ram
# cx31  =  2 CPU 8GB Ram
# cpx31 =  4 CPU 8GB Ram

echo "machine oluşturuluyor"
ip=$(hcloud server create --name k3s --image ubuntu-20.04 --type cx21 --without-ipv6 --location hel1 --ssh-key mac | grep "IPv4:" | awk '{print $2}')
echo "Oluşturulan IP: $ip"

while ! nc -z $ip 22; do
    echo "Machine'nin açılması bekleniyor"
    sleep 2
done

echo "Sunucu known_hosts'a ekleniyor"
ssh-keyscan -H "$ip" -p 22 >> /Users/koraykutanoglu/.ssh/known_hosts

echo "k3s kuruluyor"
ssh root@$ip "sudo -E apt update;sudo -E apt upgrade -y;curl -sfL https://get.k3s.io | sudo sh -;kubectl get nodes"

echo "ArgoCD Kuruluyor"
ssh root@$ip "kubectl create namespace argocd;kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"

max_retries=16
retries=0
while [ $retries -lt $max_retries ]; do
    argocd_password=$(ssh root@$ip "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d" 2>/dev/null)
    if [ -n "$argocd_password" ]; then
        echo "ArgoCD admin şifresi: $argocd_password"
        break
    else
        echo "ArgoCD admin şifresi henüz hazır değil, bekleniyor..."
        sleep 5
        retries=$((retries + 1))
    fi
done

if [ -z "$argocd_password" ]; then
    echo "ArgoCD admin şifresi alınamadı, işlem başarısız oldu."
else
    echo "işlemlere devam ediliyor"
fi

echo "sunucuya bağlanılıyor"
ssh root@$ip

read -p "Sunucuyu silmek için entere basın"
hcloud server delete k3s