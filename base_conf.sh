#!/bin/bash
sudo apt-get update -y 
sudo apt-get full-upgrade -y
sudo apt-get install -y -f --fix-missing ansible python3 python3-pip openssh-server 
sudo apt-get install -y -f --fix-missing nginx netplan.io

if [ -n "$NEW_HOSTNAME" ]; then

    echo "$NEW_HOSTNAME" | sudo tee /etc/hostname
    sudo hostnamectl set-hostname "$NEW_HOSTNAME"

    sudo sed -i "s/127.0.1.1.*/127.0.1.1 $NEW_HOSTNAME/" /etc/hosts
fi


sudo /tmp/network.sh
