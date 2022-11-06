#!/bin/bash

# Author: Tyler McCann (tylerdotrar)
# Arbitrary Version Number: 1.0.0
# Link: https://github.com/tylerdotrar/ProxmoxMaster

### Script Headers and Banners
service='<ADD_STUFF_HERE>'
header="${service} Installation Script"
length=${#header}

repeat() {
  for (( i=1; i<=$1; i++ ))
  do
    echo -n "$2"
  done
}
line=$(repeat $length '=')

echo "$(tput setaf 2)${line}$(tput setaf 7)"
echo "$header"
echo "$(tput setaf 2)${line}$(tput setaf 7)"

red_input=$(tput setaf 1)
yellow_prompt=`echo "$(tput setaf 7)[$(tput setaf 3)PROMPT$(tput setaf 7)]  "`
yellow_final=`echo "$(tput setaf 7)[$(tput setaf 3)FINAL$(tput setaf 7)]   "`
blue_start=`echo "$(tput setaf 7)[$(tput setaf 4)START$(tput setaf 7)]   "`
green_notice=`echo "$(tput setaf 7)[$(tput setaf 2)NOTICE$(tput setaf 7)]  "`


### Prompt for Installation Settings
while :
do
  echo -e -n "\n${yellow_prompt}Utilize SSL? (yes/no): ${red_input}"
  read ssl_prompt

  if [[ $ssl_prompt == 'yes' || $ssl_prompt == 'y' ]]

  then
    ssl_bool='true'
    echo -e -n "${yellow_prompt}-->  HTTPS Port: ${red_input}"
    read https_port
    echo -e -n "${yellow_prompt}-->  SSL Certificate Path: ${red_input}"
    read cert_path
    echo -e -n "${yellow_prompt}-->  SSL Key Path: ${red_input}"
    read key_path

  else
    ssl_bool='false'
    https_port='443'
    cert_path='/etc/ssl/example.crt'
    key_path='/etc/ssl/example.key'
	echo -e -n "${yellow_prompt}HTTP Port: ${red_input}"
    read http_port
  fi

  echo -e -n "\n${yellow_prompt}Accept above settings? (yes/no): ${red_input}"
  read accept_settings

  if [[ $accept_settings == 'yes' || $accept_settings == 'y' ]]; then
    tput setaf 7
    break
  fi
done


### Updates & Dependencies
echo -e "\n${blue_start}Updating and installing dependencies..."
apt update &>/dev/null
apt upgrade -y &>/dev/null
apt install -y <ADD_STUFF_HERE> &>/dev/null
echo -e "${green_notice}Complete."


### Download, Install, and Clean-up Service
echo -e "\n${blue_start}Installing ${service}..."
<ADD_STUFF_HERE>
echo -e "${green_notice}Complete."


### Configuring Service with User Input
echo -e "\n${blue_start}Configuring ${service} with user input data..."
<ADD_STUFF_HERE>
echo -e "${green_notice}Complete."


### Finished; Restart Service/Nginx/Apache (just in case)
sleep 3
systemctl restart <WEB_SERVICE>
echo -e "\n${yellow_final}${service} was successfully installed."