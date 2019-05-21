#!/bin/bash
# this will enable cgroups in Raspberry Pi cmdline.txt
# I found i needed the cgroup options before "rootwait"

# NOTE: will overwrite /boot/cmdline.txt

rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}

# run as root
if [[ root != "$(whoami)" ]]; then
  echo "Error: requires root";
  exit 1;
fi

rpilogit "starting genbootcmd.sh"

DISKMAIN=$(blkid -o export /dev/mmcblk0p2 | grep "PARTUUID")

BOOTOPS="dwc_otg.lpm_enable=0 console=serial0,115200 console=tty1 root=${DISKMAIN} rootfstype=ext4 cgroup_enable=memory cgroup_memory=1 elevator=deadline fsck.repair=yes rootwait"

echo $BOOTOPS > /boot/cmdline.txt;

rpilogit "finished genbootcmd.sh"
