#!/bin/bash

# Author: Tyler McCann (tylerdotrar)
# Arbitrary Version Number: 1.0.0
# Link: https://github.com/tylerdotrar/ProxmoxMaster

### Script Headers and Banners
service='FileGator'
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
  echo -e -n "\n${yellow_prompt}Modify 100MB file size limit? (yes/no): ${red_input}"
  read size_prompt
  
  if [[ $size_prompt == 'yes' || $size_prompt == 'y' ]]; then
    echo -e -n "${yellow_prompt}-->  Maximum File Size (MB): ${red_input}"
	read max_file_size
  fi
  
  echo -e -n "${yellow_prompt}Utilize SSL? (yes/no): ${red_input}"
  read ssl_prompt

  if [[ $ssl_prompt == 'yes' || $ssl_prompt == 'y' ]]

  then
    ssl_bool='true'
    comment=""
    echo -e -n "${yellow_prompt}-->  HTTPS Port: ${red_input}"
    read server_port
    echo -e -n "${yellow_prompt}-->  SSL Certificate Path: ${red_input}"
    read cert_path
    echo -e -n "${yellow_prompt}-->  SSL Key Path: ${red_input}"
    read key_path

  else
    ssl_bool='false'
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
apt install -y unzip php apache2 libapache2-mod-php php-zip php-mbstring php-dom php-xml &>/dev/null
echo -e "${green_notice}Complete."


### Download, Install, and Clean-up Service
echo -e "\n${blue_start}Installing ${service}..."
wget https://github.com/filegator/static/raw/master/builds/filegator_latest.zip &>/dev/null
unzip filegator_latest.zip -d /var/www &>/dev/null
rm filegator_latest.zip
chown -R www-data:www-data /var/www/filegator
chmod -R 775 /var/www/filegator
echo -e "${green_notice}Complete."


### Configuring Service with User Input
echo -e "\n${blue_start}Configuring ${service} with user input data..."
# Modify default 100MB file size limit
if [[ $size_prompt == 'yes' || $size_prompt == 'y' ]]; then
  #line_num=$(grep -n 'upload_max_size' /var/www/filegator/configuration.php | cut -f1 -d:)
  #sed -i "${line_num}s/100/${max_file_size}/" /var/www/filegator/configuration.php
  #sed -i "${line_num}s/100MB/100MB changed to ${max_file_size}MB/" /var/www/filegator/configuration.php
  sed -i "s/'upload_max_size' => 100/'upload_max_size' => ${max_file_size}/" /var/www/filegator/configuration.php
  sed -i "s/100MB/100MB changed to ${max_file_size}MB/" /var/www/filegator/configuration.php
fi

echo "<VirtualHost *:${server_port}>
    DocumentRoot /var/www/filegator/dist
    ${comment}SSLEngine on
    ${comment}SSLCertificateFile ${cert_path}
    ${comment}SSLCertificateKeyFile ${key_path}
</VirtualHost>" > /etc/apache2/sites-available/filegator.conf

# Modify ports.conf for non-default port compatibility
if [[ $ssl_bool == 'false' && $server_port != '80' ]]; then
  sed -i "s/Listen 80/Listen ${server_port}/" /etc/apache2/ports.conf
fi

if [[ $ssl_bool == 'true' ]]; then
  a2enmod ssl
  if [[ $server_port != '443' ]]; then
    sed -i "s/Listen 443/Listen ${server_port}/" /etc/apache2/ports.conf
  fi
fi

a2dissite 000-default.conf &>/dev/null
a2ensite filegator.conf &>/dev/null
systemctl enable apache2 &>/dev/null
echo -e "${green_notice}Complete."


### Finished; Restart Service/Nginx/Apache (just in case)
sleep 3
systemctl restart apache2 &>/dev/null
echo -e "\n${yellow_final}${service} was successfully installed."
echo -e "${green_notice}Default Credentials: admin/admin123"