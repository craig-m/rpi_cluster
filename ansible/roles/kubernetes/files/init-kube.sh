#!/bin/bash

# name: init-kube.sh
# desc: create a K8 master node on a fresh cluster deployment

rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}

# run as root
if [[ root != "$(whoami)" ]]; then
  echo "Error: requires root";
  exit 1;
fi

if [ -f /opt/cluster/docker/kubeinit.txt ]; then
	rpilogit "ERROR: already ran k8 init scripts";
	exit 1;
fi

hostname=$(hostname)
rpilogit "starting init-kube.sh on ${hostname}";


rpilogit "get kube docker images"
kubeadm config images pull
if [ $? -eq 0 ]; then
  rpilogit "pulled images OK"
	sleep 120s;
else
	rpilogit "pulled images FAILED"
	exit 1;
fi

# reset
#kubeadm reset -f

rpilogit "start kube init"

date -u

# raspberry pi timeout waiting on init:
# "error execution phase wait-control-plane: couldn't initialize a Kubernetes cluster"

# 70 minute timeout:
sed -i 's/failureThreshold:: [0-9]\+/failureThreshold:: 15/' /etc/kubernetes/manifests/*.yaml
sed -i 's/initialDelaySeconds: [0-9]\+/initialDelaySeconds: 2400/' /etc/kubernetes/manifests/*.yaml
sed -i 's/timeoutSeconds: [0-9]\+/timeoutSeconds: 2400/' /etc/kubernetes/manifests/*.yaml


# Init cluster!
kubeadm init \
	--ignore-preflight-errors=all \
	--token-ttl=0 \
	| tee > /opt/cluster/docker/kubecnf/kube_info.txt


# test init
if [ $? -eq 0 ]; then
	# init success
	rpilogit "kubeadm init ran OK"

	chown pi:pi /opt/cluster/docker/kubecnf/kube_info.txt
else
	# init failure -
	rpilogit "kubeadm init FAILED"
	exit 1;
fi


rpilogit "pausing"
sleep 5m;


# for kube admin
mkdir -p -v /home/pi/.kube
cp /etc/kubernetes/admin.conf /home/pi/admin.conf
cp -i -v -- /etc/kubernetes/admin.conf /opt/cluster/docker/kubecnf/admin.conf
chown pi:pi /opt/cluster/docker/kubecnf/admin.conf
mkdir -pv /etc/cni/net.d
echo "source <(kubectl completion bash)" >> ~/.bashrc


sudo -u pi kubectl config view


# Finished!

date -u

touch -f /opt/cluster/docker/kubeinit.txt

rpilogit "finished init-kube.sh on $hostname";
