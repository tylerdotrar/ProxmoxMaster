#!/bin/bash

# AUTHOR: Tyler McCann (@tylerdotrar)
# ARBITRARY VERSION NUMBER: 1.1.2
# LINK: https://github.com/tylerdotrar/ProxmoxMaster


# Validate script is being ran with elevated privileges
if [ "$EUID" -ne 0 ]
  then echo "Script must be ran as root."
  exit
fi

# Visual formatting of output
print_yellow() {
  echo -e "$(tput setaf 3)$1$(tput setaf 7)"
}

# Determine Distro Version 
version_codename=$(cat /etc/*-release | grep 'VERSION_CODENAME' | awk -F= '{print $2}')

# Target File(s)
sources_list='/etc/apt/sources.list'
sources_list_bak="${sources_list}.bak" # Backup of original file

enterprise_list='/etc/apt/sources.list.d/pve-enterprise.list'
enterprise_list_bak="${enterprise_list}.bak" # Backup of original file


### Step 1: Remove enterprise package repository
print_yellow "[+] Removing 'pve-enterprise' package repository from '$enterprise_list'..."

# Create backup of target file
cp $enterprise_list $enterprise_list_bak
echo " o  Backup file created: '$enterprise_list_bak'"

echo -e "# Commented out due to no Proxmox License\n# deb https://enterprise.proxmox.com/debian/pve ${version_codename} pve-enterprise" > $enterprise_list
echo -e " o  Done.\n"


### Step 2: Add no-subscription package repository
print_yellow "[+] Adding 'pve-no-subscription' package repository to '$sources_list'..."

if grep -q "deb http://download.proxmox.com/debian/pve ${version_codename} pve-no-subscription" $sources_list; then
    echo " o  'pve-no-subscription' package list already exists. Skipping."
else
    # Create backup of target file
    cp $sources_list $sources_list_bak
    echo " o  Backup file created: '$sources_list_bak'"

    echo -e "\n# Added due to no Proxmox License\ndeb http://download.proxmox.com/debian/pve ${version_codename} pve-no-subscription" >> $sources_list
fi
echo -e " o  Done.\n"
