#!/bin/bash
#Script sukurti Useri SSH

read -p "Username : " Login
read -p "Password Baru : " Pass
read -p "Penambahan Masa Aktif (skaicius): " masaaktif
userdel $Login
useradd -e `date -d "$masaaktif days" +"%Y-%m-%d"` -s /bin/false -M $Login
exp="$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')"
echo -e "$Pass\n$Pass\n"|passwd $Login &> /dev/null
echo -e "--------------------------------"

echo -e "Paskyra buvo pratęsta iki $exp"
echo -e "Slaptažodis buvo pakeistas $Pass"
echo -e "==========================="
