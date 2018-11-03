#!/bin/bash
# ansible compute -a "/opt/cluster/docker/scripts/emove_docker.sh" --become -f 10

# run as root
if [[ root != "$(whoami)" ]]; then
  echo "Error: requires root";
  exit 1;
fi

rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}

rpilogit "removing all traces of docker"

# Purge all Images + Containers + Networks + Volumes
docker system prune -a -f

# stop daemon
systemctl stop docker.service
systemctl stop docker.socket

# purge
apt-get remove -y --purge docker-ce

rm -rfv -- /etc/docker/key.json
rm -rfv -- /var/lib/docker/
rm -rfv -- /var/run/docker/
rm -rfv -- /etc/docker/
rm -fv -- /usr/local/bin/docker-machine
rm -fv -- /opt/cluster/mysrc/getdocker.sh
rm -rfv -- /opt/cluster/mysrc/docker-gc

rpilogit "removed docker"

#rm -rfv /opt/cluster/bin/remove_docker.sh
