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
cd ~/.ssh/ || exit 1;

# generate a new SSH key pair
ssh-keygen -P "" -C "vagrantvmkeygen" -f ~/.ssh/id_rsa -t rsa

file ~/.ssh/id_rsa | grep "PEM RSA private key" || exit 1;

# get the CA password
thesshcapw=$(pass ssh/CA)

# sign our SSH keys with the CA key
ssh-keygen -s ~/rpi_cluster/local_data/ssh/my-ssh-ca/ca -P ${thesshcapw} -I ${USER} -n pi -V +4w -z 1 ~/.ssh/id_rsa

# PGP
rsync -avr --exclude '*.DS_Store' \
  -- ~/rpi_cluster/local_data/pgp/ ~/.gnupg/

chmod 700 ~/.gnupg/
cd ~/.gnupg/ || exit 1;

/usr/bin/sudo chown $USER:$USER ~/.gnupg/*

file ~/.gnupg/pubring.kbx | grep "GPG keybox database version 1" || exit 1

if [ ! -f /home/vagrant/.password-store ]; then
	ln -s -f /home/vagrant/rpi_cluster/vagrantvm/dotfiles/password-store /home/vagrant/.password-store
fi

cd ~/.password-store || exit 1;


# finish up --------------------------------------------------------------------

rpilogit "finished keysandconf_restore.sh";

# -- file start --
cat > /etc/ansible/facts.d/keysandconf.fact << EOF
#!/bin/bash
echo '{ "keysandconf" : "true" }';
EOF
# -- file stop --

chmod 755 /etc/ansible/facts.d/keysandconf.fact

# EOF --------------------------------------------------------------------------
