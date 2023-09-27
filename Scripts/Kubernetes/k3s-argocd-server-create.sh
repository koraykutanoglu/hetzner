#!/bin/bash

source ../Content/main.sh 

# cx21  =  2 CPU 4GB Ram
# cpx21 =  3 CPU 4GB Ram
# cx31  =  2 CPU 8GB Ram
# cpx31 =  4 CPU 8GB Ram

SERVER_NAME=k3s-argocd
SERVER_IMAGE=ubuntu-20.04
SERVER_TYPE=cx21
SERVER_LOCATION=hel1
SERVER_SSHKEY=mac

create_server "$SERVER_NAME" "$SERVER_IMAGE" "$SERVER_TYPE" "$SERVER_LOCATION" "$SERVER_SSHKEY"

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
        echo "${separator// /-} ArgoCD admin şifresi henüz hazır değil, bekleniyor... ${separator// /-}"
        sleep 5
        retries=$((retries + 1))
    fi
done

if [ -z "$argocd_password" ]; then
    echo "ArgoCD admin şifresi alınamadı, işlem başarısız oldu."
else
    echo "işlemlere devam ediliyor"
fi


echo "${separator// /-} Setting the ArgoCD Service as a NodePort ${separator// /-}"
ssh root@$ip <<EOF
kubectl patch service argocd-server -n argocd --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"}]'
kubectl patch service argocd-server -n argocd --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"},{"op":"replace","path":"/spec/ports/0/nodePort","value":30000}]'
kubectl get services -n argocd
echo "ArgoCD Erişim IP'si: http://$ip:30000"
EOF

delete_server "$SERVER_NAME"