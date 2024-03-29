#!/bin/bash

data=( `ps aux | grep -i dropbear | awk '{print $2}'`);
echo "-----------------------------------------";
echo "------------ Dropbear prisijungia -------------";
echo "-----------------------------------------";

for PID in "${data[@]}"
do
	#echo "check $PID";
	NUM=`cat /var/log/secure | grep -i dropbear | grep -i "Password auth succeeded" | grep "dropbear\[$PID\]" | wc -l`;
	USER=`cat /var/log/secure | grep -i dropbear | grep -i "Password auth succeeded" | grep "dropbear\[$PID\]" | awk '{print $10}'`;
	IP=`cat /var/log/secure | grep -i dropbear | grep -i "Password auth succeeded" | grep "dropbear\[$PID\]" | awk '{print $12}'`;
	if [ $NUM -eq 1 ]; then
		echo "$PID - $USER - $IP";
	fi
done
echo "-----------------------------------------";

data=( `ps aux | grep "\[priv\]" | sort -k 72 | awk '{print $2}'`);

echo "------------ OpenSSH prisijungia --------------";
echo "-----------------------------------------";
for PID in "${data[@]}"
do
        #echo "check $PID";
        NUM=`cat /var/log/secure | grep -i sshd | grep -i "Accepted password for" | grep "sshd\[$PID\]" | wc -l`;
        USER=`cat /var/log/secure | grep -i sshd | grep -i "Accepted password for" | grep "sshd\[$PID\]" | awk '{print $9}'`;
        IP=`cat /var/log/secure | grep -i sshd | grep -i "Accepted password for" | grep "sshd\[$PID\]" | awk '{print $11}'`;
        if [ $NUM -eq 1 ]; then
                echo "$PID - $USER - $IP";
        fi
done

echo "Norėdami sunaikinti vartotojo prisijungimą, naudokite komandą  ";
echo "kill -9 (nomerid)                        ";
echo "pvz : kill -9 28651 ";
echo "-----------------------------------------";
echo "---------------- Gatyto  ---------------";
echo "------------- www.R&M.com  ------------";
echo "-----------------------------------------";
