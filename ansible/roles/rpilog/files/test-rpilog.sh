#!/bin/bash

# check rpilog ansible role has setup the host properly.


rpilogit () {
	echo -e "rpicluster: $script_name $1 \n";
	logger -t rpicluster "$script_name $1";
}


scriptname=$(basename -- "$1")
hostname=$(hostname)
test_token=$(uuidgen)

rpilogit "${scriptname} checking rpilog on ${hostname}";
rpilogit "${scriptname} looking for token: ${test_token}";

grep --silent "${test_token}" /var/log/rpicluster.log

if [ $? -eq 0 ]; then
	rpilogit "${scriptname} test passed"
    true
    exit
else
    rpilogit "${scriptname} ERROR test failed"
    exit 1
fi