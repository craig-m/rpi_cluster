#!/bin/bash
# to be run on Psi (the Deployer node)

echo "renewing ssh keys"

# do not run this script as root
if [[ root = "$(whoami)" ]]; then
  echo "ERROR: do not run as root";
  exit 1;
fi

# test /usr/bin/sudo <cmd> works OK
/usr/bin/sudo id | grep "uid=0(root)" > /dev/null 2>&1 || exit 1;

# exit ssh agent
killall ssh-agent

mv -v -f -- ~/.ssh/id_rsa* ~/.ssh/old-keys/

sshprvpass=$(pass ssh/id_rsa)
ssh-keygen -P "${sshprvpass}" -o -f ~/.ssh/id_rsa -t rsa

# sign our SSH key with CA key
thesshcapw=$(pass ssh/CA)
ssh-keygen -s ~/.ssh/my-ssh-ca/ca -P ${thesshcapw} -I pi -n pi -V +1w -z 1 ~/.ssh/id_rsa

#eval `ssh-agent -s`
#ssh-add

/usr/bin/sudo bash -c 'cat /home/pi/.ssh/id_rsa.pub >> /home/pi/.ssh/authorized_keys'

echo "done"
