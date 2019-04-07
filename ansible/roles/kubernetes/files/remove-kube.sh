#!/bin/bash
# remove-kube.sh
# shutdown cluster, and destroyy all Kube setup.

rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}

rpilogit "starting remove-kube.sh"

/usr/bin/sudo kubeadm reset -f
sleep 10s;

/usr/bin/sudo apt-get -q purge -y \
	kubeadm \
	kubectl \
	kubernetes-cni \
	kubelet;
sleep 10s;

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
/usr/bin/sudo rm -rvf -- /opt/cluster/docker/kubecnf/kube_net.txt

/usr/bin/sudo rm -rvf -- /opt/cluster/docker/.kubeadm
/usr/bin/sudo rm -rvf -- /opt/cluster/docker/.kubeinit

# Purge all Images + Containers + Networks + Volumes
docker system prune -a -f >/dev/null

/usr/bin/sudo rm -rfv -- /var/lib/kubelet

# remove etcd
/usr/bin/sudo rm -rfv -- /var/lib/etcd

# remove weave
/usr/bin/sudo rm -rfv -- /etc/cni/
/usr/bin/sudo rm -rfv -- /opt/cni/

# done
rpilogit "finished remove-kube.sh"
