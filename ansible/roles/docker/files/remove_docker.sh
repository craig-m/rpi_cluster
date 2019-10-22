#!/bin/bash
#
# clean up docker a installation
#
# Usage:
# 
#   ansible compute -a "/opt/cluster/docker/scripts/remove_docker.sh" --become -f 10

# run as root
if [[ root != "$(whoami)" ]]; then
	echo "Error: requires root";
	exit 1;
fi

rpilogit () {
	echo -e "rpicluster: remove_docker.sh $1 \n";
	logger -t rpicluster "remove_docker.sh $1";
}

rpilogit "started"

# Purge all Images + Containers + Networks + Volumes
if [ -f /usr/bin/docker ]; then
	docker system prune -a -f >/dev/null
fi

# stop daemon
systemctl stop docker.service
systemctl stop docker.socket

# purge
apt-get -y -q purge docker-ce --allow-change-held-packages || exit 1

rm -fv -- /etc/apt/sources.list.d/docker.list
rm -fv -- /etc/apt/preferences.d/docker-ce
rm -rfv -- /etc/docker/key.json
rm -rfv -- /var/lib/docker/
rm -rfv -- /var/run/docker/
rm -rfv -- /etc/docker/
rm -fv -- /usr/local/bin/docker-machine
rm -fv -- /opt/cluster/mysrc/getdocker.sh
rm -rfv -- /opt/cluster/mysrc/docker-gc

rm -rfv -- /opt/cluster/docker/docker-installed.txt

rpilogit "finished"

#rm -rfv /opt/cluster/bin/remove_docker.sh
