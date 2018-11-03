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

rpilogit "starting init-kube.sh"


# get kube docker images
kubeadm config images pull

sleep 10s;

# init
kubeadm init --ignore-preflight-errors=all | tee > /opt/cluster/docker/kubecnf/kube_info.txt

sleep 60s;

# Setup networking with Weave
# https://www.weave.works/docs/net/latest/kubernetes/kube-addon/
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')" > /opt/cluster/docker/kubecnf/kube_net.txt

sleep 30s;

rpilogit "finished init-kube.sh"
