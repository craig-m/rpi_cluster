#!/bin/bash
#
# https://www.raspberrypi.org/documentation/linux/kernel/building.md

rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}

cd /opt/cluster/mysrc/

rpilogit "cloning linux kernel source ";

git clone --depth=1 https://github.com/raspberrypi/linux

# for V3
cd linux
KERNEL=kernel7
make bcm2709_defconfig

/usr/bin/distcc-pump make zImage modules dtbs -j4 CC="distcc gcc -std=gnu99"
#sudo make modules_install
#sudo cp -- arch/arm/boot/dts/*.dtb /boot/
#sudo cp -- arch/arm/boot/dts/overlays/*.dtb* /boot/overlays/
#sudo cp arch/arm/boot/dts/overlays/README /boot/overlays/
#sudo cp arch/arm/boot/zImage /boot/$KERNEL.img
