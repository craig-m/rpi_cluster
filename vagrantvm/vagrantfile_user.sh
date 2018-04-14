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
keyssshdir="~/rpi_cluster/local_data/ssh/my-ssh-ca"
if [ ! -d ${keyssshdir} ]; then
	mkdir -pv ${keyssshdir}
	chmod 700 ${keyssshdir}
fi

# local_data pgp
keyspgpdir="~/rpi_cluster/local_data/pgp"
if [ ! -d ${keyspgpdir}]; then
	mkdir -pv ${keyspgpdir}
	chmod 700 ${keyspgpdir}
fi

# inventory for localhost
cat > /opt/cluster/data/ansible_local << EOF
[deploy]
stretch ansible_host=stretch.local rpi_ip="10.0.2.15" rpi_racked="vm" rpi_mac="zz:zz:zz:zz:zz:zz"
EOF

if [ ! ~/.ansible_inv ]; then
	ln -s -f /opt/cluster/data/ansible_local ~/.ansible_inv
fi

# finish up --------------------------------------------------------------------

# Done
rpilogit "vagrantfile_user.sh finished OK";

sleep 1s;

# EOF --------------------------------------------------------------------------
