#!/bin/bash

cat << 'EOF'
 ____                                    __  __           _            
|  _ \ _ __ _____  ___ __ ___   _____  _|  \/  | __ _ ___| |_ ___ _ __ 
| |_) | '__/ _ \ \/ / '_ ` _ \ / _ \ \/ / |\/| |/ _` / __| __/ _ \ '__|
|  __/| | | (_) >  <| | | | | | (_) >  <| |  | | (_| \__ \ ||  __/ |   
|_|   |_|  \___/_/\_\_| |_| |_|\___/_/\_\_|  |_|\__,_|___/\__\___|_|   

Author: Tyler McCann (@tylerdotrar)
Arbitrary Version Number: v0.9.0

EOF


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

# Custom Json parsing functions to reduce dependencies
function jsonValue() {
  KEY=$1
  num=$2
  awk -F"[,:}]" '{for(i=1;i<=NF;i++){if($i~/'$KEY'\042/){print $(i+1)}}}' | tr -d '"' | sed -n ${num}p | sed -e 's/^[[:space:]]*//'
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


# Validate script is being ran with elevated privileges
if [ "$EUID" -ne 0 ]; then 
  echo "[-] Script must be ran as root."
  exit
fi


# Base URL
base_url="https://raw.githubusercontent.com/tylerdotrar/ProxmoxMaster/main"
#base_url="http://127.0.0.1" # Testing

# Fetch JSON data and store in variable
available_json="$(wget -qO- "${base_url}/modules.json")"
if [ -z "$available_json" ]; then
  print_red "[-] Failed to grab available modules."
  exit
fi


# Display Service Modules
print_yellow "[+] Available LXC Service Installation Scripts:"
services="$(echo "$available_json" | extract_services)"
service_count=$(echo "$services" | wc -l)

for ((i=1; i<=$service_count; i++)); do
  echo -n ' o  ['
  print_red --ignore-newline $(echo "$services" | jsonValue id $i)
  echo -n '] '
  print_green "$(echo "$services" | jsonValue display $i)"
done


# Display Management Modules
print_yellow "\n[+] Available Proxmox Node Management Scripts:" 
management="$(echo "$available_json" | extract_management)"
management_count=$(echo "$management" | wc -l)

for ((i=1; i<=$management_count; i++)); do
  echo -n ' o  ['
  print_red --ignore-newline $(echo $management | jsonValue id $i)
  echo -n '] '
  print_green "$(echo $management | jsonValue display $i)"
done


# User Selection
total_ids=$((${management_count}+${service_count}))
while :
do 
  print_yellow --ignore-newline "\n[+] Select Target ID: " 
  read target_id
  
  if [[ ! $target_id -gt $total_ids ]]; then
    echo ""
    break 
  else
    print_red "\n[-] Invalid module ID. Try again."
  fi
done


# Put target URL together (base URL + category + module)
if [[ $target_id -gt $service_count ]]; then
  target_category="management"
else 
  target_category="services"
fi 
target_module="$(echo "$available_json" | jsonValue module $target_id)"
target_url="${base_url}/${target_category}/${target_module}"


# Download and Execute Target Script
bash -c "$(wget -qO- ${target_url})"
