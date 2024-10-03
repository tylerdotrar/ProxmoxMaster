#!/bin/bash

# Simple Wireguard Server Installation Script (tested on Ubuntu 22.04 & 23.10 LXC's)

# Arbitrary Version Number: v1.0.0
# Author: Tyler McCann (@tylerdotrar)
# Link: https://github.com/tylerdotrar/ProxmoxMaster


# Establish Pretty Colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
white=$(tput setaf 7)


# Script Headers and Banners
service="Wireguard Server"
header=" ${service} Installation "
length=${#header}


# Dynamically Format and Print Banner
repeat() {
  for (( i=1; i<=$1; i++ ))
  do
    echo -n "$2"
  done
}
line=$(repeat $length '-')

echo "${green}
.${line}.
|${white}${header}${green}|
'${line}'
${white}"


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


# Updates & Dependencies
echo "${yellow}[+] Installing dependencies...${white}"
apt update && apt upgrade -y
apt install wireguard wireguard-tools -y 
echo -e "${yellow} o  Done.\n${white}"


# Simple Server Setup
echo "${yellow}[+] Configuring ${service}...${white}"

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
sysctl -p

# Enable Wireguard to start on boot 
systemctl enable wg-quick@wg0.service --now

# Create symbolic link to 'wg0.conf' within the home directory
ln -s /etc/wireguard/wg0.conf ~/wg0_link.conf

# Download 'wireguard_client.sh' script for easy client configurations
wget https://raw.githubusercontent.com/tylerdotrar/ProxmoxMaster/refs/heads/main/services/wireguard_client.sh -O ~/wireguard_client.sh
chmod +x wireguard_client.sh

echo -e "${yellow} o  Done.\n${white}"


# Script Summary
echo "${yellow}[+] Summary
 o  Installed: wireguard, wireguard-tools
 o  Generated server public & private keypair
 o  Generated 'wg0' tunnel configuration 
 o  Enabled IPv4 packet forwarding
 o  Enabled Wireguard server to start on boot
 o  Created symbolic link to 'wg0.conf' in home directory
 o  Downloaded 'wireguard_client.sh' in home directory for client configurations
${white}"
