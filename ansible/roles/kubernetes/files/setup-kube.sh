#!/bin/bash

mkdir -p -v $HOME/.kube

ln -s ~/.kube/ ~/kube

/usr/bin/sudo cp -i -v -- /etc/kubernetes/admin.conf $HOME/.kube/config

/usr/bin/sudo chown $(id -u):$(id -g) $HOME/.kube/config

touch -f /opt/cluster/data/.setup-kube

sleep 5s;
