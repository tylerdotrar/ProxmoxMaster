#!/bin/bash

# Author: Tyler McCann (tylerdotrar)
# Arbitrary Version Number: 1.0.0
# Link: https://github.com/tylerdotrar/KingOfTheHomer

### Script Headers and Banners
service='KingOfTheHomer'
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
  echo -e -n "${yellow_prompt}Utilize SSL? (yes/no): ${red_input}"
  read ssl_prompt

  if [[ $ssl_prompt == 'yes' || $ssl_prompt == 'y' ]]

  then
    ssl_bool="ssl"
    comment=""
    echo -e -n "${yellow_prompt}-->  HTTPS Port: ${red_input}"
    read server_port
    echo -e -n "${yellow_prompt}-->  SSL Certificate Path: ${red_input}"
    read cert_path
    echo -e -n "${yellow_prompt}-->  SSL Key Path: ${red_input}"
    read key_path

  else
    ssl_bool=""
    comment="#"
cert_path='/etc/ssl/example.crt'
    key_path='/etc/ssl/example.key'
    echo -e -n "${yellow_prompt}HTTP Port: ${red_input}"
	read server_port
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
apt install -y nginx git unzip &>/dev/null
echo -e "${green_notice}Complete."


### Download, Install, and Clean-up Homer Repository
echo -e "\n${blue_start}Installing ${service}..."
wget https://github.com/bastienwirtz/homer/releases/latest/download/homer.zip &>/dev/null
mkdir /var/www/homer
unzip homer.zip -d /var/www/homer &>/dev/null
rm -rf homer.zip
echo "[-] Homer dashboard installed."

git clone https://github.com/tylerdotrar/KingOfTheHomer &>/dev/null
cp -rf KingOfTheHomer/assets /var/www/homer
rm -rf KingOfTheHomer
echo "[-] ${service} theme installed."
echo -e "${green_notice}Complete."


### Configuration
echo -e "\n${blue_start}Configuring nginx with user input data..."

echo "server {
    listen ${server_port} ${ssl_bool} default_server;
    listen [::]:${server_port} ${ssl_bool} default_server;

    ${comment}ssl_certificate ${cert_path};
    ${comment}ssl_certificate_key ${key_path};

    root /var/www/homer;
    index index.html index.htm index.nginx-debian.html;
    server_name _;
}" > /etc/nginx/sites-available/homer

cp /etc/nginx/sites-available/homer /etc/nginx/sites-enabled/homer
rm /etc/nginx/sites-enabled/default
systemctl enable nginx --now &>/dev/null
echo -e "${green_notice}Complete."


### Ease of Use
echo -e "\n${blue_start}Creating a 'config.yml' symbolic link for quick editing..."
ln -s /var/www/homer/assets/config.yml ~/config_link.yml
echo "[-] '$(echo ~)/config_link.yml' created."
echo -e "${green_notice}Complete."


### Finished; Restart Service/Nginx/Apache (just in case)
sleep 3
systemctl restart nginx &>/dev/null
echo -e "\n${yellow_final}${service} was successfully installed."
