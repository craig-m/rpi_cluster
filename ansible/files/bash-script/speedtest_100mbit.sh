#!/bin/bash

rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}

rpilogit "running speedtest_100mbit.sh";

# do not run this script as root
if [[ root = "$(whoami)" ]]; then
  echo "ERROR: do not run as root";
  exit 1;
fi

/usr/bin/wget -q -O /dev/null -- http://cachefly.cachefly.net/100mb.test;

rpilogit "finished speedtest_100mbit.sh";
