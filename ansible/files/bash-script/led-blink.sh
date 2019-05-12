#!/bin/bash
# R-Pi LED blink mode

rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}

# test /usr/bin/sudo <cmd> works OK
/usr/bin/sudo id | grep "uid=0(root)" > /dev/null 2>&1 || exit 1;

rpilogit "starting led-blink.sh";

/usr/bin/sudo modprobe ledtrig_heartbeat
/usr/bin/sudo sh -c "echo heartbeat >/sys/class/leds/led0/trigger"

sleep 10;

# return R-Pi LED to default trigger
/usr/bin/sudo sh -c "echo mmc0 >/sys/class/leds/led0/trigger"

rpilogit "finished led-blink.sh";
