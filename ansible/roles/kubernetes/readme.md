# k8 cluster

K8 runs on the 'compute' group.

Setup is mostly done via bash scripts, K8 changes every other week and keeping the ansible playbooks current becomes quite a chore.


# kubectl from deployer

I don't want to install kubectl on my deployer rpi, but i would like to call it from there:

```
pi@psi:~/rpi_cluster $ kubectl () { ssh delta kubectl $@; }
pi@psi:~/rpi_cluster $ kubectl get pods
NAME    READY   STATUS    RESTARTS   AGE
redis   1/1     Running   0          10m
```


# Kube commands


list everything:
```
kubectl get all --all-namespaces
```

see the nodes:
```
kubectl get nodes
```

k8 pods:
```
kubectl get -n kube-system pods
```


# networking

networking is with Weave
https://www.weave.works/docs/net/latest/kubernetes/kube-addon/


# Clean up

For when you really want to clear the cluster, with a hammer, right away:


```
sshcompute() {
  nodes="zeta gamma epsilon delta"
  for node in $nodes;
  do
    ssh $node $@;
  done
}

destroy_k8() {
  sshcompute sudo apt-get -q purge kubeadm kubectl kubernetes-cni kubelet docker-* --allow-change-held-packages -y;
  sshcompute sudo apt-get -q autoremove -y -f;
  sshcompute sudo rm -rfv -- \
    /etc/apt/preferences.d/docker* \
    /etc/apt/preferences.d/kubebin* \
    /opt/cluster/docker/kubecnf/*.txt;
  sshcompute sudo reboot now;
}

destroy_k8;
```
