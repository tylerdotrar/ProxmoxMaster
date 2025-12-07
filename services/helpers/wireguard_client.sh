#!/bin/bash

# Modular Script to add Clients to 'wg0.conf' & Print Client Configurations

# Arbitrary Version Number: v1.0.2
# Author: Tyler McCann (@tylerdotrar)
# Link: https://github.com/tylerdotrar/ProxmoxMaster


# Establish Pretty Colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
white=$(tput setaf 7)


# Validate script is being ran with elevated privileges
if [ "$EUID" -ne 0 ]; then
  echo "${red}[!] Error! Script must be ran as root.${white}"
  exit
fi


# Script Headers and Banners
service="Wireguard Client"
header=" ${service} Configuration "
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
'${line}'${white}"


# Print Public & Local IP to aid in determining server endpoint
interface=$(ip route | grep "default" | awk -F 'dev ' '{print $2}' | awk '{print $1}')
publicIP=$(curl -sL ipinfo.io/ip 2>/dev/null || wget -qO- ipinfo.io/ip 2>/dev/null)
localIP=$(ip -br a | grep "${interface}" | awk '{print $3}' | awk -F '/' '{print $1}')

echo -e "${green} > Server Public IP ${white}: ${publicIP}"
echo -e "${green} > Server Local IP  ${white}: ${localIP}\n"


# Loop Until Variables are Established
while :
do 
  echo "${yellow}[+] Variable Configuration${white}"
  read -p "${white} o  Enter arbitrary client identifier (e.g., ThinkChad) : ${red}" clientID
  read -p "${white} o  Enter tunnel DNS server (e.g., 1.1.1.1)             : ${red}" tunnelDNS
  read -p "${white} o  Enter server endpoint (e.g., wg.example.com:51820)  : ${red}" serverEndpoint

  # Prompt to Accept above Settings
  read -p "${yellow}[+] Accept the above settings? (yes/no)${white}                 : ${red}" acceptSettings
  echo "${white}"

  if [[ $acceptSettings == 'yes' || $acceptSettings == 'y' ]]; then
    break
  elif [[ $acceptSettings == 'exit' || $acceptSettings == 'quit' ]]; then
    exit 
  fi
done


# Acquire Required Keys
clientPrivKey=$(wg genkey)
clientPubKey=$(echo $clientPrivKey | wg pubkey)
serverPubKey=$(cat /etc/wireguard/server_public.key)
presharedKey=$(wg genpsk)


### Part 1: Apply Changes Server-Side

# Determine base tunnel IP range
network=$(sed -n 's/^Address = \(.*\)/\1/p' /etc/wireguard/wg0.conf)

# Store all 4th Octets into an Array 
fourthOctets=()
while IFS= read -r octet; do
    fourthOctets+=("$octet")
done < <(awk -F '[/.]' '/Address|AllowedIPs/ {print $4}' /etc/wireguard/wg0.conf)

# Add +1 to the largest octet, then rebuild network for Client
fourthOctet=${fourthOctets[0]}
for value in "${fourthOctets[@]}"; do
    # Compare the current value with the fourthOctet
    if (( $(awk "BEGIN {print ($value > $fourthOctet)}") )); then
        fourthOctet=$value
    fi
done

fourthOctet=$(awk "BEGIN {print $fourthOctet + 1}")
clientNetwork=$(echo $network | awk -v clientNetwork="$fourthOctet" -F '[/.]' '{print $1 "." $2 "." $3 "." clientNetwork "/32"}')

# Add Client Configuration to the 'wg0' Interface
echo "[Peer] # ${clientID}
PublicKey    = ${clientPubKey} # Client 
PresharedKey = ${presharedKey}
AllowedIPs   = ${clientNetwork}
" >> /etc/wireguard/wg0.conf 

# Restart Wireguard Service
systemctl restart wg-quick@wg0.service


### Part 2: Print Client Configuration

echo "${yellow}[+] EZ Client Configuration (Copy/Paste)
---${white}
[Interface]
PrivateKey = ${clientPrivKey} # Client 
Address    = ${clientNetwork}
DNS        = ${tunnelDNS}
  
[Peer]
PublicKey    = ${serverPubKey} # Server 
PresharedKey = ${presharedKey}
AllowedIPs   = 0.0.0.0/1, 128.0.0.0/1 
Endpoint     = ${serverEndpoint}
${yellow}---
${white}"


# Script Summary
echo "${yellow}[+] Summary
 o  Server-Side: added client '${clientID}' to 'wg0' using '${clientNetwork}' 
 o  Client-Side: generated user Wireguard configuration to copy & paste
${white}"

