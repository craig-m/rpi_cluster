#!/bin/bash

# name: init-kube.sh
# desc: create a K8 master node on a fresh cluster deployment

rpilogit () {
	echo -e "rpicluster: init-kube.sh $1 \n";
	logger -t rpicluster "init-kube.sh $1";
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
rpilogit "starting on ${hostname}";


# pull images
rpilogit "get kube docker images"
kubeadm config images pull
if [ $? -eq 0 ]; then
	rpilogit "pulled images OK"
	sleep 120s;
else
	rpilogit "pulled images FAILED"
	exit 1;
fi


# K8 Init function
k8_clust_init () {
	kubeadm init \
		--ignore-preflight-errors=all \
		--token-ttl=0 | tee > /opt/cluster/docker/kubecnf/kube_info.txt;
}


# update manifest values
k8_img_timeout () {
	# raspberry pi timeout waiting on init:
	# "error execution phase wait-control-plane: couldn't initialize a Kubernetes cluster"
	#
	# 70 minute timeout:
	rpilogit "update timeout values in manifests"
	sed -i 's/failureThreshold:: [0-9]\+/failureThreshold:: 15/' /etc/kubernetes/manifests/*.yaml
	sed -i 's/initialDelaySeconds: [0-9]\+/initialDelaySeconds: 2400/' /etc/kubernetes/manifests/*.yaml
	sed -i 's/timeoutSeconds: [0-9]\+/timeoutSeconds: 2400/' /etc/kubernetes/manifests/*.yaml
}


# check we have token
k8_token_check () {
	tail -n5 /opt/cluster/docker/kubecnf/kube_info.txt | grep --silent -e kubeadm -e token -e discovery -e hash
}

# adjust timeouts
k8_img_timeout;


# Try Init of k8 master node
rpilogit "kubeadm master init starting"
k8_clust_init;


# check we have the token
k8_token_check;


# test cluster init
if [ $? -eq 0 ]; then

	# init success
	rpilogit "kubeadm master init ran OK";

else

	# init failure
	rpilogit "kubeadm init FAILED - try again";

	# adjust timeouts
	k8_img_timeout;

	# try init again
	k8_clust_init;

	# check we have the token
	k8_token_check;
	
	# test cluster init
	if [ $? -eq 0 ]; then

		# init success
		rpilogit "kubeadm master init ran OK 2nd try"

	else

		rpilogit "kubeadm master init FAILED 2nd try"
		exit 1;

	fi

fi


chown -v pi:pi /opt/cluster/docker/kubecnf/kube_info.txt

tail -n5 /opt/cluster/docker/kubecnf/kube_info.txt | grep -e kubeadm -e token -e discovery -e hash > /opt/cluster/docker/kubecnf/k8_rpi_join.sh

chown -v pi:pi /opt/cluster/docker/kubecnf/k8_rpi_join.sh

rpilogit "finished on $hostname"

exit 0;
