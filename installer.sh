#!/bin/bash
# LEMP Install Script

# Must be root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Remove conflicting programs
apt purge apache*
apt purge php*
apt purge mysql*

# Install Nginx
apt install nginx
wget https://pastebin.com/raw/ih3f011P
mv ih3f011P default
mv default /etc/nginx/sites-available/default
service restart nginx

# Install pHp 7.2
add-apt-repository -y ppa:ondrej/php -y
apt update
apt -y install php7.2 php7.2-cli php7.2-gd php7.2-mysql php7.2-pdo php7.2-mbstring php7.2-tokenizer php7.2-bcmath php7.2-xml php7.2-fpm php7.2-curl php7.2-zip
sed -i 's/;cgi\.fix_pathinfo=1/cgi\.fix_pathinfo=0/g' /etc/php/7.2/fpm/php.ini

# Install MariaDB
apt install mariadb-server mariadb-client

# Secure MySQL Install
