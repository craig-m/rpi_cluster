#!/bin/bash
# name: vagrantfile_user.sh
# desc: Runs automatically on Vagrant Provision, as Vagrant user.
# Safe to re-run manually, multiple times over.

# pre-run checks ---------------------------------------------------------------

# send output to screen
set -o verbose

rpilogit () {
	echo -e "rpicluster: $1";
	logger -t rpicluster "$1";
}

# log
rpilogit "vagrantfile_user.sh started";

# only run as vagrant
if [[ vagrant != "$(whoami)" ]]; then
  rpilogit "Error: requires vagrant user";
  exit 1;
fi

# Only run on stretch
if [[ stretch != "$(hostname)" ]]; then
  rpilogit "Error: vbox only";
  exit 1;
fi

# check vagrantvm (created by vagrantfile_root.sh)
/etc/ansible/facts.d/vagrantvm.fact | grep boxbuild_id || exit 1;

# Vagrant VM files -------------------------------------------------------------

# local_data ssh
if [ ! -d ~/rpi_cluster/local_data/ssh/my-ssh-ca ]; then
	mkdir -pv ~/rpi_cluster/local_data/ssh/my-ssh-ca;
	chmod 700 ~/rpi_cluster/local_data/ssh/my-ssh-ca;
fi

# local_data pgp
if [ ! -d ~/rpi_cluster/local_data/pgp ]; then
	mkdir -pv ~/rpi_cluster/local_data/pgp;
	chmod 700 ~/rpi_cluster/local_data/pgp;
fi


# backup authorized_keys (with default vagrant user key)
if [ ! -f ~/.ssh/authorized_keys.vagrant ]; then
	cp ~/.ssh/authorized_keys ~/.ssh/authorized_keys.vagrant
fi


# finish up --------------------------------------------------------------------

# Done
rpilogit "vagrantfile_user.sh finished OK";

sleep 1s;

# EOF --------------------------------------------------------------------------
