#!/bin/bash
echo "----------------------------------------------------"
echo " STARTING INSTALLING ZABBIX 7.0 ON DEBIAN 12 "
echo "----------------------------------------------------"
sleep 2
echo ""
echo "----------------------------------------------------"
echo " UPDATING AND UPGRADING "
echo "----------------------------------------------------"
sleep 2
apt update -y
apt upgrade -y
echo ""
echo "----------------------------------------------------"
echo " ADDING ZABBIX USER "
echo "----------------------------------------------------"
sleep 2
addgroup --system --quiet zabbix
adduser --quiet --system --disabled-login --ingroup zabbix --home /var/lib/zabbix --no-create-home zabbix
mkdir -m u=rwx,g=rwx,o= -p /var/lib/zabbix
chown zabbix:zabbix /var/lib/zabbix
echo ""
echo "----------------------------------------------------"
echo " CHANGING REPOSITORY TO UNSTABLE "
echo "----------------------------------------------------"
sleep 2
sed -i '/debian.org.*bookworm/ {
    /bookworm-updates/! {
        /bookworm-security/! s/bookworm/unstable/
    }
}' /etc/apt/sources.list
apt update -y
apt upgrade -y
echo ""
echo "----------------------------------------------------"
echo " INSTALLING REQUIRED PACKAGES "
echo "----------------------------------------------------"
sleep 2
apt install libldap2-dev libopenipmi-dev \
build-essential libsnmp-dev libevent-dev pkg-config \
libpcre3-dev golang libxml2-dev libcurl4-openssl-dev \
apache2 php php-mysql php-gd php-xml php-bcmath php-mbstring php-ldap php-curl \
libssh2-1-dev wget libmariadb-dev htop libmariadb-dev-compat -y
echo ""
echo "----------------------------------------------------"
echo " DOWNLOADING ZABBIX 7.0 SOURCES "
echo "----------------------------------------------------"
sleep 2
wget https://cdn.zabbix.com/zabbix/sources/stable/7.0/zabbix-7.0.0.tar.gz
tar -xvf zabbix-7.0.0.tar.gz
echo ""
echo "----------------------------------------------------"
echo " CONFIGURING, MAKING, INSTALLING "
echo "----------------------------------------------------"
sleep 2
cd /root/zabbix-7.0.0 || { echo "Directory not found! Exiting."; exit 1; }
./configure --enable-server \
           --enable-agent \
           --enable-agent2 \
           --with-mysql \
           --with-net-snmp \
           --with-libcurl \
           --with-libxml2 \
           --with-openssl \
           --with-ssh2 \
           --with-libpcre
echo ""
echo " Zabbix configuration complete."
sleep 5
make install 
echo ""
echo "----------------------------------------------------"
echo " INSTALLING MYSQL "
echo "----------------------------------------------------"
sleep 2
apt install mariadb-server -y
mariadb-secure-installation
echo ""
echo "----------------------------------------------------"
echo " CREATING MYSQL DATABASE AND USER FOR ZABBIX "
echo "----------------------------------------------------"
sleep 2
echo ""
echo " (Script don't accept special symbols in Zabbix user password)"
echo ""
echo -n " Create Zabbix user MySQL password: "
echo ""
stty -echo
read MYSQL_ZABBIX_PASS
stty echo
echo
echo -n " Enter MySQL root password: "
stty -echo
read MYSQL_ROOT_PASS
stty echo
echo
mysql -u root -p"$MYSQL_ROOT_PASS" <<EOF
CREATE DATABASE zabbix CHARACTER SET utf8 COLLATE utf8_bin;
CREATE USER 'zabbix'@'localhost' IDENTIFIED BY '$MYSQL_ZABBIX_PASS';
GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';
FLUSH PRIVILEGES;
EOF
echo ""
echo " MySQL database and user for Zabbix have been created"
echo ""
sleep 2
echo "----------------------------------------------------"
echo " COPING ZABBIX DATA TO MYSQL DATABASE                 "
echo "----------------------------------------------------"
echo ""
echo " Enter Zabbix user MySQL password:            "
echo ""   
mysql -u zabbix -p zabbix < /root/zabbix-7.0.0/database/mysql/schema.sql
echo " Enter Zabbix user MySQL password one more time: "
echo ""
mysql -u zabbix -p zabbix < /root/zabbix-7.0.0/database/mysql/images.sql
echo " Enter Zabbix user MySQL password one more time: "
echo ""
mysql -u zabbix -p zabbix < /root/zabbix-7.0.0/database/mysql/data.sql
echo ""
echo " Zabbix data copied"
echo ""
sleep 2
echo "----------------------------------------------------"
echo " EDITING ZABBIX SERVER CONFIGURATION FILE "
echo "----------------------------------------------------"
echo ""
echo -n " Enter Zabbix user MySQL password: "
stty -echo
read MYSQL_ZABBIX_PASS
stty echo
echo
sed -i "s/# DBPassword=/DBPassword=$MYSQL_ZABBIX_PASS/" /usr/local/etc/zabbix_server.conf
echo "AllowUnsupportedDBVersions=1 " >> /usr/local/etc/zabbix_server.conf
echo ""
sleep 2
echo "----------------------------------------------------"
echo " CREATING ZABBIX SERVER & AGENT SYSTEMD SERVICE  "
echo "----------------------------------------------------"
echo "[Unit]
Description=Zabbix Server
After=syslog.target
After=network.target
After=mysql.service
After=mysqld.service
After=mariadb.service

[Service]
Environment=\"CONFFILE=/usr/local/etc/zabbix_server.conf\"
EnvironmentFile=-/usr/local/sbin/zabbix_server
Type=forking
Restart=on-failure
PIDFile=/run/zabbix/zabbix_server.pid
KillMode=control-group
ExecStart=/usr/local/sbin/zabbix_server -c \$CONFFILE
ExecStop=/bin/sh -c '[ -n \"\$1\" ] && kill -s TERM \"\$1\"' -- \"\$MAINPID\"
RestartSec=10s
TimeoutSec=infinity

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/zabbix-server.service

echo "[Unit]
Description=Zabbix Agent
After=syslog.target
After=network.target

[Service]
Environment=\"CONFFILE=/usr/local/etc/zabbix_agentd.conf\"
EnvironmentFile=-/usr/local/sbin/zabbix_agentd
Type=forking
Restart=on-failure
PIDFile=/run/zabbix/zabbix_agentd.pid
KillMode=control-group
ExecStart=/usr/local/sbin/zabbix_agentd -c \$CONFFILE
ExecStop=/bin/sh -c '[ -n \"\$1\" ] && kill -s TERM \"\$1\"' -- \"\$MAINPID\"
RestartSec=10s
User=zabbix
Group=zabbix

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/zabbix-agent.service
systemctl enable zabbix-server zabbix-agent
systemctl daemon-reload
echo ""
sleep 2
echo "----------------------------------------------------"
echo " CONFIGURING LAMP AND ZABBIX FRONTEND "
echo "----------------------------------------------------"
rm /var/www/html/index.html
cp -r /root/zabbix-7.0.0/ui/* /var/www/html/
chown -R www-data:www-data /var/www/html
sed -i "s/max_execution_time = 30/max_execution_time = 300/" /etc/php/8.2/apache2/php.ini
sed -i "s/memory_limit = 128M/memory_limit = 256M/" /etc/php/8.2/apache2/php.ini
sed -i "s/post_max_size = 8M/post_max_size = 16M/" /etc/php/8.2/apache2/php.ini
sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 16M/" /etc/php/8.2/apache2/php.ini
sed -i "s/max_input_time = 60/max_input_time = 300/" /etc/php/8.2/apache2/php.ini
systemctl restart apache2
echo ""
sleep 2
echo "----------------------------------------------------"
echo " REMOVING UNUSED PACKAGES "
echo "----------------------------------------------------"
apt autoremove -y
echo ""
sleep 2
echo "----------------------------------------------------"
echo " INSTALLATION FINISHED "
echo "----------------------------------------------------"
echo ""
echo " Server will start after machine reboot."
echo ""
echo " Please continue the installation by opening the following URL in your web browser:"
echo " http://$(hostname -I | awk '{print $1}')"
echo ""
read -p "Do you want to restart now? (Y/n): " choice
answer=${answer,,}
if [[ "$answer" == "y" || "$answer" == "Y" || "$answer" == "" ]]; then
echo "Reboot in 5 seconds..."
sleep 5
reboot
else
echo "Reboot canceled."
fi
