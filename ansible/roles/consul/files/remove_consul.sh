#!/bin/bash
# ansible compute -a "/opt/cluster/bin/remove_consul.sh" --become

# run as root
if [[ root != "$(whoami)" ]]; then
  echo "Error: requires root";
  exit 1;
fi

rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}

rpilogit "removing all traces of consul"

systemctl stop consul
systemctl disable consul
rm -vf /etc/systemd/system/consul.service
systemctl daemon-reload

#rm -vrf /opt/cluster/mysrc/consul/
rm -vrf /opt/consul/
rm -vf /usr/local/sbin/consul

userdel consul

rpilogit "removed consul"
