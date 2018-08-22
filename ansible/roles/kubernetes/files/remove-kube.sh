#!/bin/bash
# shutdown cluster and remove all Kube setup

echo "remove all trace of k8";

/usr/bin/sudo kubectl delete node --all
/usr/bin/sudo kubeadm reset -f

/usr/bin/sudo apt-get purge kubeadm kubectl kubernetes-cni kubelet -y

/usr/bin/sudo rm -rfv -- /etc/kubernetes/
/usr/bin/sudo rm -rfv -- /var/lib/kubelet/
/usr/bin/sudo rm -rfv -- /var/lib/etcd/

/usr/bin/sudo rm -rfv -- /home/pi/.kube/
/usr/bin/sudo rm -rfv -- /root/.kube/

/usr/bin/sudo rm -rfv -- /etc/apt/sources.list.d/kubernetes.list

# remove ansible role setup files
rm -rfv -- /opt/cluster/docker/kubecnf/admin.conf
rm -rfv -- /opt/cluster/docker/kubecnf/kube_info.txt
rm -rvf -- /opt/cluster/docker/kubecnf/kube_joined_cli.txt

# Purge all Images + Containers + Networks + Volumes
/usr/bin/sudo docker system prune -a -f

echo "done";
