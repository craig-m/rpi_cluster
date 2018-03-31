#!/bin/bash

rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}

rpilogit "starting install-kube.sh"

sleep 1s;

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | /usr/bin/sudo apt-key add -

/usr/bin/sudo touch -f /etc/apt/sources.list.d/kubernetes.list

echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

/usr/bin/sudo apt-get update -q

sleep 3s;

rpilogit "finished install-kube.sh"
