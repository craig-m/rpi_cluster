#!/bin/bash
# Disable systems Swap

# log
rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}

rpilogit "started disable-swap.sh";

# test /usr/bin/sudo <cmd> works OK
/usr/bin/sudo id | grep "uid=0(root)" > /dev/null 2>&1 || exit 1;

/usr/bin/sudo dphys-swapfile swapoff

/usr/bin/sudo dphys-swapfile uninstall

/usr/bin/sudo update-rc.d dphys-swapfile remove

touch -f /opt/cluster/data/swap_disabled
echo "swap is off" > /opt/cluster/data/swap_disabled

rpilogit "finished disable-swap.sh";
