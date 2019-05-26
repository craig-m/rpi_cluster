#!/bin/bash

# name: install-kube-bin.sh
# desc: Install a specific version of K8 tools from apt, and then pin them.

rpilogit () {
	echo -e "rpicluster: install-kube-bin.sh $1 \n";
	logger -t rpicluster "install-kube-bin.sh $1";
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
# cat <<EOF > /etc/apt/preferences.d/kubebin.conf
# Package: kube*
# Pin: version 1.13.*
# Pin-Priority: 1000
# EOF

ls -la /etc/apt/preferences.d/kubebin.conf


export DEBIAN_FRONTEND=noninteractive;

# apt-cache madison kubeadm | grep "1.13"

# k8 packages
apt-get -q install -y \
	kubeadm=1.13.6-00 \
	kubelet=1.13.6-00 \
	kubectl=1.13.6-00 \
	kubernetes-cni;
if [ $? -eq 0 ]; then
  rpilogit "installed kubeadm tools";
else
  rpilogit "ERROR: apt install of kubeadm failed";
	exit 1;
fi


# lock kubernetes version
apt-mark hold kubeadm kubelet kubectl kubernetes-cni;


# kubeadm version info
/usr/bin/kubeadm version
if [ $? -eq 0 ]; then
	echo "kubeadm executes OK";
else
	rpilogit "could NOT exec kubeadm"
	exit 1;
fi


# finished
rpilogit "finished install-kube-bin.sh on ${hostname}";
sleep 3s;
touch -f /opt/cluster/docker/kube-installed.txt
