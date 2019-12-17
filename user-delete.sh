#!/bin/bash
#Script istrinti useri

read -p "Userio vardas : " Pengguna

if getent passwd $Pengguna > /dev/null 2>&1; then
        userdel $Pengguna
        echo -e "Useris $Pengguna buvo istrintas."
else
        echo -e "DEMESIO: Useris $Pengguna tokio nera."
fi
