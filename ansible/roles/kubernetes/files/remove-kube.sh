#!/bin/bash
# remove-kube.sh
# shutdown cluster, and destroyy all Kube setup.

rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}

rpilogit "starting remove-kube.sh"

kubeadm reset -f
sleep 5s;

/usr/bin/sudo apt-get purge kubeadm kubectl kubernetes-cni kubelet -y
sleep 5s;

/usr/bin/sudo rm -rfv -- /etc/kubernetes/
/usr/bin/sudo rm -rfv -- /var/lib/kubelet/
/usr/bin/sudo rm -rfv -- /var/lib/etcd/

/usr/bin/sudo rm -rfv -- /home/pi/.kube/
/usr/bin/sudo rm -rfv -- /root/.kube/

/usr/bin/sudo rm -rfv -- /etc/apt/sources.list.d/kubernetes.list

# remove ansible role setup files
/usr/bin/sudo rm -rfv -- /opt/cluster/docker/kubecnf/admin.conf
/usr/bin/sudo rm -rfv -- /opt/cluster/docker/kubecnf/kube_info.txt
/usr/bin/sudo rm -rvf -- /opt/cluster/docker/kubecnf/kube_joined_cli.txt

# Purge all Images + Containers + Networks + Volumes
docker system prune -a -f >/dev/null

# done
rpilogit "finished remove-kube.sh"
sleep 2s;
