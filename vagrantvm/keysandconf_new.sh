#!/bin/bash
# name: new_keysandconf.sh
# desc: create new private SSH, PGP and Ansible vault files.
# Used when standing up a R-Pi new cluster, with new configs (varible files).

thehomedir="/home/vagrant";

# pre-run checks ---------------------------------------------------------------

# prompt before continue
echo " ";
echo "Generate new PGP, SSH, and ansible vault configs (see /doc/defaults/readme.md). Use when creating a new cluster.";
echo " ";
echo "WARNING: all old [ssh and PGP] keys, passwords, and ansible varibles will be replaced!"
echo " ";

read -p "Type uppercase yes to contine:"$'\n\n' message
echo " ";

if [ "$message" != "YES" ]; then
  echo "* Canceled, script exiting ";
  exit
else
  echo "* Continuing.";
fi

# only run as vagrant
if [[ vagrant != "$(whoami)" ]]; then
  rpilogit "* Error: requires vagrant user";
  exit 1;
fi

# Only run on stretch
if [[ stretch != "$(hostname)" ]]; then
  rpilogit "* Error: vbox only";
  exit 1;
fi

# check vagrantvm (created by vagrantfile_root.sh)
/etc/ansible/facts.d/vagrantvm.fact | grep boxbuild_id || exit 1;

# log
rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}

rpilogit "starting new_keysandconf.sh";


# Create PGP key ---------------------------------------------------------------
# Make a pair of keys, with password for private key.
# https://www.gnupg.org/documentation/manuals/gnupg/Unattended-GPG-key-generation.html

# This will be the only password that we need to manage,
# all other passwords are encrypted with our PGP key.

read -p "Type the GPG password:"$'\n\n' themasterpw

# created in tmpfs
cat > /mnt/ramstore/data/gpg-gen-key-script << EOF
Key-Type: 1
Key-Length: 4096
Subkey-Type: 1
Subkey-Length: 4096
Name-Real: admin
Name-Email: admin@localhost
Name-Comment: Berry Cluster root admin
Passphrase: $themasterpw
Expire-Date: 0
EOF

killall gpg-agent

# remmove old keys
echo "* remove old ~/.gnupg files"
rm -rfv -- ~/.gnupg/*

# gen new keys
gpg --batch --gen-key /mnt/ramstore/data/gpg-gen-key-script

# clean up
themasterpw="x";
srm -v -- /mnt/ramstore/data/gpg-gen-key-script

# public key id
mypubkeyid=$(gpg2 --list-public-keys root@localhost | head -n2 | tail -1 | tr -d '\ ')


# pass store -------------------------------------------------------------------
# the password store is encrypted with the GPG key we just created
# https://www.passwordstore.org/

echo "* remove old ~/.password-store files"
rm -rfv -- ${thehomedir}/.password-store/

echo "* initialize a new password storage"
pass init ${mypubkeyid}

# ID for this vault
pass_id=$(uuid)
pass insert id/

# test password with a random name
echo "* create test password: "
atestpw=$(pwgen -1 -a)
pass generate test/${atestpw} 10
echo "* test password is: "
pass test/${atestpw}


# ansible vault ----------------------------------------------------------------

# generate a password for the new vault files, stored in pass
pass generate ansible/vault/current 40

# remove old config
echo "* remove old ansible var files"
rm -rfv -- /home/vagrant/rpi_cluster/deploy/ansible/host_vars/*
rm -rfv -- /home/vagrant/rpi_cluster/deploy/ansible/group_vars/*

# copy example files from /doc/defaults/{host_vars,group_vars} to deploy/ansible/{host_vars,group_vars}
echo "* copy /doc/default var files"

rsync -avr -- \
  /home/vagrant/rpi_cluster/doc/defaults/host_vars/* \
  /home/vagrant/rpi_cluster/ansible/host_vars/

rsync -avr -- \
  /home/vagrant/rpi_cluster/doc/defaults/group_vars/* \
  /home/vagrant/rpi_cluster/ansible/group_vars/


# edit the var files - this is a manual step
echo "* You need to edit /rpi_cluster/local_data/ansible_var_temp on your desktop (or in VM if you want)."
read -p "Type uppercase yes to contine:"$'\n\n' message
echo " ";
if [ "$message" != "YES" ]; then
  echo "* Canceled, script exiting ";
  exit
else
  echo "* Continuing.";
fi


# encrypt all of the vault files in host_vars and group_vars
echo "* encrypt the vault files with ansible-vault"
find \
  /home/vagrant/rpi_cluster/deploy/ansible/host_vars/ \
  /home/vagrant/rpi_cluster/deploy/ansible/group_vars/ \
  -iname vault \
  -exec ansible-vault --vault-id ~/rpi_cluster/ansible/vault_pass.sh encrypt {} \;


# SSH keys ---------------------------------------------------------------------

# remove old
echo "* remove old ssh key pair from ~/.ssh/"
rm -fv -- ${thehomedir}/.ssh/id_rsa
rm -fv -- ${thehomedir}/.ssh/id_rsa.pub

# generate a password for the SSH private key
echo "* create a password for ssh private key"
pass generate --no-symbols ssh/id_rsa_pw 30

# get the password
thesshkeypw=$(pass ssh/id_rsa_pw)

# create key pair
echo "* create a new SSH key pair"
ssh-keygen -b 4096 -P ${thesshkeypw} -t rsa -f ${thehomedir}/.ssh/id_rsa

# cleanup
thesshkeypw="x";


# ID ---------------------------------------------------------------------------

if [ ! -f /home/vagrant/rpi_cluster/local_data/keyset_id ]; then
  keyset_id=$(uuid)
  ssh_fprint=$(ssh-keygen -l -f ~/.ssh/id_rsa.pub)
  touch /home/vagrant/rpi_cluster/local_data/keyset_id
  echo "keyset_id: ${keyset_id}" > /home/vagrant/rpi_cluster/local_data/keyset_id
  echo "gpgkey_id: ${mypubkeyid}" >> /home/vagrant/rpi_cluster/local_data/keyset_id
  echo "ssh_pub_id: ${ssh_fprint}" >> /home/vagrant/rpi_cluster/local_data/keyset_id
fi

# Backup -----------------------------------------------------------------------
# the GPG, SSH, and password store files are only in an ephemeral right now, we
# need to back them up. They can be restored in a new VN when we have an
# exiting cluster up and running already.

# to local
rsync -avr --exclude '*.DS_Store' \
  -- /home/vagrant/.ssh/ /home/vagrant/rpi_cluster/local_data/ssh/

rsync -avr --exclude '*.DS_Store' \
  -- /home/vagrant/.gnupg/ /home/vagrant/rpi_cluster/local_data/pgp

# copy into git repo
rsync -avr --delete --exclude '*.DS_Store' \
  -- /home/vagrant/.password-store/ /home/vagrant/rpi_cluster/vagrantvm/dotfiles/password-store/

rpilogit "finished new_keysandconf.sh";

# EOF --------------------------------------------------------------------------
