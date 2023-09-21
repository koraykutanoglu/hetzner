#!/bin/bash

source ../main.sh 

# cx21  =  2 CPU 4GB Ram
# cpx21 =  3 CPU 4GB Ram
# cx31  =  2 CPU 8GB Ram
# cpx31 =  4 CPU 8GB Ram

# create_server "$server_name" "$server_image" "$server_type" "$server_location" "$server_sshkey"
create_server "k3s" "ubuntu-20.04" "cx21" "hel1" "mac"

install_k3s

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

delete_server