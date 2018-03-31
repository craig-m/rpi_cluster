#!/bin/bash
# ansible compute -a "/opt/cluster/bin/remove_docker.sh" --become

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

docker system prune -a -f

systemctl stop docker.service
systemctl stop docker.socket

# purge
apt-get remove -y --purge docker-ce

rm -rfv /var/lib/docker/
rm -rfv /var/run/docker/
rm -rfv /etc/docker/
rm -fv /opt/cluster/data/rpi_swarm_init.txt
rm -fv /usr/local/bin/docker-machine
rm -fv /opt/cluster/mysrc/getdocker.sh
rm -rf /opt/cluster/mysrc/docker-gc

rpilogit "removed docker"
