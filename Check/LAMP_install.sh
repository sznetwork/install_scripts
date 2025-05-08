#!/bin/sh
echo $(Script not tested.)
# Update package index
apt update
# Install Apache
apt install -y apache2
# Enable and start Apache service
systemctl enable apache2
systemctl start apache2
# Install MySQL
apt install -y mysql-server
apt install -y mysql-common
# Secure MySQL installation
mysql_secure_installation
# Install PHP and necessary modules
apt install -y php libapache2-mod-php php-mysql
# Restart Apache to apply changes
if command -v systemctl &> /dev/null; then
    echo $(systemctl is available.)
    systemctl restart apache2
else
    echo $(systemctl is not available.)
    service apache2 restart
fi
# Test PHP Processing
echo $(<?php phpinfo(); ?>) | sudo tee /var/www/html/phpinfo.php