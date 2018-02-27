#!/bin/bash

# only removes files that cannot be downloaded anymore (obsolete)
/usr/bin/sudo apt-get autoclean
/usr/bin/sudo apt-get autoremove
/usr/bin/sudo apt-get clean

# resync package index
/usr/bin/sudo apt-get update
/usr/bin/sudo apt-get upgrade

# update + upgrade
/usr/bin/sudo apt-get dist-upgrade
/usr/bin/sudo apt-get -f install
/usr/bin/sudo dpkg --configure -a
