#!/bin/bash

# Author: Tyler McCann (tylerdotrar)
# Arbitrary Version Number: 1.3.0
# Link: https://github.com/tylerdotrar/ProxmoxMaster

### Script Headers and Banners
service='Wiki.js'
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
  echo -e -n "\n${yellow_prompt}HTTP Port: ${red_input}"
  read http_port

  echo -e -n "${yellow_prompt}Utilize SSL? (yes/no): ${red_input}"
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
apt install -y curl &>/dev/null
echo -e "${green_notice}Complete."


# Setting up Node.js Repository
echo -e "\n${blue_start}Configuring Node.js repository..."
curl -sL https://deb.nodesource.com/setup_16.x | bash - &>/dev/null
apt install -y nodejs &>/dev/null
echo -e "${green_notice}Complete."


### Download, Install, and Clean-up Service
echo -e "\n${blue_start}Installing ${service}..."
mkdir -p /var/www/wikijs
cd /var/www/wikijs
wget https://github.com/Requarks/wiki/releases/latest/download/wiki-js.tar.gz &>/dev/null
tar xzf wiki-js.tar.gz
rm wiki-js.tar.gz
echo -e "${green_notice}Complete."


### Configuring Service with User Input
echo -e "\n${blue_start}Configuring ${service} with user input data..."
cat <<EOF > /var/www/wikijs/config.yml
bindIP: 0.0.0.0
port: $http_port
db:
  type: sqlite
  storage: /var/www/wikijs/db.sqlite
logLevel: info
logFormat: default
dataPath: /var/www/wikijs/data
bodyParserLimit: 5mb
ssl:
  enabled: $ssl_bool
  port: $https_port
  provider: custom
  format: pem
  key: $key_path
  cert: $cert_path
  passphrase: null
  dhparam: null
EOF
npm rebuild sqlite3 &>/dev/null
echo -e "${green_notice}Complete."


# Create Wiki.js Service
echo -e "\n${blue_start}Creating a 'wikijs' Service..."
service_path="/etc/systemd/system/wikijs.service"
echo "[Unit]
Description=Wiki.js
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/node server
Restart=always
User=root
Environment=NODE_ENV=production
WorkingDirectory=/var/www/wikijs

[Install]
WantedBy=multi-user.target" > $service_path

systemctl enable --now wikijs &>/dev/null
echo -e "${green_notice}Complete."


### Finished; Restart Service/Nginx/Apache (just in case)
sleep 3
systemctl restart wikijs &>/dev/null
echo -e "\n${yellow_final}${service} was successfully installed."