#!/bin/bash


# Setup networking with Weave
# https://www.weave.works/docs/net/latest/kubernetes/kube-addon/

rpilogit () {
	echo -e "rpicluster: init-kube-net.sh $1 \n";
	logger -t rpicluster "init-kube-net.sh $1";
}

sudo -u pi kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')" > /opt/cluster/docker/kubecnf/kube_net.txt
if [ $? -eq 0 ]; then
	rpilogit "kubectl apply networking OK"
	sleep 5m;
else
	rpilogit "kubectl apply networking FAILED"
	exit 1;
fi

touch -f /opt/cluster/docker/kubeinit-net.txt