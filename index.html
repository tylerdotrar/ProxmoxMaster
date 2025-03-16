#!/bin/bash

# This is a bash menu system intended to automate the usage of the ProxmoxMaster repository.
# Arbitrary Version Number: v1.0.1
# Author: Tyler McCann (@tylerdotrar)
#
# Usage:
#   bash -c "$(wget -qO- https://tylerdotrar.github.io/ProxmoxMaster)"
#   bash -c "$(curl -sL https://tylerdotrar.github.io/ProxmoxMaster)"


## Establish Key Internal Functions

# Visual formatting of output
print_yellow() {
  if [[ $1 == '--ignore-newline' ]]; then
   echo -n -e "$(tput setaf 3)$2$(tput setaf 7)"
  else
    echo -e "$(tput setaf 3)$1$(tput setaf 7)"
  fi
}
print_red() {
  if [[ $1 == '--ignore-newline' ]]; then
   echo -n -e "$(tput setaf 1)$2$(tput setaf 7)"
  else
    echo -e "$(tput setaf 1)$1$(tput setaf 7)"
  fi
}
print_green() {
  if [[ $1 == '--ignore-newline' ]]; then
   echo -n -e "$(tput setaf 2)$2$(tput setaf 7)"
  else
    echo -e "$(tput setaf 2)$1$(tput setaf 7)"
  fi
}


# Ugly custom JSON parsing functions to reduce script dependencies
jsonValue() {
  KEY=$1
  NUM=$2
  awk -F"[,:}]" '{for(i=1;i<=NF;i++){if($i~/'$KEY'\042/){print $(i+1)}}}' | tr -d '"' | sed -n ${NUM}p | sed -e 's/^[[:space:]]*//'
}
extract_services() {
  sed -n '/"services": \[/,/^\s*]/{
    /"services": \[/d
    /^\s*]/d
    p
  }'
}
extract_management() {
  sed -n '/"management": \[/,/^\s*]/{
    /"management": \[/d
    /^\s*]/d
    p
  }'
}


## Establish Key Script Requirements  

# Validate script is being ran with elevated privileges
if [ "$EUID" -ne 0 ]; then
  print_red "[-] Script must be ran as root."
  exit
fi

# Base URL
base_url="https://raw.githubusercontent.com/tylerdotrar/ProxmoxMaster/main"
#base_url="http://127.0.0.1"

# Fetch JSON data and store in variable (supports both curl & wget)
available_json=$(curl -sL "${base_url}/modules.json" 2>/dev/null || wget -qO- "${base_url}/modules.json" 2>/dev/null)
if [ -z "$available_json" ]; then
  print_red "[-] Failed to grab available modules."
  exit
fi


## Begin Main Functionality 

while true; do

    cat << 'EOF'
 _________________________________________________________________________
|  ____                                    __  __           _             |
| |  _ \ _ __ _____  ___ __ ___   _____  _|  \/  | __ _ ___| |_ ___ _ __  |
| | |_) | '__/ _ \ \/ / '_ ` _ \ / _ \ \/ / |\/| |/ _` / __| __/ _ \ '__| |
| |  __/| | | (_) >  <| | | | | | (_) >  <| |  | | (_| \__ \ ||  __/ |    |
| |_|   |_|  \___/_/\_\_| |_| |_|\___/_/\_\_|  |_|\__,_|___/\__\___|_|    |
|_________________________________________________________________________|
    
Author: Tyler McCann (@tylerdotrar)
Arbitrary Version Number: v1.0.1
   
EOF
    
    print_red "---------------------------------------------------------------------------"


    # Display Service Modules
    print_yellow "[+] Available Service Installation Scripts:"
    print_yellow " > (execute within Ubuntu 22.04/24.04 LXCs and VMs)\n"
    services="$(echo "$available_json" | extract_services)"
    service_count=$(echo "$services" | wc -l)
    
    for ((i=1; i<=$service_count; i++)); do
      echo -n ' o  ['
      print_red --ignore-newline $(echo "$services" | jsonValue id $i)
      echo -n '] '
      print_green "$(echo "$services" | jsonValue display $i)"
    done
    
    
    # Display Management Modules
    print_yellow "\n[+] Available PVE Node Management Scripts:"
    print_yellow " > (execute on the physical Proxmox node)\n"
    management="$(echo "$available_json" | extract_management)"
    management_count=$(echo "$management" | wc -l)
    
    for ((i=1; i<=$management_count; i++)); do
      echo -n ' o  ['
      print_red --ignore-newline $(echo $management | jsonValue id $i)
      echo -n '] '
      print_green "$(echo $management | jsonValue display $i)"
    done
    
    
    # Exit Menu
    print_yellow "\n[+] Exit Menu System:\n"
    echo -n ' o  ['
    print_red --ignore-newline '00'
    echo -n '] '
    print_green 'Return to host.'


    print_red "---------------------------------------------------------------------------"


    # User Selection
    total_ids=$((${management_count}+${service_count}))
    while :
    do
        print_yellow --ignore-newline "\n[+] Select Target ID: "
        read target_id
 
        if [[ $target_id == 'exit' ]]; then
            exit
 
        elif [[ $target_id =~ ^0*[0-9]+$ ]]; then
            sanitized_id=$((10#$target_id))
 
            if [[ $sanitized_id -eq 0 ]]; then
                exit
            elif [[ $sanitized_id -le $total_ids ]]; then
                echo ""
                break
            else
                print_red "\n[-] Invalid module ID. Try again."
            fi
 
        else
            print_red "\n[-] Invalid input.  Input proper ID."
      fi
    done
    
    
    # Put target URL together (base URL + category + module)
    if [[ $sanitized_id -gt $service_count ]]; then
      target_category="management"
    else
      target_category="services"
    fi
    target_module="$(echo "$available_json" | jsonValue module $sanitized_id)"
    target_url="${base_url}/${target_category}/${target_module}"
    
    
    # Download and Execute Target Script (supports both curl & wget)
    scriptContents=$(curl -sL ${target_url} 2>/dev/null || wget -qO- ${target_url} 2>/dev/null)
    bash -c "${scriptContents}"
  done
