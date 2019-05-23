#!/bin/bash

# name: install-kube-apt.sh
# desc: setup apt source and install GPG key - then update. 
# This does not install any packages.

rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}

# run as root
if [[ root != "$(whoami)" ]]; then
  echo "Error: requires root";
  exit 1;
fi

rpilogit "starting install-kube.sh"

sleep 1s;

# create a temp dir
kube_inst_tmpdir=$(mktemp -d)

# get kube gpg key
wget https://packages.cloud.google.com/apt/doc/apt-key.gpg -O ${kube_inst_tmpdir}/kubeapt.gpg;
if [ $? -eq 0 ]; then
  echo "downloaded key";
else
  rpilogit "could NOT download key"
	exit 1;
fi

# get filesum
checkpgpkey=$(sha256sum ${kube_inst_tmpdir}/kubeapt.gpg | awk {'print $1'})

# check filesum
if [ $checkpgpkey = "226ba1072f20e4ff97ee4f94e87bf45538a900a6d9b25399a7ac3dc5a2f3af87" ]; then
	echo "GPG key OK"
	cat ${kube_inst_tmpdir}/kubeapt.gpg | apt-key add -
else
	rpilogit "BAD GPG FILESUM"
	exit 1;
fi

apt-key fingerprint gc-team@google.com | grep "54A6 47F9 048D 5688 D7DA  2ABE 6A03 0B21 BA07 F4FB"
if [ $? -eq 0 ]; then
  echo "key fingerprint ok";
else
  rpilogit "BAD key fingerprint"
	exit 1;
fi

/usr/bin/sudo touch -f /etc/apt/sources.list.d/kubernetes.list

echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | /usr/bin/sudo tee /etc/apt/sources.list.d/kubernetes.list

/usr/bin/sudo apt-get -q update

sleep 1s;

rpilogit "finished install-kube.sh"
