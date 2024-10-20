#!/bin/bash

# WIP Passbolt Community Edition (CE) Server Installation Script (tested on Ubuntu 22.04/24.04) 

# Author: Tyler McCann (tylerdotrar)
# Arbitrary Version Number: v0.9.9
# Link: https://github.com/tylerdotrar/ProxmoxMaster


# Establish Pretty Colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
white=$(tput setaf 7)


# Validate script is being ran with elevated privileges
if [ "$EUID" -ne 0 ]; then
  echo "${red}[-] Script must be ran as root.${white}"
  exit
fi


# Script Headers and Banners
service="Passbolt Server"
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
  
  read -p "${white} o  Passbolt Server Domain Name          : ${red}" passboltDomain
  read -p "${white} o  Utilize SSL? (yes/no)                : ${red}" sslPrompt

  if [[ $sslPrompt == 'yes' || $sslPrompt == 'y' ]]; then
    sslBool='true'
    read -p "${white} o  -->  HTTPS Port                      : ${red}" httpsPort
    read -p "${white} o  -->  SSL Certificate Path            : ${red}" certPath 
    read -p "${white} o  -->  SSL Key Path                    : ${red}" keyPath
  else
    sslBool='false'
    httpsPort='443'
    certPath='/etc/ssl/example.crt'
    keyPath='/etc/ssl/example.key'
    read -p "${white} o  HTTP Port                            : ${red}" httpPort 
  fi

  # Prompt to Accept above Settings
  read -p "${yellow}[+] Accept the above settings? (yes/no)${white}  : ${red}" acceptSettings
  echo "${white}"

  if [[ $acceptSettings == 'yes' || $acceptSettings == 'y' ]]; then
    break
  elif [[ $acceptSettings == 'exit' || $acceptSettings == 'quit' ]]; then
    exit 
  fi
done


# Updates & Dependencies
echo "${yellow}[+] Installing dependencies...${white}"
apt update && apt upgrade -y

wget "https://download.passbolt.com/ce/installer/passbolt-repo-setup.ce.sh"
wget https://github.com/passbolt/passbolt-dep-scripts/releases/latest/download/passbolt-ce-SHA512SUM.txt

# Validate Checksum & Cleanup
sha512sum -c passbolt-ce-SHA512SUM.txt && bash ./passbolt-repo-setup.ce.sh || echo "${red}[-] Bad checksum. Aborting.${white}" && rm -f passbolt-repo-setup.ce.sh && exit

rm -f passbolt-repo-setup.ce.sh passbolt-ce-SHA512SUM.txt
apt install passbolt-ce-server -y

echo -e "${yellow} o  Done.\n${white}"


# Download, Install, Configure, and/or Clean-up Service
echo "${yellow}[+] Configuring ${service}...${white}"
#<ADD_STUFF_HERE>

# Download helper scripts for EZ User Configurations without Email (supports wget and curl)
registerScript="https://raw.githubusercontent.com/tylerdotrar/ProxmoxMaster/refs/heads/main/services/passbolt_register_user.sh"
recoverScript="https://raw.githubusercontent.com/tylerdotrar/ProxmoxMaster/refs/heads/main/services/passbolt_recover_user.sh"

curl ${registerScript} -o ~/passbolt_register_user.sh 2>/dev/null || wget ${registerScript} -O ~/passbolt_register_user.sh 2>/dev/null
curl ${recoverScript} -o ~/passbolt_recover_user.sh 2>/dev/null || wget ${recoverScript} -O ~/passbolt_recover_user.sh 2>/dev/null

chmod +x ~/passbolt_register_user.sh
chmod +x ~/passbolt_recover_user.sh

# Modifying helper scripts with custom Passbolt Domain
sed -i "s|^passboltURL=.*|passboltURL=\"${passboltDomain}\"|g" ~/passbolt_register_user.sh
sed -i "s|^passboltURL=.*|passboltURL=\"${passboltDomain}\"|g" ~/passbolt_recover_user.sh

echo -e "${yellow} o  Done.\n${white}"


# Script Summary
echo "${yellow}[+] Summary
 o  Installed: passbolt-ce-server
 o  Downloaded 'passbolt_register_user.sh' to home directory for user registration.
 o  Downloaded 'passbolt_recover_user.sh' to home directory for user recovery.
 ${white}"
