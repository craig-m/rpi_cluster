#!/bin/bash#
# clean up our k8 installation
#
# Usage:
# 
#   ansible compute -a "/opt/cluster/docker/scripts/remove-kube.sh" --become -f 10

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

/usr/bin/sudo rm -rfv -- /etc/apt/preferences.d/kubebin
/usr/bin/sudo rm -rfv -- /etc/kubernetes/
/usr/bin/sudo rm -rfv -- /var/lib/kubelet/
/usr/bin/sudo rm -rfv -- /var/lib/etcd/

/usr/bin/sudo rm -rfv -- /home/pi/.kube/
/usr/bin/sudo rm -rfv -- /root/.kube/

/usr/bin/sudo rm -rfv -- /etc/apt/sources.list.d/kubernetes.list

/usr/bin/sudo rm -rfv -- /opt/cluster/docker/kubecnf/k8_rpi_join.sh

# remove ansible role setup files
/usr/bin/sudo rm -rfv -- /opt/cluster/docker/kubecnf/admin.conf
/usr/bin/sudo rm -rfv -- /opt/cluster/docker/kubecnf/kube_info.txt
/usr/bin/sudo rm -rvf -- /opt/cluster/docker/kubecnf/kube_joined_cli.txt
/usr/bin/sudo rm -rvf -- /opt/cluster/docker/kubecnf/kube_net.txt
/usr/bin/sudo rm -rvf -- /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
/usr/bin/sudo rm -rvf -- /opt/cluster/docker/kube-installed.txt
/usr/bin/sudo rm -rvf -- /opt/cluster/docker/kubeinit.txt

# Purge all Images + Containers + Networks + Volumes
if [ -f /usr/bin/docker ]; then
	docker system prune -a -f >/dev/null
fi

/usr/bin/sudo rm -rfv -- /var/lib/kubelet

# remove etcd
/usr/bin/sudo rm -rfv -- /var/lib/etcd

# remove weave
/usr/bin/sudo rm -rfv -- /etc/cni/
/usr/bin/sudo rm -rfv -- /opt/cni/

# done
rpilogit "finished remove-kube.sh"
