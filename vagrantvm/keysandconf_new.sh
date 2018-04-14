#!/bin/bash
# name: new_keysandconf.sh
# desc: create new private SSH, PGP and Ansible vault files.
# Used when standing up a R-Pi new cluster, with new configs (varible files).

# run manually

# pre-run checks ---------------------------------------------------------------

# prompt before continue
echo " ";
echo "Generate new PGP, SSH, and ansible vault configs (see /doc/defaults/readme.md). Use when creating a new cluster.";
echo " ";
echo "WARNING: all old keys (GPG, SSH, CA etc), passwords, and ansible varibles will be replaced!"
echo " ";

read -p "Type uppercase yes to contine:"$'\n\n' message
echo " ";

if [ "$message" != "YES" ]; then
  echo "* Canceled, script exiting ";
  exit
else
  echo "* Continuing.";
fi

# log
rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}

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

# check vagrantvm OK (created by vagrantfile_root.sh)
/etc/ansible/facts.d/vagrantvm.fact | grep boxbuild_id > /dev/null 2>&1 || exit 1;

rpilogit "starting keysandconf_new.sh";

# secure umask
umask 77

# Create PGP key ---------------------------------------------------------------
# Make a pair of keys, with password for private key.
# https://www.gnupg.org/documentation/manuals/gnupg/Unattended-GPG-key-generation.html

# This will be the only password that we need to manage,
# all other passwords are encrypted with our PGP key.

read -s -p "Type the GPG password, push enter:"$'\n\n' themasterpw

read -s -p "Enter GPG password again, push enter:"$'\n\n' themasterpw_conf

# check passwords match
if [ "$themasterpw" != "$themasterpw_conf" ]; then
  echo "ERROR: passwords don't match!";
  exit 1;
else
  echo -e "Passwords match OK.\n";
fi
keysandconf_gpg () {
# created in tmpfs
cat > /mnt/ramstore/data/gpg.batch << EOF
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

# remmove old keys
echo "* remove old ~/.gnupg files"
rm -rfv -- ~/.gnupg/*
mkdir -pv -- ~/.gnupg/private-keys-v1.d
mkdir -pv -- ~/.gnupg/openpgp-revocs.d
killall gpg-agent
gpg-agent bash
sleep 2s;

# gen new keys
echo "* create gpg private key"
gpg --batch --gen-key /mnt/ramstore/data/gpg.batch || exit 1;

# clean up
themasterpw="x"
if [ -f /mnt/ramstore/data/gpg.batch ]; then
  srm -v -- /mnt/ramstore/data/gpg.batch || exit 1;
fi

# public key id
mypubkeyid=$(gpg2 --list-public-keys admin@localhost | head -n2 | tail -1 | tr -d '\ ')

# GnuPG config
cat > ~/.gnupg/gpg-agent.conf << EOF
default-cache-ttl 172800
max-cache-ttl 172800
EOF
}

keysandconf_gpg


# pass store -------------------------------------------------------------------
# the password store is encrypted with the GPG key we just created
# https://www.passwordstore.org/
# https://docs.ansible.com/ansible/latest/plugins/lookup/passwordstore.html


keysandconf_pass () {
echo "* remove old ~/.password-store files"
rm -rfv -- ~/.password-store/
rm -rfv -- ~/rpi_cluster/vagrantvm/dotfiles/password-store
echo "* initialize a new password storage"
pass init ${mypubkeyid} || exit 1;
# test passwords
# note: only used for verification this script has run (etc),
# these are not sensitive.
echo "* create test passwords: "
pass_id=$(uuid)
echo ${pass_id} | pass insert --echo test/id || exit 1;
atestpw=$(pwgen -1 -a)
pass generate --no-symbols test/${atestpw} 10
echo "* test password named: "
pass test/${atestpw} || exit 1;
pass generate --no-symbols test/test 10
mv /home/vagrant/.password-store ~/rpi_cluster/vagrantvm/dotfiles/password-store
ln -s -f ~/rpi_cluster/vagrantvm/dotfiles/password-store /home/vagrant/.password-store
}

keysandconf_pass;


# ansible vault ----------------------------------------------------------------

# generate a password for the new vault files, stored in pass
pass generate --no-symbols ansible/vault/current 40

# remove old config
echo "* remove old ansible var files"
rm -rfv -- ~/rpi_cluster/deploy/ansible/host_vars/*
rm -rfv -- ~/rpi_cluster/deploy/ansible/group_vars/*

# copy example files from /doc/defaults/{host_vars,group_vars} to deploy/ansible/{host_vars,group_vars}
echo "* copy /doc/default var files"

rsync -avr -- \
  ~/rpi_cluster/doc/defaults/host_vars/* \
  ~/rpi_cluster/ansible/host_vars/

rsync -avr -- \
  ~/rpi_cluster/doc/defaults/group_vars/* \
  ~/rpi_cluster/ansible/group_vars/

rsync -avr -- \
  ~/rpi_cluster/doc/defaults/inventory/* \
  ~/rpi_cluster/ansible/inventory/

# edit the var files - this is a manual step
echo "* On your desktop or in Vagrant VM, in rpi_cluster/ansible"
echo "you need to edit files in group_vars/* + host_vars/* + inventory/* to suit your needs."
echo "These files will be encrypted with ansible vault when you are done. \n"
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
  ~/rpi_cluster/ansible/group_vars/* \
  -iname vault \
  -exec ansible-vault encrypt {} \;

find \
  ~/rpi_cluster/ansible/host_vars/* \
  -iname vault \
  -exec ansible-vault encrypt {} \;


# SSH keys ---------------------------------------------------------------------

keysandconf_ssh () {
  # remove old
  rm -rfv -- ~/rpi_cluster/local_data/ssh/*
  rm -rfv -- ~/.ssh/
  # --- create the CA certs ---
  mkdir -pv ~/rpi_cluster/local_data/ssh/my-ssh-ca/ || exit 1
  cd ~/rpi_cluster/local_data/ssh/my-ssh-ca/ || exit 1
  # generate a password for the SSH CA
  echo "* create a password for ssh CA"
  pass generate --no-symbols ssh/CA 40
  # get the password
  thesshcapw=$(pass ssh/CA)
  # generate the CA key pair (with password)
  ssh-keygen -t rsa -b 4096 -C ~/rpi_cluster/local_data/ssh/my-ssh-ca/CA -f ~/rpi_cluster/local_data/ssh/my-ssh-ca/ca -P ${thesshcapw}
  cp -fv ~/rpi_cluster/local_data/ssh/my-ssh-ca/ca.pub ~/.ssh/ca.pub
  # --- SSH user keys ---
  # generate our SSH key pair
  ssh-keygen -P "" -f ~/.ssh/id_rsa -t rsa
  # --- sign our SSH key with CA key ---
  ssh-keygen -s ~/rpi_cluster/local_data/ssh/my-ssh-ca/ca -P ${thesshcapw} -I ${USER} -n pi -V +4w -z 1 ~/.ssh/id_rsa
  # cleanup
  thesshkeypw="x";
  thesshcapw="x";
}

keysandconf_ssh;


# ID ---------------------------------------------------------------------------

if [ ! -f /home/vagrant/rpi_cluster/local_data/keyset_id ]; then
  keyset_id=$(uuid)
  ssh_fprint=$(ssh-keygen -l -f ~/rpi_cluster/local_data/ssh/id_ecdsa.pub )
  touch ~/rpi_cluster/local_data/keyset_id
  echo "keyset_id: ${keyset_id}" > ~/rpi_cluster/local_data/keyset_id
  echo "gpgkey_id: ${mypubkeyid}" >> ~/rpi_cluster/local_data/keyset_id
  echo "ssh_pub_id: ${ssh_fprint}" >> ~/rpi_cluster/local_data/keyset_id
  # from VM build:
  vmbuild_id=$(/etc/ansible/facts.d/vagrantvm.fact | jq '.boxbuild_id' | tr -d '"')
  echo "boxbuild_id: ${vmbuild_id}" >> ~/rpi_cluster/local_data/keyset_id
fi


# Backup -----------------------------------------------------------------------

rsync -avr \
  --exclude '*.DS_Store' \
  -- ~/.gnupg/ ~/rpi_cluster/local_data/pgp

rpilogit "finished keysandconf_new.sh";

# -- file start --
cat > /etc/ansible/facts.d/keysandconf.fact << EOF
#!/bin/bash
echo '{ "keysandconf" : "true" }';
EOF
# -- file stop --

chmod 755 /etc/ansible/facts.d/keysandconf.fact

# EOF --------------------------------------------------------------------------
