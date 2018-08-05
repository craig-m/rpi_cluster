#!/bin/bash

rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}

rpilogit "started fix_apt.sh";

# test /usr/bin/sudo <cmd> works OK
/usr/bin/sudo id | grep "uid=0(root)" > /dev/null 2>&1 || exit 1;

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

rpilogit "finished fix_apt.sh";
