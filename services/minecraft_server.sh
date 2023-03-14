#!/bin/bash

# Author: Tyler McCann (tylerdotrar)
# Arbitrary Version Number: 1.1.0
# Link: https://github.com/tylerdotrar/ProxmoxMaster

### Script Headers and Banners
service='Minecraft_Server'
service_lower=$(echo $service | tr 'A-Z' 'a-z' | sed 's/\.//')

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
  echo -e -n "\n${yellow_prompt}Server RAM Allocation (default: 1024M): ${red_input}"
  read ram_prompt
  echo -e -n "\n${yellow_prompt}Change default server properties? (yes/no): ${red_input}"
  read server_prompt

  if [[ $server_prompt == 'yes' || $server_prompt == 'y' ]]

  then
    echo -e -n "${yellow_prompt}-->  Server Name: ${red_input}"
    read levelname_prompt
    echo -e -n "${yellow_prompt}-->  Message of the Day: ${red_input}"
    read motd_prompt
    echo -e -n "${yellow_prompt}-->  Password: ${red_input}"
    read password_prompt
    echo -e -n "${yellow_prompt}-->  Gamemode (survival, creative, adventure, spectator): ${red_input}"
    read gamemode_prompt
    echo -e -n "${yellow_prompt}-->  Difficulty (peaceful, easy, normal, hard): ${red_input}"
    read difficulty_prompt
    echo -e -n "${yellow_prompt}-->  Level Type (normal, flat, large_biomes, amplified, single_biome_surface): ${red_input}"
    read leveltype_prompt
    echo -e -n "${yellow_prompt}-->  PvP (true, false): ${red_input}"
    read pvp_prompt
    
  else
    levelname_prompt='world'
    motd_prompt='A Minecraft Server'
    password_prompt=''
    gamemode_prompt='survival'
    difficulty_prompt='easy'
    leveltype_prompt='normal'
    pvp_prompt='true'
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

apt add-apt-repository ppa:openjdk-r/ppa -y &>/dev/null
apt update &>/dev/null
apt install openjdk-17-jre-headless curl -y &>/dev/null
echo -e "${green_notice}Complete."


### Download, Install, and Clean-up Service
echo -e "\n${blue_start}Installing ${service}..."
generic_agent="Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/81.0"
minecraft_url="https://minecraft.net/en-us/download/server"

server_version=$(curl --user-agent "$generic_agent" -f -L "https://minecraft.net/en-us/download/server"  2>/dev/null | grep -Eo "minecraft_server(.[1-9]*)+(.jar)$")
server_url=$(curl --user-agent "$generic_agent" -f -L "https://minecraft.net/en-us/download/server"  2>/dev/null | grep -Eo "https://\S+?/server.jar")
curl --user-agent "$generic_agent" $server_url --output $server_version &>/dev/null

echo -e "${green_notice}Complete."


### Configuring Service with User Input
echo -e "\n${blue_start}Configuring ${service} with user input data..."

java -Xmx${ram_prompt} -Xms${ram_prompt} -jar $server_version nogui &>/dev/null
sed -i 's/eula=false/eula=true/g' eula.txt

sed -i "s/level-name=world/level-name=${levelname_prompt}/g" server.properties
sed -i "s/motd=A Minecraft Server/motd=${motd_prompt}/g" server.properties
sed -i "s/rcon.password=/rcon.password=${password_prompt}/g" server.properties
sed -i "s/gamemode=survival/gamemode=${gamemode_prompt}/g" server.properties
sed -i "s/difficulty=easy/difficulty=${difficulty_prompt}/g" server.properties
sed -i "s/level-type=minecraft\\\:normal/level-type=minecraft\\\:${leveltype_prompt}/g" server.properties
sed -i "s/pvp=true/pvp=${pvp_prompt}/g" server.properties

echo -e "${green_notice}Complete."


### Create Systemd Service
echo -e "\n${blue_start}Creating a '${service_lower}' Service..."
service_path="/etc/systemd/system/${service_lower}.service"

# Effectively this is an alias for nginx, apache, node, etc.
echo "[Unit]
Description=${service}
After=network.target

[Service]
Type=simple
PIDFile=/run/${service_lower}.pid
WorkingDirectory=$(pwd)
ExecStart=/usr/bin/java -Xmx${ram_prompt} -Xms${ram_prompt} -jar ${server_version} nogui
ExecStop=-/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile /run/${service_lower}.pid
TimeoutStopSec=5
KillMode=mixed

[Install]
WantedBy=multi-user.target" > $service_path

systemctl enable --now ${service_lower} &>/dev/null
echo -e "${green_notice}Complete."
echo -e "\n${yellow_final}${service} was successfully installed."