#!/bin/bash

# Rough Baseline Template for Installation Scripts 

# Author: Tyler McCann (tylerdotrar)
# Arbitrary Version Number: v1.0.0
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
service="<SERVICE_NAME_HERE>"
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
#apt install <DEPENDENCIES_HERE> -y 
echo -e "${yellow} o  Done.\n${white}"


# Download, Install, Configure, and/or Clean-up Service
echo "${yellow}[+] Configuring ${service}...${white}"
#<ADD_STUFF_HERE>
echo -e "${yellow} o  Done.\n${white}"


# Script Summary
echo "${yellow}[+] Summary
 o  Installed: <DEPENDENCIES>
 o  <ADD_STUFF_HERE>
 ${white}"
