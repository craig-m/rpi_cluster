#!/bin/bash

# a setuid c wrapper for /sbin/reboot

rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}

# test /usr/bin/sudo <cmd> works OK
/usr/bin/sudo id | grep "uid=0(root)" > /dev/null 2>&1 || exit 1;

rpilogit "started reboot_setuid build";

# clean up old
if [ -f reboot_setuid ]; then
	rm -fv -- reboot_setuid
fi

# compile (static linking)
gcc -static -fpic -fpie reboot_setuid.c -o reboot_setuid || exit 1;

# perms
/usr/bin/sudo chown root:root reboot_setuid
/usr/bin/sudo chmod 0755 reboot_setuid

# set setuid
/usr/bin/sudo chmod +s reboot_setuid

# remove check old if exists
if [ -f /opt/cluster/bin/reboot_setuid ]; then
	/usr/bin/sudo chattr -i /opt/cluster/bin/reboot_setuid
	/usr/bin/sudo rm -rv -- /opt/cluster/bin/reboot_setuid
fi

# copy new
/usr/bin/sudo mv -v -- reboot_setuid /opt/cluster/bin/reboot_setuid
/usr/bin/sudo chattr +i /opt/cluster/bin/reboot_setuid

rpilogit "created reboot_setuid";
