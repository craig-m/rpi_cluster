#!/bin/bash
for ((i=0; i<=254; i++)); do
  /bin/ping -w 1 -c 1 192.168.6.$i | grep -A1 -B1 "1 received";
done
