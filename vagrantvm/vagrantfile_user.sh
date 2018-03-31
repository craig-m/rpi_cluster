#!/bin/bash
# name: vagrantfile_user.sh
# desc: Runs on Vagrant Provision, as Vagrant user.

# pre-run checks ---------------------------------------------------------------

# send output to screen
set -o verbose

rpilogit () {
	echo -e "rpicluster: $1";
	logger -t rpicluster "$1";
}

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

# log
rpilogit "setup.sh (vagrantvm) started";

# Vagrant VM files -------------------------------------------------------------

# local_data ssh
if [ ! -d /home/vagrant/rpi_cluster/local_data/ssh ]; then
	mkdir -pv /home/vagrant/rpi_cluster/local_data/ssh
fi

# local_data pgp
if [ ! -d /home/vagrant/rpi_cluster/local_data/pgp ]; then
	mkdir -pv /home/vagrant/rpi_cluster/local_data/pgp
fi

# local_data ansible var backup
if [ ! -d /home/vagrant/rpi_cluster/local_data/var-bu ]; then
	mkdir -pv /home/vagrant/rpi_cluster/local_data/var-bu
fi

# finish up --------------------------------------------------------------------

# check process count
echo "check process count";
/usr/bin/sudo /usr/lib/nagios/plugins/check_procs -w 200 -c 300;

# Done
rpilogit "setup.sh (vagrantvm) finished";

# EOF --------------------------------------------------------------------------
