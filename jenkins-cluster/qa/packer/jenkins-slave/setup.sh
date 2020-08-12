#!/bin/bash

echo "Install Java JDK 8"
sudo yum remove -y java
sudo yum install -y java-1.8*

sleep 5
echo "Install Docker engine"
sudo yum update -y
sudo yum install docker -y
sudo usermod -aG docker ec2-user
sudo systemctl start docker

echo "Install git"
sudo yum install -y git

sleep 5
echo "Install Telegraf"
wget https://dl.influxdata.com/telegraf/releases/telegraf-1.6.0-1.x86_64.rpm -O /tmp/telegraf.rpm
yum localinstall -y /tmp/telegraf.rpm
rm /tmp/telegraf.rpm
chkconfig telegraf on
usermod -aG docker telegraf
mv /tmp/telegraf.conf /etc/telegraf/telegraf.conf
service telegraf start

sleep 5
echo "Install SSM-Agent"
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent