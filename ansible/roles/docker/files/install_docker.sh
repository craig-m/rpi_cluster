#!/bin/bash

rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}

# run as root
if [[ root != "$(whoami)" ]]; then
  echo "Error: requires root";
  exit 1;
fi

rpilogit "installing docker-ce"

cat <<EOF > /etc/apt/sources.list.d/docker.list
deb [arch=armhf] https://download.docker.com/linux/raspbian stretch test
EOF

# to check what versions are available from apt:
# apt-cache madison docker-ce | grep "18.06"

cat <<EOF > /etc/apt/preferences.d/dockerce
Package: docker-ce*
Pin: version 18.06.*
Pin-Priority: 1000
EOF


export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y docker-ce

touch /opt/cluster/docker/.dockerbin

/usr/bin/docker version > /opt/cluster/docker/.dockerbin

rpilogit "docker-ce installed"
