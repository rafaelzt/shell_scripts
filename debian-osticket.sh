#!/bin/bash

export DOMAIN=osticket
export DOMAIN_FOLDER=/var/www/html/$DOMAIN

sudo apt update -y
sudo apt install -y vim curl wget

# Apache2
sudo apt install -y apache2
sudo mkdir -p $DOMAIN_FOLDER
sudo chown -R $USER:$USER $DOMAIN_FOLDER

echo "<VirtualHost *:80>" | sudo tee -a /etc/apache2/sites-available/$DOMAIN.conf
echo "  ServerAdmin     webmaster@localhost" | sudo tee -a /etc/apache2/sites-available/$DOMAIN.conf
echo "  ServerName      $DOMAIN" | sudo tee -a /etc/apache2/sites-available/$DOMAIN.conf
echo "  DocumentRoot    $DOMAIN_FOLDER" | sudo tee -a /etc/apache2/sites-available/$DOMAIN.conf
echo "  ErrorLog        ${APACHE_LOG_DIR}/error.log" | sudo tee -a /etc/apache2/sites-available/$DOMAIN.conf
echo "  CustomLog       ${APACHE_LOG_DIR}/access.log  combined" | sudo tee -a /etc/apache2/sites-available/$DOMAIN.conf
echo "</VirtualHost>" | sudo tee -a /etc/apache2/sites-available/$DOMAIN.conf

sudo a2ensite $DOMAIN.conf
sudo a2dissite 000-default.conf

# PHP 8.2
sudo apt install -y apt-transport-https ca-certificates lsb-release
sudo wget -O php-repo.sh https://packages.sury.org/php/README.txt
sudo chmod +x php-repo.sh
sudo ./php-repo.sh
sudo rm php-repo.sh

sudo apt update -y
sudo apt install -y php8.2 libapache2-mod-php8.2
sudo apt install -y php8.2-{cgi,mysql,curl,imap,intl,apcu,xsl,gd,common,xml,zip,soap,bcmath,mbstring,imagick}
sudo a2enmod php8.2

# MySQL/MariaDB
sudo apt install -y mariadb-server
sudo mysql_secure_installation

echo -e "CREATE DATABASE osticket_db;\nGRANT ALL PRIVILEGES ON osticket_db.* TO osticket_user@localhost IDENTIFIED BY 'Str0ngP@ss';\nFLUSH PRIVILEGES;\nQUIT;\n"
sudo mysql -u root -p

# OsTicket
wget -O osticket.zip https://github.com/osTicket/osTicket/releases/download/v1.18/osTicket-v1.18.zip
sudo unzip osTicket.zip -d $DOMAIN_FOLDER
sudo cp /var/www/html/osTicket/upload/include/ost-sampleconfig.php /var/www/html/osTicket/upload/include/ost-config.php
sudo chown -R www-data:www-data $DOMAIN_FOLDER
sudo chmod 755 -R $DOMAIN_FOLDER
