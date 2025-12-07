#!/bin/bash

# Create a backup of the current Passbolt configuration.

# Author: Tyler McCann (@tylerdotrar)
# Arbitrary Version Number: v1.0.0
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

# Banner
cat << 'EOF'
 ____               _           _ _
|  _ \ __ _ ___ ___| |__   ___ | | |_
| |_) / _` / __/ __| '_ \ / _ \| | __|
|  __/ (_| \__ \__ \ |_) | (_) | | |_
|_|   \__,_|___/___/_.__/ \___/|_|\__|

EOF

# Files & Folders to Backup
PassboltPhpConfig="/etc/passbolt/passbolt.php"
PassboltNginxConfig="/etc/nginx/sites-enabled/nginx-passbolt.conf"
PassboltMySqlDB="/var/lib/mysql/passboltdb"

# Date of Backup
BackupDir="$(pwd)/backups/$(date +%F)"

# Backup the Files
mkdir -p $BackupDir
cp -f $PassboltPhpConfig $BackupDir/. 
cp -f $PassboltNginxConfig $BackupDir/. 
cp -rf $PassboltMySqlDB $BackupDir/.

echo -e "${yellow}[+] Passbolt configuration backed up!${white}"
echo -e " o  Backup Location    : ${green}${BackupDir}${white}"
echo -e " o  --> PHP Config     : ${green}${PassboltPhpConfig}${white}"
echo -e " o  --> MySQL Database : ${green}${PassboltMySqlDB}${white}"
echo -e " o  --> Nginx Config   : ${green}${PassboltNginxConfig}${white}"

