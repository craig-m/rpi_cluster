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

rpilogit "starting install-kube-bin.sh"


cat <<EOF > /etc/apt/preferences.d/kubebin
Package: /kubeadm/kubelet/kubectl/kubernetes-cni/
Pin: version 1.10.*
Pin-Priority: 1000
EOF


apt-get install -y \
	kubeadm \
	kubelet \
	kubectl \
	kubernetes-cni;

sleep 30s;

rpilogit "finished install-kube-bin.sh"
