#!/bin/bash

# max temp
temp_max="55"

# get temp
temp_cur=$(/opt/vc/bin/vcgencmd measure_temp | cut -c 6-7)

# check
if [ $temp_max -gt $temp_cur ]; then
  echo "temp ok"
  true;
else
  echo "too hot"
  false
fi
