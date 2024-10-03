#!/bin/bash

# Modular Script to Add Clients to 'wg0.conf' & Print Client Configurations
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
  read -p "${white} o  Enter arbitrary client identifier (e.g., ThinkChad) : ${red}" clientID
  read -p "${white} o  Enter tunnel DNS server (e.g., 1.1.1.1)             : ${red}" tunnelDNS
  read -p "${white} o  Enter server endpoint (e.g., wg.example.com:51820)  : ${red}" serverEndpoint

  # Prompt to Accept above Settings
  read -p "${yellow}[+] Accept the above settings? (yes/no)${white}                 : ${red}" acceptSettings

  if [[ $acceptSettings == 'yes' || $acceptSettings == 'y' ]]; then
    echo ""
    break
  else
  	echo ""
  fi
done


# Acquire Required Keys
clientPrivKey=$(wg genkey)
clientPubKey=$(echo $clientPrivKey | wg pubkey)
serverPubKey=$(cat /etc/wireguard/server_public.key)


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
PublicKey = ${clientPubKey} # Client 
AllowedIPs = ${clientNetwork}
" >> /etc/wireguard/wg0.conf 

# Restart Wireguard Service
systemctl restart wg-quick@wg0.service


### Part 2: Print Client Configuration

echo "${yellow}[+] EZ Client Configuration (Copy/Paste)${white}"

echo "[Interface]
PrivateKey = ${clientPrivKey} # Client 
Address = ${clientNetwork}
DNS = ${tunnelDNS}

[Peer]
PublicKey = ${serverPubKey} # Server 
AllowedIPs = 0.0.0.0/0 
Endpoint = ${serverEndpoint}
"


# Script Summary
echo "${yellow}[+] Wireguard Client Configuration Summary
 o  Server-Side: added client '${clientID}' to 'wg0' using '${clientNetwork}' 
 o  Client-Side: generated user Wireguard configuration to copy & paste
${white}"
