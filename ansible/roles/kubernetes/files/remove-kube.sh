#!/bin/bash

/usr/bin/sudo kubectl delete node --all
/usr/bin/sudo kubeadm reset

/usr/bin/sudo apt-get -y remove kubeadm kubectl kubernetes-cni kubelet

/usr/bin/sudo rm -rfv -- /etc/kubernetes/

rm -rfv -- $HOME/.kube/

/usr/bin/sudo rm -rfv -- /root/.kube/

rm -rfv -- /etc/apt/sources.list.d/kubernetes.list

rm -rfv -- /opt/cluster/data/.setup-kube
rm -rfv -- /opt/cluster/data/kube_info.txt
rm -rvf -- /opt/cluster/data/kube_joined_cli.txt
