#!/bin/bash
for i in {1..254}; do ping -w 1 -c 1 192.168.6.$i | grep -A1 -B1 "1 received"; done
