#!/bin/bash
#Script auto test useruj SSH
#vienos dienos 

Login=gatyto-`</dev/urandom tr -dc X-Z0-9 | head -c4`
masaaktif="1"
Pass=`</dev/urandom tr -dc a-f0-9 | head -c9`
IP=`dig +short myip.opendns.com @resolver1.opendns.com`
useradd -e `date -d "$masaaktif days" +"%Y-%m-%d"` -s /bin/false -M $Login
echo -e "$Pass\n$Pass\n"|passwd $Login &> /dev/null
echo -e "Host: $IP" 
echo -e "Port: 22, 80, 8080"
echo -e "Username: $Login "
echo -e "Password: $Pass\n"
echo -e ""
echo -e "Ši sąskaita aktyvi bus tik 1 dieną"
echo -e "=================================="
