#!/bin/bash

DISKMAIN=$(blkid -o export /dev/mmcblk0p2 | grep "PARTUUID")

BOOTOPS="dwc_otg.lpm_enable=0 console=serial0,115200 console=tty1 root=${DISKMAIN} rootfstype=ext4 cgroup_enable=memory cgroup_memory=1 elevator=deadline fsck.repair=yes rootwait"

echo $BOOTOPS > /boot/cmdline.txt;
