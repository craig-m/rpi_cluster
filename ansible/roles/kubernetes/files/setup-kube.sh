#!/bin/bash

rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}

rpilogit "starting setup-kube.sh"

mkdir -p -v /home/pi/.kube

/usr/bin/sudo cp -i -v -- /etc/kubernetes/admin.conf /home/pi/.kube/config
/usr/bin/sudo chown pi:pi -R /home/pi/.kube/*

/usr/bin/sudo cp -i -v -- /etc/kubernetes/admin.conf /opt/cluster/docker/kubecnf/admin.conf
/usr/bin/sudo chown pi:pi /opt/cluster/docker/kubecnf/admin.conf

/usr/bin/sudo mkdir -pv /etc/cni/net.d

# setup autocomplete in bash into the current shell, bash-completion package should be installed first.
#source <(kubectl completion bash)

# add autocomplete permanently to your bash shell.
echo "source <(kubectl completion bash)" >> ~/.bashrc

touch -f /opt/cluster/data/.setup-kube

rpilogit "finished setup-kube.sh"
