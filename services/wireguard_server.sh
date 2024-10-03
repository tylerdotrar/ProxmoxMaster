#!/bin/bash

# Simple Wireguard Server Installation Script (tested on Ubuntu 22.04 & 23.10 LXC's)
# Arbitrary Version Number: v0.9.9
# Author: Tyler McCann (@tylerdotrar)


# Establish Pretty Colors
yellow=$(tput setaf 3)
red=$(tput setaf 1)
white=$(tput setaf 7)


# Loop Until Variables are Established
while :
do 
  echo "${yellow}[+] Variable Configuration${white}"
  read -p "${white} o  Enter tunnel interface IP and CIDR (e.g., 10.5.0.1/24) : ${red}" tunnelNetwork
  read -p "${white} o  Enter server listening port (default port: 51820)      : ${red}" listeningPort

  # Prompt to Accept above Settings
  read -p "${yellow}[+] Accept the above settings? (yes/no)${white}                    : ${red}" acceptSettings

  if [[ $acceptSettings == 'yes' || $acceptSettings == 'y' ]]; then
    echo ""
    break
  else
  	echo ""
  fi
done


# Dependencies
echo "${yellow}[+] Installing dependencies...${white}"
apt install wireguard wireguard-tools -y 
echo -e "${yellow} o  Done.\n${white}"


# Simple Server Setup
echo "${yellow}[+] Configuring Wireguard server...${white}"

# Generate public and private keypair
wg genkey | tee /etc/wireguard/server_private.key | wg pubkey > /etc/wireguard/server_public.key
serverPrivKey=$(cat /etc/wireguard/server_private.key)

# Generate baseline 'wg0' configuration
echo "[Interface]
Address = ${tunnelNetwork}
ListenPort = ${listeningPort}
PrivateKey = ${serverPrivKey} # Server
# Tunnel Enabled: enable packet forwarding
PostUp = ufw route allow in on wg0 out on eth0
PostUp = iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
# Tunnel Disabled: disable packet forwarding
PreDown = ufw route delete allow in on wg0 out on eth0
PreDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
" > /etc/wireguard/wg0.conf

# Enable IPv4 packet forwarding
sed -i 's/^#\(net\.ipv4\.ip_forward=1\)/\1/' /etc/sysctl.conf 

# Enable Wireguard to start on boot 
systemctl enable wg-quick@wg0.service --now

# Create symbolic link to 'wg0.conf' within the home directory
ln -s /etc/wireguard/wg0.conf ~/wg0_link.conf

# Download 'wireguard_client.sh' script for easy client configurations
wget https://raw.githubusercontent.com/tylerdotrar/ProxmoxMaster/refs/heads/main/services/wireguard_client.sh -O ~/wireguard_client.sh
chmod +x wireguard_client.sh

echo -e "${yellow} o  Done.\n${white}"


# Script Summary
echo "${yellow}[+] Wireguard Installation Summary
 o  Installed: wireguard, wireguard-tools
 o  Generated server public & private keypair
 o  Generated 'wg0' tunnel configuration 
 o  Enabled IPv4 packet forwarding
 o  Enabled Wireguard server to start on boot
 o  Created symbolic link to 'wg0.conf' in home directory
 o  Downloaded 'wireguard_client.sh' in home directory for client configurations
${white}"
