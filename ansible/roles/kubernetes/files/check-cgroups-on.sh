#!/bin/bash
# name: check-cgroups-on.sh
# Desc: Small script to check if cgroups are enabled on this host.

CGRPSTATUS=$(cat /proc/cgroups | grep memory | awk {'print $4'})

rpilogit () {
	echo -e "rpicluster: check-cgroups-on.sh $1 \n";
	logger -t rpicluster "check-cgroups-on.sh $1";
}

if [[ 1 = "$CGRPSTATUS" ]]; then
  rpilogit "cgroups enabled";
  exit 0;
else
  rpilogit "cgroups NOT enabled";
  exit 1;
fi
