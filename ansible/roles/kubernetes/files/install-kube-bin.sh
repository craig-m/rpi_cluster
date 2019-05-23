#!/bin/bash

# name: install-kube-bin.sh
# desc: Install a specific version of K8 tools from apt, and then pin them.

rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}


# run as root
if [[ root != "$(whoami)" ]]; then
  echo "Error: requires root";
  exit 1;
fi

hostname=$(hostname)

rpilogit "starting install-kube-bin.sh on ${hostname}"


# Relase notes:
# https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.13.md#kubernetes-113-release-notes



# apt pin to set version
cat <<EOF > /etc/apt/preferences.d/kubebin.conf
Package: /kubeadm/kubelet/kubectl/kubernetes-cni/
Pin: version 1.13.*
Pin-Priority: 1000
EOF

export DEBIAN_FRONTEND=noninteractive;

# apt-cache madison kubeadm | grep "1.13"

# k8 packages
apt-get -q install -y \
	kubeadm \
	kubelet \
	kubectl \
	kubernetes-cni;
if [ $? -eq 0 ]; then
  rpilogit "installed kubeadm tools";
else
  rpilogit "ERROR: apt install of kubeadm failed";
	exit 1;
fi


# lock kubernetes version
apt-mark hold kubeadm kubelet kubectl kubernetes-cni;


# finished
rpilogit "finished install-kube-bin.sh on ${hostname}";
sleep 3s;
touch -f /opt/cluster/docker/kube-installed.txt
