## Simple scripts to install software

 1. **DUCO**
#### *sh* scripts to automatically install Duino coin miner
If running by *regular user*:<br>
`sudo chmod +x install_duco.sh`
<br>
`sudo ./install_duco.sh`
<br>
*root* user:
<br>
`sudo chmod +x install_duco.sh`
<br>
`sudo ./install_duco.sh`

- **install_duco.sh** - Duino coin miner installer on Debian based distrto.
- **install_duco.sh** - Duino coin miner on installer Debian based distrto with fasthash support.
- **install_duco_termux.sh** - Duino coin miner installer on Termux (no fasthash support).

---
2. **Debian**
#### *sh* scripts to install some apps or make changes in system
Run example as *root*:
<br>
`chmod +x add_sudo.sh`
<br>
`./add_sudo.sh`
- **add_sudo.sh** - Ads desired user to sudo users.
- **LAMP_install.sh** - Installs Apache MariaDB PHP stack.

---
3. **Zabbix**
#### *sh* scripts to compile and install Zabbix
Run example as *root*:
<br>
`chmod +x compile_zabbix7.0.sh`
<br>
`./compile_zabbix7.0.sh`
- **compile_zabbix7.0.sh** - Compile and install Zabbix 7.0 on 32 bit (Tested on Debian 12 32 bit) on other systems not tested.