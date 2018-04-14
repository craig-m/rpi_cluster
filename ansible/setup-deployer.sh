#!/bin/bash

rpi_hw=$(/etc/ansible/facts.d/rpihw.fact | jq '.rpi_hw_mac' | tr -d '"')

case "$rpi_hw" in
  True)
  # Deployer is R-Pi
  echo 'Setting up psi';
  ;;
  False)
  echo 'Setting up Deployer VM'
  # Deployer is VM
  ansible-playbook --connection=local play-deployer.yml -i /opt/cluster/data/ansible_local
  ansible-playbook -e "runtherole=group-deployer-ssh-client" single-role.yml --connection=local
  ;;

  *)
  echo "ERROR: keys not setup"
  exit 1
esac
