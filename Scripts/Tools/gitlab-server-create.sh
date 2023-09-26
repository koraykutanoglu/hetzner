#!/bin/bash

source ../Content/main.sh 

# cx21  =  2 CPU 4GB Ram
# cpx21 =  3 CPU 4GB Ram
# cx31  =  2 CPU 8GB Ram
# cpx31 =  4 CPU 8GB Ram

SERVER_NAME=Gitlab
SERVER_IMAGE=ubuntu-22.04
SERVER_TYPE=cpx31
SERVER_LOCATION=hel1
SERVER_SSHKEY=mac

create_server "$SERVER_NAME" "$SERVER_IMAGE" "$SERVER_TYPE" "$SERVER_LOCATION" "$SERVER_SSHKEY"

echo "${separator// /-} Install Gitlab ${separator// /-}"
ssh root@$ip <<EOF
sudo -E apt-get install -y curl openssh-server ca-certificates tzdata perl
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y postfix
curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
sudo DEBIAN_FRONTEND=noninteractive EXTERNAL_URL="http://$ip" apt-get install gitlab-ce
cat /etc/gitlab/initial_root_password
EOF

delete_server "$SERVER_NAME"