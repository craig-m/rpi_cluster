#!/bin/bash
# name: restore_keysandconf.sh
# desc: restore private ssh and pgp keys, from Desktop to Admin VM.

# run manually

# pre-run checks ---------------------------------------------------------------

# log
rpilogit () {
	echo -e "rpicluster: $1 \n";
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

rpilogit "starting keysandconf_restore.sh";


# restore ----------------------------------------------------------------------
# private keys are kept locally

# SSH
rsync -avr --exclude '*.DS_Store' --exclude 'ssh-copy-id_id.*' \
  -- ~/rpi_cluster/local_data/ssh/ ~/.ssh/
chmod 700 ~/.ssh/

# PGP
rsync -avr --exclude '*.DS_Store' \
  -- ~/rpi_cluster/local_data/pgp/ ~/.gnupg/
chmod 700 ~/.gnupg/
/usr/bin/sudo chown $USER:$USER ~/.gnupg/*
file ~/.gnupg/pubring.kbx | grep "GPG keybox database version 1" || exit 1

if [ ! /home/vagrant/.password-store ]; then
	ln -s -f /home/vagrant/rpi_cluster/vagrantvm/dotfiles/password-store /home/vagrant/.password-store
fi

# finish up --------------------------------------------------------------------

rpilogit "finished keysandconf_restore.sh";

# EOF --------------------------------------------------------------------------
