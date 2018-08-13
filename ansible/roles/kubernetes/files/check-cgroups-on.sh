#!/bin/bash

CGRPSTATUS=$(cat /proc/cgroups | grep memory | awk {'print $4'})

if [[ 1 = "$CGRPSTATUS" ]]; then
  echo "cgroups enabled";
else
  echo "cgroups NOT enabled";
  exit 1;
fi
