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
service nginx restart

# Install pHp 7.2
add-apt-repository -y ppa:ondrej/php -y
apt update
apt -y install php7.4 php7.4-cli php7.4-gd php7.4-mysql php7.4-pdo php7.4-mbstring php7.4-tokenizer php7.4-bcmath php7.4-xml php7.4-fpm php7.4-curl php7.4-zip
sed -i 's/;cgi\.fix_pathinfo=1/cgi\.fix_pathinfo=0/g' /etc/php/7.4/fpm/php.ini

# Install MariaDB
apt install mariadb-server mariadb-client

# Secure MySQL Install
RandomPass=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')
echo 'Your Random MySQL Password' + $RandomPass
read -p 'Please copy the password and save it for logging into MySQL, Press ENTER To Continue....'

apt install expect

MYSQL_ROOT_PASSWORD=$RandomPass

SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"$MYSQL\r\"
expect \"Change the root password?\"
send \"n\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")

echo "$SECURE_MYSQL"

apt-get -y purge expect

# Create MySQL User for phpMyAdmin
read -p "Please enter your desired MySQL username:  " USER
echo $USER
read -p "Please enter your desired MySQL password:  " PASS
echo $PASS

echo "
CREATE USER '$USER'@'localhost' IDENTIFIED BY '$PASS';
GRANT ALL PRIVILEGES ON *.* TO '$USER'@'localhost' WITH GRANT OPTION;
CREATE USER '$USER'@'%' IDENTIFIED BY '$PASS';
GRANT ALL PRIVILEGES ON *.* TO '$USER'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;" >> commands.sql

mysql < "commands.sql"

# Install phpmyadmin
apt install phpmyadmin
ln -s /usr/share/phpmyadmin /var/www/html/

# Completed
echo 'Complete!'
