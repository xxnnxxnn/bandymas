#!/bin/bash
#Script paleisti autokill cron by Gatyto

mkdir -p "$HOME/tmp"
PIDFILE="$HOME/tmp/autokill.pid"

if [ -e "${PIDFILE}" ] && (ps -u $(whoami) -opid= |
                           grep -P "^\s*$(cat ${PIDFILE})$" &> /dev/null); then
  echo "Jau veikia."
  exit 99
fi

/usr/bin/autokill > $HOME/tmp/autokill.log &

echo $! > "${PIDFILE}"
chmod 644 "${PIDFILE}"
