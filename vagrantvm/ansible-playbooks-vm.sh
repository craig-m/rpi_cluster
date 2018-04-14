#!/bin/bash
# run ansible playbooks for the Vagrant VM

# pre-run checks ---------------------------------------------------------------

rpilogit () {
	echo -e "rpicluster: $1";
	logger -t rpicluster "$1";
}

# log
rpilogit "ansible-playbooks-vm.sh started";

# only run as vagrant
if [ vagrant != "$(whoami)" ]; then
  rpilogit "Error: requires vagrant user";
  exit 1;
fi

# Only run on stretch
if [ stretch != "$(hostname)" ]; then
  rpilogit "Error: vbox only";
  exit 1;
fi

# check vagrantvm (created by vagrantfile_root.sh)
/etc/ansible/facts.d/vagrantvm.fact | grep boxbuild_id || exit 1;

/etc/ansible/facts.d/keysandconf.fact | jq '.keysandconf'

# env --------------------------------------------------------------------------

source ~/env/bin/activate

cd ~/rpi_cluster/ansible/

# run playbooks ----------------------------------------------------------------

ansible-playbook -e "runtherole=group-deployer-ssh-client" single-role.yml --connection=local;

ansible-playbook --connection=local play-deployer.yml -i /opt/cluster/data/ansible_local;

#-------------------------------------------------------------------------------
