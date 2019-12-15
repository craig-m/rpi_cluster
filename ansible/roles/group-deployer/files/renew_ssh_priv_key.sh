#!/bin/bash
# to be run on Psi (the Deployer node)

echo "renewing ssh keys"

# do not run this script as root
if [[ root = "$(whoami)" ]]; then
  echo "ERROR: do not run as root";
  exit 1;
fi

# Run on psi:
hostname | grep psi || exit 1;

rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}

# test /usr/bin/sudo <cmd> works OK
# /usr/bin/sudo id | grep "uid=0(root)" > /dev/null 2>&1 || exit 1;

rpilogit "renew_ssh_priv_key.sh started";

# exit ssh agent
killall ssh-agent

mkdir -pv ~/.ssh/old-keys/

cp -v -f -- ~/.ssh/id_rsa* ~/.ssh/old-keys/
rm -rvf -- /home/pi/.ssh/id_ecdsa.pub /home/pi/.ssh/id_ecdsa

sshprvpass=$(pass ssh/id_ecdsa)

sshprvpass_leng=$(echo $sshprvpass | wc -c)
if [ ${sshprvpass_leng} -lt 15 ]; then
  echo "error password too short"
  exit 1;
else
  echo "pass length ok"
fi

# create SSH key pair
ssh-keygen -P "${sshprvpass}" -o -f ~/.ssh/id_ecdsa -t ecdsa

sshkeyid_redis=$(/usr/bin/redis-cli --raw incr /rpi/deployer/keys/ssh_key_id)

# sign our SSH key with CA key
thesshcapw=$(pass ssh/CA)
ssh-keygen -s ~/.ssh/my-ssh-ca/ca -P ${thesshcapw} -I pi -n pi -V +1w -z ${sshkeyid_redis} ~/.ssh/id_ecdsa.pub

# clear vars
sshprvpass="x"
thesshcapw="x"

chmod 600 ~/.ssh/authorized_keys
bash -c 'cat /home/pi/.ssh/id_rsa.pub >> /home/pi/.ssh/authorized_keys'
chmod 400 ~/.ssh/authorized_keys

rpilogit "renew_ssh_priv_key.sh finished";
