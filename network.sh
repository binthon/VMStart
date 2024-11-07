#!/bin/bash

INTERFACE=$(ip -4 route | grep default | awk '{print $5}' | head -n 1 | tr -d '[:space:]')

if [ -z "$INTERFACE" ]; then
  echo "Nie znaleziono aktywnego interfejsu sieciowego."
  exit 1
fi


IP_ADDRESS=$(ip -4 addr show "$INTERFACE" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
SUBNET_MASK=$(ip -4 addr show "$INTERFACE" | grep -oP '(?<=/)\d+' | head -n 1)
GATEWAY=$(ip -4 route | grep default | awk '{print $3}' | head -n 1)
DNS1="8.8.8.8"


NETPLAN_FILE="/etc/netplan/50-cloud-init.yaml"


sudo tee $NETPLAN_FILE > /dev/null <<EOF
# This file is generated from information provided by the datasource. Changes
# to it will not persist across an instance reboot. To disable cloud-init's
# network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
  version: 2
  ethernets:
    $INTERFACE:
      dhcp4: no
      addresses:
        - $IP_ADDRESS/$SUBNET_MASK
      routes:
        - to: default
          via: $GATEWAY
      nameservers:
        addresses:
          - $GATEWAY
          - $DNS1
EOF

echo "Aplikowanie ustawień Netplan..."

sudo netplan apply

echo "Konfiguracja zakończona. Adres IP $IP_ADDRESS/$SUBNET_MASK został ustawiony jako statyczny dla interfejsu $INTERFACE."
