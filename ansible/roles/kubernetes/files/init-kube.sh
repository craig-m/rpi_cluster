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

echo "start kube init"
kubeadm init --ignore-preflight-errors=all --token-ttl=0 --skip-phases --token=t3stt0okenDEV mark-control-plane | tee > /opt/cluster/docker/kubecnf/kube_info.txt
if [ $? -eq 0 ]; then
  rpilogit "kubeadm init ran OK"
	sleep 120s;
else
	rpilogit "kubeadm init FAILED - trying again"
	sed -i 's/initialDelaySeconds: [0-9]\+/initialDelaySeconds: 180/' /etc/kubernetes/manifests/kube-apiserver.yaml
	kubeadm init --ignore-preflight-errors=all --token-ttl=0 --skip-phases --token=t3stt0okenDEV mark-control-plane | tee > /opt/cluster/docker/kubecnf/kube_info.txt
fi


# Setup networking with Weave
# https://www.weave.works/docs/net/latest/kubernetes/kube-addon/
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')" > /opt/cluster/docker/kubecnf/kube_net.txt
if [ $? -eq 0 ]; then
  rpilogit "kubectl apply networking OK"
	sleep 120s;
else
	rpilogit "kubectl apply networking FAILED"
	exit 1;
fi


touch -f /opt/cluster/docker/.kubeinit

rpilogit "finished init-kube.sh"
