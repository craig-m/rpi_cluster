#!/bin/bash
#
# name: setup-conf.sh
# desc: copy ansible default inventory + host/group vars


# pre-run checks ---------------------------------------------------------------

# do not run this script as root
if [[ root = "$(whoami)" ]]; then
  echo "ERROR: do not run as root";
  exit 1;
fi

echo "* check install-deploy-tools.sh ran";
/etc/ansible/facts.d/deploytool.fact || exit 1;

# log
rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}

rpilogit "starting setup-conf.sh";

# prompt before continue
echo " ";
echo "Will overwrite ansible vars and inventory.";
echo " ";

read -p "Type uppercase yes to contine:"$'\n\n' message
echo " ";

if [ "$message" != "YES" ]; then
  echo "* Canceled, script exiting ";
  exit
else
  echo "* Continuing.";
fi


# ansible vault ----------------------------------------------------------------

# generate a password for the new vault files, stored in pass
pass generate --no-symbols ansible/vault/current 40 || exit 1;

# copy example files from /doc/defaults/{host_vars,group_vars} to /etc/ansible/{host_vars,group_vars}
rpilogit "* copy /doc/default var files";

rsync -avr -- \
  ~/rpi_cluster/ansible/setup/defaults/host_vars/* \
  /etc/ansible/host_vars/

rsync -avr -- \
  ~/rpi_cluster/ansible/setup/defaults/group_vars/* \
  /etc/ansible/group_vars/

rsync -avr -- \
  ~/rpi_cluster/ansible/setup/defaults/inventory/* \
  /etc/ansible/inventory/

cp -v ~/rpi_cluster/ansible/ansible.cfg \
  /etc/ansible/ansible.cfg


# symlink to ansible config
if [ ! -f /home/pi/rpi_cluster/ansible/host_vars ]; then
  ln -sf /etc/ansible/host_vars/ ~/rpi_cluster/ansible/host_vars;
fi
if [ ! -f /home/pi/rpi_cluster/ansible/group_vars ]; then
  ln -sf /etc/ansible/group_vars/ ~/rpi_cluster/ansible/group_vars;
fi


# edit the var files - this is a manual step
echo -e "\n Check /etc/ansible/ config is ok. ";
echo -e " The vault files will be encrypted when you are done. \n ";
read -p " Type uppercase yes to contine: "$'\n\n' message;
echo " ";
if [ "$message" != "YES" ]; then
  echo "* Canceled, script exiting ";
  exit
else
  echo "* Continuing.";
fi

# encrypt all of the vault files in host_vars and group_vars
echo "* encrypt the vault files with ansible-vault"

source ~/env/bin/activate;

find \
   /etc/ansible/group_vars/* \
  -iname vault \
  -exec ansible-vault encrypt {} \;

find \
   /etc/ansible/host_vars/* \
  -iname vault \
  -exec ansible-vault encrypt {} \;

if [ $? -eq 0 ]; then
  rpilogit "ansible-vault encrypt vars OK"
else
  rpilogit "ansible-vault encrypt vars FAILED"
	exit 1;
fi

# Finished ---------------------------------------------------------------------

rpilogit "finished setup-conf.sh";
