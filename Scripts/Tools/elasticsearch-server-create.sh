#!/bin/bash

source ../main.sh 

# cx21  =  2 CPU 4GB Ram
# cpx21 =  3 CPU 4GB Ram
# cx31  =  2 CPU 8GB Ram
# cpx31 =  4 CPU 8GB Ram

SERVER_NAME=Elasticsearch
SERVER_IMAGE=ubuntu-22.04
SERVER_TYPE=cpx31
SERVER_LOCATION=hel1
SERVER_SSHKEY=mac

create_server "$SERVER_NAME" "$SERVER_IMAGE" "$SERVER_TYPE" "$SERVER_LOCATION" "$SERVER_SSHKEY"

echo "${separator// /-} Install ElasticSearch ${separator// /-}"
ssh root@$ip <<EOF
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
sudo -E apt-get install apt-transport-https
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
sudo -E apt update && sudo -E apt install elasticsearch
sed -i 's/#network.host: 192.168.0.1/network.host: $ip/g' /etc/elasticsearch/elasticsearch.yml
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service
EOF

delete_server "$SERVER_NAME"