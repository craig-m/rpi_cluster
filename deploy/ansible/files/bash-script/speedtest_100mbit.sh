#!/bin/bash

rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}

rpilogit "running speedtest_100mbit.sh";

wget -O /dev/null http://cachefly.cachefly.net/100mb.test
