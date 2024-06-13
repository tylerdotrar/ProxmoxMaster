#!/bin/bash

# AUTHOR: Tyler McCann (@tylerdotrar)
# ARBITRARY VERSION NUMBER: 1.1.1
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

# Target File for Node Hardware Monitoring
nodes='/usr/share/perl5/PVE/API2/Nodes.pm'
nodes_bak="${nodes}.bak" # Backup of original file
nodes_tmp="${nodes}.tmp" # Temporary file storing custom contents

# Target File for Summary Page Formatting
manager='/usr/share/pve-manager/js/pvemanagerlib.js'
manager_bak="${manager}.bak" # Backup of original file
manager_tmp="${manager}.tmp" # Temporary file storing custom contents

# Acquire Number of Sockets
cpu_sockets=$(lscpu | grep 'Socket(s):' | awk -F: '{print $2}' | sed -r 's/\s+//g')

### Step 1: Setup CPU temp monitoring
print_yellow "[+] Attempting to install and execute 'sensors' tool..."
apt install lm-sensors -y
sensors-detect --auto
echo -e " o  Done.\n"


### Step 2: Add Node CPU Temperature Readings
print_yellow "[+] Adding sensors reference to '$nodes'..."

# Create backup of target file
echo " o  Backup file created: '$nodes_bak'"
cp $nodes $nodes_bak

# Insert sensors reference
echo -e '\n\t# Added Reference for CPU Temperature Readings
\t$res->{CPUtemperature} = `sensors`;' > $nodes_tmp

# Get line number of unique string and paste contents immediately after
line_node=$(grep -n '$dinfo' $nodes | head -1 | cut -f1 -d:)
sed -i "$line_node r $nodes_tmp" $nodes

# Remove temp contents file
rm $nodes_tmp
echo -e " o  Done.\n"


### Step 3: Display Readings on Proxmox Summary
print_yellow "[+] Formatting CPU temperature readings in '$manager'..."

# Create backup of target file
echo -e " o  Backup file created: '$manager_bak'"
cp $manager $manager_bak

# Adjust Sensors to the Quantity of a Sockets
echo " o  Number of CPU's Detected: ${cpu_sockets}"

# Temperature Readings for a Single CPU
if [[ $cpu_sockets == "1" ]]; then
  
  # Insert CPU formatting (Package + Cores 0-3)
  echo -e '\t// Added Formatting for CPU Temperature Readings
\t{
	\titemId: "CPUtemperature",
	\tcolspan: 2,
	\tprintBar: false,
  \ttitle: gettext("CPU Temperature(s)"),
	\ttextField: "CPUtemperature",
	\trenderer: function(value) {
		\tconst package = value.match(/Package id 0.*?\+([\d\.]+)Â/)[1];
		\tconst c0 = value.match(/Core 0.*?\+([\d\.]+)Â/)[1];
		\tconst c1 = value.match(/Core 1.*?\+([\d\.]+)Â/)[1];
		\tconst c2 = value.match(/Core 2.*?\+([\d\.]+)Â/)[1];
		\tconst c3 = value.match(/Core 3.*?\+([\d\.]+)Â/)[1];
		\treturn `Package: ${package}℃ | Core 0: ${c0}℃ | Core 1: ${c1}℃ | Core 2: ${c2}℃ | Core 3: ${c3}℃`
	\t}
\t},' > $manager_tmp

# Temperature Readings for Two CPUs 
elif [[ $cpu_sockets == "2" ]]; then 
  
  # Insert CPU formatting (CPU1 + CPU2)
  echo -e '\t// Added Formatting for CPU Temperature Readings
\t{
	\titemId: "CPUtemperature",
	\tcolspan: 2,
	\tprintBar: false,
  \ttitle: gettext("CPU Temperature(s)"),
	\ttextField: "CPUtemperature",
	\trenderer: function(value) {
		\tconst cpu1 = value.match(/Package id 0.*?\+([\d\.]+)Â/)[1];
		\tconst cpu2 = value.match(/Package id 1.*?\+([\d\.]+)Â/)[1];
		\treturn `CPU 1: ${cpu1}℃ | CPU 2: ${cpu2}℃ `
	\t}
\t},' > $manager_tmp

# Temperature Readings for Three CPUs (weirdo???) 
elif [[ $cpu_sockets == "3" ]]; then 
  
  # Insert CPU formatting (CPU1 + CPU2 + CPU3)
  echo -e '\t// Added Formatting for CPU Temperature Readings
\t{
	\titemId: "CPUtemperature",
	\tcolspan: 2,
	\tprintBar: false,
  \ttitle: gettext("CPU Temperature(s)"),
	\ttextField: "CPUtemperature",
	\trenderer: function(value) {
		\tconst cpu1 = value.match(/Package id 0.*?\+([\d\.]+)Â/)[1];
		\tconst cpu2 = value.match(/Package id 1.*?\+([\d\.]+)Â/)[1];
		\tconst cpu3 = value.match(/Package id 2.*?\+([\d\.]+)Â/)[1];
		\treturn `CPU 1: ${cpu1}℃ | CPU 2: ${cpu2}℃ | CPU 3: ${cpu3}℃ `
	\t}
\t},' > $manager_tmp

# Temperature Readings for Four CPUs 
elif [[ $cpu_sockets == "4" ]]; then 
  
  # Insert CPU formatting (CPU1 + CPU2 + CPU3 + CPU4)
  echo -e '\t// Added Formatting for CPU Temperature Readings
\t{
	\titemId: "CPUtemperature",
	\tcolspan: 2,
	\tprintBar: false,
  \ttitle: gettext("CPU Temperature(s)"),
	\ttextField: "CPUtemperature",
	\trenderer: function(value) {
		\tconst cpu1 = value.match(/Package id 0.*?\+([\d\.]+)Â/)[1];
		\tconst cpu2 = value.match(/Package id 1.*?\+([\d\.]+)Â/)[1];
		\tconst cpu3 = value.match(/Package id 2.*?\+([\d\.]+)Â/)[1];
		\tconst cpu4 = value.match(/Package id 3.*?\+([\d\.]+)Â/)[1];
		\treturn `CPU 1: ${cpu1}℃ | CPU 2: ${cpu2}℃ | CPU 3: ${cpu3}℃ | CPU 4: ${cpu4}℃ `
	\t}
\t},' > $manager_tmp
fi

# Get line number of unique string (+ 2) and paste contents immediately after
line=$(grep -n 'Proxmox.Utils.render_cpu_model' $manager | cut -f1 -d:)
line_p2=$((line + 2))
sed -i "$line_p2 r $manager_tmp" $manager

# Remove temp contents file
rm $manager_tmp
echo -e " o  Done.\n"


### Step 4: Restart the Summary Page
print_yellow "[+] Restarting 'pveproxy' to reload the summary page..."
systemctl restart pveproxy
echo -e " o  You will need to reload your page/clear your cache to see these changes (or open with a private window)."
echo -e " o  Done.\n"
