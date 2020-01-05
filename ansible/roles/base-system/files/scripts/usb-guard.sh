#!/bin/bash
#
# The USBGuard software framework helps to protect your computer against rogue USB devices (a.k.a. BadUSB)
# by implementing basic whitelisting and blacklisting capabilities based on device attributes.
#
# https://usbguard.github.io/
#

sudo apt-get install -y usbguard

usbguard generate-policy > /root/usbguard-rules.conf

# vi rules.conf (review/modify the rule set)

sudo install -m 0600 -o root -g root /root/usbguard-rules.conf /etc/usbguard/rules.conf

sudo systemctl restart usbguard