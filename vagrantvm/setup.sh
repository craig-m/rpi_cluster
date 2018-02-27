#!/bin/bash
# name: setup.sh
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

# check Vagrant Provisioned OK
if [ ! -f /home/Vagrantfile.sh.txt ]; then
  rpilogit "ERROR: Vagrantfile.sh did not finish";
  exit 1;
fi

mkdir -pv /home/vagrant/.rpivbox;

rpilogit "setup.sh (vagrantvm) started";

# Vagrant VM files -------------------------------------------------------------

if [ ! -f /home/vagrant/.rpivbox/stow_files ]; then
  # GNU Stow symlink files ( https://www.gnu.org/software/stow/ )
  stow --dir=/home/vagrant/rpi_cluster/vagrantvm/dotfiles/ \
		--target=/home/vagrant git || exit 1;

  stow --dir=/home/vagrant/rpi_cluster/vagrantvm/dotfiles/ \
		--target=/home/vagrant password-store || exit 1;

  touch /home/vagrant/.rpivbox/stow_files;
fi

if [ ! -f /home/vagrant/.rpivbox/files ]; then
  # copy password-store
  rsync -av /home/vagrant/rpi_cluster/vagrantvm/dotfiles/password-store/ ~/ || exit 1;

  # Copy PGP key pair
  rsync -av /home/vagrant/rpi_cluster/vagrantvm/dotfiles/gnupg/* ~/.gnupg || exit 1;
  chmod 700 ~/.gnupg;

  # copy bash dotfiles
  rsync -av /home/vagrant/rpi_cluster/vagrantvm/dotfiles/bash/ ~/ || exit 1;

  touch /home/vagrant/.rpivbox/files;
fi

# local_data on host
if [ ! -d /home/vagrant/rpi_cluster/local_data ]; then
	mkdir -pv /home/vagrant/rpi_cluster/local_data/
fi


# finish up --------------------------------------------------------------------

# check process count
echo "check process count";
/usr/lib/nagios/plugins/check_procs -w 200 -c 300;

# Done
rpilogit "setup.sh (vagrantvm) finished";

# EOF
