#!/bin/bash

# Run on psi:
hostname | grep psi || exit 1;
whoami | grep pi || exit 1;

mpikeytemp=$(mktemp -d)
cd $mpikeytemp;

cp /opt/cluster/backup/omega/home/mpiuser/.ssh/* .
thesshcapw=$(pass ssh/CA)
ssh-keygen -s ~/.ssh/my-ssh-ca/ca -P ${thesshcapw} -I mpiuser -n mpiuser -V +2w -z 1 ${mpikeytemp}/id_rsa.pub

scp id_rsa-cert.pub pi@omega:~/
ssh pi@omega sudo mv id_rsa-cert.pub /home/mpiuser/.ssh/id_rsa-cert.pub -v
ssh pi@omega sudo chown mpiuser:mpiuser /home/mpiuser/.ssh/id_rsa-cert.pub
