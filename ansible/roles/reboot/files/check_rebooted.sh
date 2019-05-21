#!/bin/bash
# name: check_rebooted.sh
# desc: check our uptime and alert if greater than 10 minutes.

cur_up=$(awk '{print $0/60;}' /proc/uptime)

if [ $(echo "$cur_up < 10" | bc) -ne 0  ];
then
  echo "ok";
  true;
else
  echo "ERROR";
  false;
fi
