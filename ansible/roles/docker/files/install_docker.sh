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

rpilogit "starting install_docker.sh"


cat <<EOF > /etc/apt/sources.list.d/docker.list
deb [arch=armhf] https://download.docker.com/linux/raspbian stretch test
EOF


# to check what versions are available from apt:
# apt-cache madison docker-ce | grep "18.06"

cat <<EOF > /etc/apt/preferences.d/docker.conf
Package: docker-ce
Pin: version 18.09.*
Pin-Priority: 1000
EOF

# create a temp dir
dock_inst_tmpdir=$(mktemp -d)

# get docker gpg key
wget https://download.docker.com/linux/debian/gpg -O ${dock_inst_tmpdir}/dock.gpg;
if [ $? -eq 0 ]; then
  echo "downloaded gpg key ok";
else
  rpilogit "FAILED to download docker deiban gpg key"
	exit 1;
fi

# get filesum
checkpgpkey=$(sha256sum ${dock_inst_tmpdir}/dock.gpg | awk {'print $1'})

# check sum of file before adding
if [ $checkpgpkey = "1500c1f56fa9e26b9b8f42452a553675796ade0807cdce11975eb98170b3a570" ]; then
	echo "GPG key OK"
	cat ${dock_inst_tmpdir}/dock.gpg | apt-key add -
else
	rpilogit "BAD GPG FILESUM"
	exit 1;
fi

apt-key fingerprint 0EBFCD88 | grep "9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88"
if [ $? -eq 0 ]; then
  echo "key fingerprint ok";
else
  rpilogit "BAD key fingerprint"
	exit 1;
fi

export DEBIAN_FRONTEND=noninteractive

apt-get -q update

apt-get -q install -y docker-ce
if [ $? -eq 0 ]; then
  rpilogit "docker installed";
else
  rpilogit "error installing docker"
	exit 1;
fi

sleep 3s;

/usr/bin/docker version > /opt/cluster/docker/docker-installed.txt
if [ $? -eq 0 ]; then
	rpilogit "docker-ce installed"
else
  rpilogit "error docker not executing"
	exit 1;
fi


# lock docker version
apt-mark hold docker-ce


rpilogit "finished install_docker.sh"
