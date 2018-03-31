#!/bin/bash

rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}

rpilogit "running speedtest_100mbit.sh";

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

wget -O /dev/null http://cachefly.cachefly.net/100mb.test

rpilogit "finished speedtest_100mbit.sh";
