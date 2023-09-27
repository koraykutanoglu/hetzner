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

install_argocd() {

  echo "${separator// /-} Install ArgoCD ${separator// /-}"
  ssh root@$ip "kubectl create namespace argocd;kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"

  max_retries=16
  retries=0
  while [ $retries -lt $max_retries ]; do
    argocd_password=$(ssh root@$ip "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d" 2>/dev/null)
    if [ -n "$argocd_password" ]; then
        echo "${separator// /-} ArgoCD admin şifresi: $argocd_password ${separator// /-}"
        break
    else
        echo "${separator// /-} ArgoCD admin şifresi henüz hazır değil, bekleniyor... ${separator// /-}"
        sleep 5
        retries=$((retries + 1))
    fi
  done

  if [ -z "$argocd_password" ]; then
    echo "${separator// /-} ArgoCD admin şifresi alınamadı, işlem başarısız oldu. ${separator// /-}"
  else
    echo "${separator// /-} işlemlere devam ediliyor ${separator// /-}"
  fi

echo "${separator// /-} Setting the ArgoCD Service as a NodePort ${separator// /-}"
ssh root@$ip <<EOF
  kubectl patch service argocd-server -n argocd --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"}]'
  kubectl patch service argocd-server -n argocd --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"},{"op":"replace","path":"/spec/ports/0/nodePort","value":30000}]'
  kubectl get services -n argocd
  echo "ArgoCD Erişim IP'si: http://$ip:30000"
EOF

}