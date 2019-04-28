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

# test /usr/bin/sudo <cmd> works OK
# /usr/bin/sudo id | grep "uid=0(root)" > /dev/null 2>&1 || exit 1;

# exit ssh agent
killall ssh-agent

mkdir -pv ~/.ssh/old-keys/

cp -v -f -- ~/.ssh/id_rsa* ~/.ssh/old-keys/
rm -rvf -- /home/pi/.ssh/id_rsa.pub /home/pi/.ssh/id_rsa

sshprvpass=$(pass ssh/id_rsa)

sshprvpass_leng=$(echo $sshprvpass | wc -c)
if [ ${sshprvpass_leng} -lt 15 ]; then
  echo "error password too short"
  exit 1;
else
  echo "pass length ok"
fi

ssh-keygen -P "${sshprvpass}" -o -f ~/.ssh/id_rsa -t rsa

# sign our SSH key with CA key
thesshcapw=$(pass ssh/CA)
ssh-keygen -s ~/.ssh/my-ssh-ca/ca -P ${thesshcapw} -I pi -n pi -V +1w -z 1 ~/.ssh/id_rsa

# clear vars
sshprvpass="x"
thesshcapw="x"

bash -c 'cat /home/pi/.ssh/id_rsa.pub >> /home/pi/.ssh/authorized_keys'

echo "done"
