#!/bin/bash

# NextCloud (PHP 8.1) Installation Script (tested on Ubuntu 22.04 LXC)
# Arbitrary Version Number: v0.9.9
# Author: Tyler McCann (@tylerdotrar)

# Loop Until Variables are Established
while :
do
	echo "[+] Variable Configuration"

	# Prompt user for SSL usage
	read -p " o  Utilize SSL? (yes/no): " useSSL
	
	# Check user input and adjust variables accordingly
	if [[ $useSSL == 'yes' || $useSSL == 'y' ]]; then
	    #serverPort=443
	    read -p " o  HTTPS Port: " serverPort
	    read -p " o  Enter the certificate path: " cert_path
	    read -p " o  Enter the key path: " key_path
	    comment=''
	    proto='https'
	else
	    read -p " o  HTTP Port: " serverPort
	    comment='#'
	    proto='http'
	fi
	
	# Prompt user for server name, DB username, and DB password
	read -p " o  Enter server name (e.g., <hostname>.<domain>): " serverName
	read -p " o  Enter the database username: " dbUser
	read -p " o  Enter the database password: " dbPass
	
	# Prompt to Accept above Settings
	read -p "[+] Accept the above settings? (yes/no): " acceptSettings
	
	if [[ $acceptSettings == 'yes' || $acceptSettings == 'y' ]]; then
	    break
	else
		echo ""
	fi
  
done

# Dependencies
echo "[+] Installing dependencies..."
# Minimum Working Install
apt install -y php php-curl php-dompdf php-gd php-json php-xml php-xml-svg php-mbstring php-zip php-mysql php-bz2 php-intl php-ldap php-imap php-bcmath php-gmp php-memcached php-redis php-imagick ffmpeg libreoffice-nogui mariadb-server php-fpm memcached

# Improve Performance
#apt install -y php8.1-fpm memcached

echo -e " o  Done.\n"

# Simple Apache Config
echo "[+] Configuring apache..."

# Apache Web User Privs
mkdir /var/www/nextcloud
chown -R www-data:www-data /var/www/nextcloud
chmod -R 775 /var/www/nextcloud

# Site Config
echo "<VirtualHost *:${serverPort}>
  Protocols h2 h2c http/1.1
  DocumentRoot /var/www/nextcloud
  ServerName  ${serverName}

  ${comment}SSLEngine on
  ${comment}SSLCertificateFile ${cert_path}
  ${comment}SSLCertificateKeyFile ${key_path}

  <FilesMatch \.php$>
    SetHandler 'proxy:unix:/var/run/php/php8.1-fpm.sock|fcgi://localhost'
  </FilesMatch>

  <Directory /var/www/nextcloud/>
    Satisfy Any
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews

    <IfModule mod_dav.c>
      Dav off
    </IfModule>
  </Directory>

  ErrorLog /var/log/apache2/nextcloud-error.log
  CustomLog /var/log/apache2/nextcloud-access.log common
</VirtualHost>" > /etc/apache2/sites-available/nextcloud.conf

a2dissite 000-default
a2ensite nextcloud

# Toggle Apache Modules
if [[ $useSSL == 'yes' || $useSSL == 'y' ]]; then
    a2enmod ssl
fi
a2enconf php8.1-fpm
a2enmod rewrite env dir mime 

# Improve Performance
a2enconf php8.1-fpm
a2enmod proxy_fcgi setenvif http2

systemctl restart apache2
echo -e " o  Done.\n"

# MySQL Config
echo "[+] Configuring MySQL..."
mysql -e "CREATE USER '${dbUser}'@'localhost' IDENTIFIED BY '${dbPass}';"
mysql -e "CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
mysql -e "GRANT ALL PRIVILEGES ON nextcloud.* TO '${dbUser}'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"
echo -e " o  Done.\n"

# Download Nextcloud Web Installer
echo "[+] Downloading Nextcloud web installer (setup-nextcloud.php)..."
wget https://download.nextcloud.com/server/installer/setup-nextcloud.php
mv setup-nextcloud.php /var/www/nextcloud/.
echo -e " o  Done.\n"

# Completion
echo "[+] Nextcloud has been configured."
echo " o  Navigate to '${proto}://${serverName}:${serverPort}/setup-nextcloud.php' to finish installation."
