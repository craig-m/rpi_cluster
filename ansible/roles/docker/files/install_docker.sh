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

#cat <<EOF > /etc/apt/preferences.d/dockerce
#Package: docker-ce*
#Pin: version 18.06.*
#Pin-Priority: 1000
#EOF


curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
apt-key fingerprint 0EBFCD88

export DEBIAN_FRONTEND=noninteractive

apt-get update

apt-get install -y docker-ce

if [ $? -eq 0 ]; then
  echo "docker installed";
else
  echo "error installing docker"
	exit 1;
fi


/usr/bin/docker version > /opt/cluster/docker/.dockerbin || exit 1;

touch /opt/cluster/docker/.dockerbin

rpilogit "docker-ce installed"
