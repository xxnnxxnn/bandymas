#!/bin/sh
PFILE=/var/run/dropbear.pid
if [ -e "${PFILE}" ] && (ps -p $(cat ${PFILE}) > /dev/null); then
        echo "procesas pradetas..."
        service dropbear status
        exit
else
        echo "procesas neveikia, paleidžiamas iš naujo..."
        service dropbear restart
        exit 0
fi
