#!/bin/bash

# a setuid c wrapper for /sbin/reboot

rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}

# clean up old
if [ -f reboot_setuid ]; then
	rm -fv reboot_now
fi

# compile (static linking)
gcc -static -fpic -fpie reboot_setuid.c -o reboot_setuid

# perms
/usr/bin/sudo chown root reboot_setuid
/usr/bin/sudo chmod 0755 reboot_setuid

# set setuid
/usr/bin/sudo chmod +s reboot_setuid

# remove check old if exists
if [ -f /opt/cluster/bin/reboot_setuid ]; then
	/usr/bin/sudo chattr -i /opt/cluster/bin/reboot_setuid
	/usr/bin/sudo rm -rv /opt/cluster/bin/reboot_setuid
fi

# copy new
/usr/bin/sudo mv -v reboot_setuid /opt/cluster/bin/reboot_setuid
/usr/bin/sudo chattr +i /opt/cluster/bin/reboot_setuid

rpilogit "created reboot_setuid";
