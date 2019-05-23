#!/bin/bash


# do not run this script as root
if [[ root = "$(whoami)" ]]; then
  echo "ERROR: do not run as root";
  exit 1;
fi


echo -e "\nNodes:";
kubectl get nodes


echo -e "\nPods:";
kubectl get pods --all-namespaces