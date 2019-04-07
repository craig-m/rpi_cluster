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

export DEBIAN_FRONTEND=noninteractive;

apt-get -q install -y \
	kubeadm \
	kubelet \
	kubectl \
	kubernetes-cni;
if [ $? -eq 0 ]; then
  echo "installed kubeadm tools";
else
  rpilogit "apt install of kubeadm failed";
	exit 1;
fi

sleep 120s;

touch -f /opt/cluster/docker/.kubeadm

rpilogit "finished install-kube-bin.sh"
