#!/bin/bash

CGRPSTATUS=$(cat /proc/cgroups | grep memory | awk {'print $4'})

rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}

if [[ 1 = "$CGRPSTATUS" ]]; then
  rpilogit "cgroups enabled";
  exit 0;
else
  rpilogit "cgroups NOT enabled";
  exit 1;
fi
