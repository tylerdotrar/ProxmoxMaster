#!/bin/bash

# Simple Passbolt script to allow for user registration without email

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


# Banner
cat << 'EOF'
 ____               _           _ _
|  _ \ __ _ ___ ___| |__   ___ | | |_
| |_) / _` / __/ __| '_ \ / _ \| | __|
|  __/ (_| \__ \__ \ |_) | (_) | | |_
|_|   \__,_|___/___/_.__/ \___/|_|\__|

EOF


# Example Passbolt Server URL to Replace
passboltURL="https://passbolt.domain"


# Username (aka email) to Register
while :
do 
  echo "${yellow}[+] Variable Configuration${white}"
  read -p "${white} o  Input Username (e.g., user@example.com) : ${red}" registerUsername
  read -p "${white} o  Input First Name                        : ${red}" registerFname
  read -p "${white} o  Input Last Name                         : ${red}" registerLname
  read -p "${white} o  Input Role ('admin' or 'user')          : ${red}" registerRole
  
  # Prompt to Accept above Settings
  read -p "${yellow}[+] Accept the above settings? (yes/no)${white}     : ${red}" acceptSettings
  echo "${white}"

  if [[ $acceptSettings == 'yes' || $acceptSettings == 'y' ]]; then
    break
  elif [[ $acceptSettings == 'exit' || $acceptSettings == 'quit' ]]; then
    exit 
  fi
done

# Generate Recovery Link (bypassing email requirements)
cakeOut=$(su -c "/usr/share/php/passbolt/bin/cake passbolt register_user -u $registerUsername -f $registerFname -l $registerLname -r $registerRole" -s /bin/bash www-data) || exit 1
registerURL=$(echo $cakeOut | awk '{print $NF}' | tail -n 1)

echo "${green} >  Registration Link                      ${white} : ${passboltURL}${registerURL}"

