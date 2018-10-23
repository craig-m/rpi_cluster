#!/bin/bash
# name: new_keysandconf.sh
# desc: create new private SSH, PGP, SSL and Ansible vault files.
# Used when standing up a R-Pi new cluster, with new configs (varible files).

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

rpilogit "starting keysandconf_new.sh";

# secure umask
umask 77


# PGP key ----------------------------------------------------------------------
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
Name-Email: pi@psi
Name-Comment: Berry Cluster deployer admin
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
mypubkeyid=$(gpg2 --list-public-keys pi@psi | head -n2 | tail -1 | tr -d '\ ')

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
}

keysandconf_pass;

# ansible vault ----------------------------------------------------------------

# generate a password for the new vault files, stored in pass
pass generate --no-symbols ansible/vault/current 40

# copy example files from /doc/defaults/{host_vars,group_vars} to /etc/ansible/{host_vars,group_vars}
echo "* copy /doc/default var files"

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


# todo: remove the need for this symlink
ln /etc/ansible/host_vars/ ~/rpi_cluster/ansible/host_vars -sf
ln /etc/ansible/group_vars/ ~/rpi_cluster/ansible/group_vars -sf


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

# SSH keys ---------------------------------------------------------------------
# create a SSH-CA key and then sign SSH keys with it

keysandconf_ssh () {
  # --- create the CA certs ---
  mkdir -pv ~/.ssh/my-ssh-ca/ || exit 1
  cd ~/.ssh/my-ssh-ca/ || exit 1
  mkdir -pv ~/.ssh/old-keys
  # generate a password for the SSH CA
  echo "* create a password for ssh CA"
  pass generate --no-symbols ssh/CA 40
  # get the password
  thesshcapw=$(pass ssh/CA)
  # generate the CA key pair (with password)
  ssh-keygen -t rsa -b 4096 -C ~/.ssh/my-ssh-ca/CA -f ~/.ssh/my-ssh-ca/ca -P ${thesshcapw}
  # --- SSH user keys ---
  # password for ssh pair
  pass generate --no-symbols ssh/id_rsa 30
  idrsapass=$(pass ssh/id_rsa)
  # generate our pub+priv ssh rsa keys
  ssh-keygen -P "${idrsapass}" -o -f ~/.ssh/id_rsa -t rsa
  # --- sign our SSH key with CA key ---
  # note: keys are valid for 1 week
  ssh-keygen -s ~/.ssh/my-ssh-ca/ca -P ${thesshcapw} -I ${USER} -n pi -V +1w -z 1 ~/.ssh/id_rsa
  # cleanup
  thesshkeypw="x";
  thesshcapw="x";
}

keysandconf_ssh;

# SSL CA -----------------------------------------------------------------------

keysandconf_pass () {
  mkdir -pv ~/.ssl-pki/

}

# finished ---------------------------------------------------------------------

if [ ! -f ~/.keyset_id ]; then
  keyset_id=$(uuid)
  ssh_fprint=$(ssh-keygen -l -f ~/.ssh/id_rsa.pub )
  touch ~/.rpibs/keyset_id
  echo "keyset_id: ${keyset_id}" > ~/.rpibs/keyset_id
  echo "gpgkey_id: ${mypubkeyid}" >> ~/.rpibs/keyset_id
  echo "ssh_pub_id: ${ssh_fprint}" >> ~/.rpibs/keyset_id
fi


# -- file start --
cat > /etc/ansible/facts.d/keysandconf.fact << EOF
#!/bin/bash
echo '{ "keysandconf" : "true" }';
EOF
# -- file stop --

chmod 755 /etc/ansible/facts.d/keysandconf.fact

# EOF --------------------------------------------------------------------------
