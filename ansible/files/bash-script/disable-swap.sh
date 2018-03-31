#!/bin/bash
# Disable Swap

# log
rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}

rpilogit "started disable-swap.sh";

/usr/bin/sudo dphys-swapfile swapoff

/usr/bin/sudo dphys-swapfile uninstall

/usr/bin/sudo update-rc.d dphys-swapfile remove

touch -f /opt/cluster/data/swap_disabled
echo "swap is off" > /opt/cluster/data/swap_disabled

rpilogit "finished disable-swap.sh";
