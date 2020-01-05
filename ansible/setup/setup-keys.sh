#!/bin/bash
#
# name: setup-keys.sh
# desc: create new private SSH, PGP, SSL keys.

# pre-run checks ---------------------------------------------------------------

# prompt before continue
echo " ";
echo "Generate new PGP + SSH + SSL Keys (see /doc/defaults/readme.md).";
echo " ";
echo "WARNING: ALL current keys + passwords will be replaced!"
echo " ";

read -p "Type uppercase yes to contine:"$'\n\n' message
echo " ";

if [ "$message" != "YES" ]; then
  echo "* Canceled, script exiting ";
  exit
else
  echo "* Continuing.";
fi

# exit on use of uninitialized var
set -u

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

rpilogit "starting setup-keys.sh";

# secure umask
umask 77


# PGP keypair ------------------------------------------------------------------
# Make a pair of keys, with password protected private key.
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


# gpg batch
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
rpilogit "remove old ~/.gnupg files";
rm -rfv -- ~/.gnupg/*
mkdir -pv -- ~/.gnupg/private-keys-v1.d
mkdir -pv -- ~/.gnupg/openpgp-revocs.d
killall gpg-agent
gpg-agent bash
sleep 2s;


# generate new PGP keys
rpilogit "* create gpg private key";
gpg --batch --gen-key /mnt/ramstore/data/gpg.batch
if [ $? -eq 0 ]; then
  rpilogit "created new private key"
else
  rpilogit "FAILED to create new private key"
	exit 1;
fi

# clean up
themasterpw="x"
themasterpw_conf="x"
if [ -f /mnt/ramstore/data/gpg.batch ]; then
  srm -v -- /mnt/ramstore/data/gpg.batch || exit 1;
fi

# public key id
mypubkeyid=$(gpg --list-public-keys pi@psi | head -n2 | tail -1 | tr -d '\ ')

# GnuPG config
cat > ~/.gnupg/gpg-agent.conf << EOF
default-cache-ttl 172800
max-cache-ttl 172800
EOF


# pass store -------------------------------------------------------------------
# the password store is encrypted with the GPG key we just created
# https://www.passwordstore.org/
# https://docs.ansible.com/ansible/latest/plugins/lookup/passwordstore.html

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
# check the test password
testpw=$(pass test/test)
sshprvpass_leng=$(echo $testpw | wc -c)
if [ ${sshprvpass_leng} -ne 11 ]; then
  rpilogit "error password too short"
  exit 1;
else
  echo "pass length ok"
fi


# SSH keys ---------------------------------------------------------------------
# create a SSH-CA key and then sign SSH keys with it


# SSHD will only accept keys signed this key pair (excludes deployer)
# SSH CA key setup described at:
# https://code.facebook.com/posts/365787980419535/scalable-and-secure-access-with-ssh/


# --- create the CA certs ---
if [ ! -d ~/.ssh/my-ssh-ca/ ]; then
  mkdir -pv ~/.ssh/my-ssh-ca/ || exit 1
  chmod 700 -v ~/.ssh/my-ssh-ca/
fi

cd ~/.ssh/my-ssh-ca/ || { rpilogit "error changing dir to my-ssh-ca/"; exit 1; }

# generate a password for the SSH CA
rpilogit "create a password for ssh CA";
pass generate --no-symbols ssh/CA 40
# get the CA password
thesshcapw=$(pass ssh/CA)
# check CA password length
sshprvpass_leng=$(echo $thesshcapw | wc -c)
if [ ${sshprvpass_leng} -lt 30 ]; then
  rpilogit "error CA password too short"
  exit 1;
else
  rpilogit "pass length ok"
fi

# generate the CA key pair (with password)
rm -rfv -- ~/.ssh/my-ssh-ca/*
ssh-keygen -C ~/.ssh/my-ssh-ca/CA -f ~/.ssh/my-ssh-ca/ca -P ${thesshcapw}
if [ $? -eq 0 ]; then
  rpilogit "created CA key pair"
  chmod 600 -v ~/.ssh/my-ssh-ca/ca ~/.ssh/my-ssh-ca/ca.pub
else
  rpilogit "FAILED to create CA key pair"
	exit 1;
fi

# add pub CA key to ssh known hosts
the_pub_key=$(cat ~/.ssh/my-ssh-ca/ca.pub)
sudo sh -c "echo '@cert-authority *.local $the_pub_key' > /etc/ssh/ssh_known_hosts"
sh -c "echo '@cert-authority *.local $the_pub_key' > ~/.ssh/known_hosts"


# --- SSH user keys ---
# password for ssh pair
pass generate --no-symbols ssh/id_ecdsa 30
idrsapass=$(pass ssh/id_ecdsa)
# check password length
sshprvpass_leng=$(echo $idrsapass | wc -c)
if [ ${sshprvpass_leng} -lt 20 ]; then
  rpilogit "error SSH key password too short"
  exit 1;
else
  rpilogit "pass length ok"
fi

# generate our pub+priv ssh rsa keys
ssh-keygen -P "${idrsapass}" -o -f ~/.ssh/id_ecdsa -t ecdsa || exit 1;

# --- sign our public SSH key with CA private key ---
rpilogit "note: keys are valid for 1 week";
# get key id
sshkeyid_redis=$(/usr/bin/redis-cli --raw incr /rpi/deployer/keys/ssh_key_id)
# sign
ssh-keygen -s ~/.ssh/my-ssh-ca/ca -P ${thesshcapw} -I ${USER} -n pi -V +1w -z ${sshkeyid_redis} ~/.ssh/id_ecdsa.pub || exit 1;
# show info on the public key
ssh-keygen -L -f ~/.ssh/id_ecdsa-cert.pub


# cleanup
thesshkeypw="x";
thesshcapw="x";


# Finished ---------------------------------------------------------------------

touch ~/.rpibs/setup-keys;
echo "setup-keys.sh finished" >>  ~/.rpibs/setup-keys;
rpilogit "finished setup-keys.sh";
