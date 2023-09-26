#!/bin/bash

source ../Content/main.sh 

# cx21  =  2 CPU 4GB Ram
# cpx21 =  3 CPU 4GB Ram
# cx31  =  2 CPU 8GB Ram
# cpx31 =  4 CPU 8GB Ram

SERVER_NAME=nexus
SERVER_IMAGE=ubuntu-22.04
SERVER_TYPE=cx21
SERVER_LOCATION=hel1
SERVER_SSHKEY=mac

create_server "$SERVER_NAME" "$SERVER_IMAGE" "$SERVER_TYPE" "$SERVER_LOCATION" "$SERVER_SSHKEY"

echo "${separator// /-} Install Java ${separator// /-}"
ssh root@$ip "sudo apt install openjdk-8-jre-headless -y"

echo "${separator// /-} Install Nexus ${separator// /-}"
ssh root@$ip <<EOF
cd /opt
sudo wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz
tar -zxvf latest-unix.tar.gz
sudo mv /opt/nexus-3.*/ /opt/nexus
sed -i 's/\.\.\/sonatype-work/\.\/sonatype-work/g' /opt/nexus/bin/nexus.vmoptions
EOF

echo "${separator// /-} Transfering Nexus Service File ${separator// /-}"
scp ../Content/Nexus/nexus.service root@$ip:/etc/systemd/system/

echo "${separator// /-} Start And Enable Nexus ${separator// /-}"
ssh root@$ip <<EOF
sudo systemctl start nexus
sudo systemctl enable nexus
sleep 20
cat /opt/nexus/sonatype-work/nexus3/admin.password
password=$(cat /opt/nexus/sonatype-work/nexus3/admin.password)
echo "Nexus Admin Password: $password"
EOF

delete_server "$SERVER_NAME"