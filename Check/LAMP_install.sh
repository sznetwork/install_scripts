#!/bin/sh
# Update package index
apt update
# Install Apache
apt install -y apache2
# Enable and start Apache service
systemctl enable apache2
systemctl start apache2
# Install MySQL (MariaDB)
apt install -y mariadb-server mariadb-client
# Secure MySQL installation
mysql_secure_installation <<EOF

y
password
password
y
y
y
y
EOF
# Install PHP and necessary modules
apt install -y php libapache2-mod-php php-mysql
# Restart Apache to apply changes
if command -v systemctl &> /dev/null; then
    echo "systemctl is available."
    systemctl restart apache2
else
    echo "systemctl is not available."
    service apache2 restart
fi
# Test PHP Processing
echo '<?php phpinfo(); ?>' | sudo tee /var/www/html/phpinfo.php

# Display installation summary
echo ""
echo "============================================"
echo " LAMP Stack Installation Complete"
echo "============================================"
echo "Installed Versions:"
echo " - Apache: $(apache2 -v | head -n 1 | awk '{print $3}')"
echo " - MariaDB: $(mariadb --version | awk '{print $5}')"
echo " - PHP: $(php --version | head -n 1 | awk '{print $2}')"
echo ""
echo "Security Information:"
echo " - MariaDB root password is temporarily set to: password"
echo " - THIS IS NOT SECURE! You must change it immediately!"
echo " - Change password using: mysqladmin -u root -p password newpassword"
echo " - Then update all applications using this password"
echo ""
echo "Test PHP installation by visiting:"
echo "http://your_server_ip/phpinfo.php"
echo "============================================"