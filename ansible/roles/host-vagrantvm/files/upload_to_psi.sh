#!/bin/bash

psi_ip="$1"

if [[ -z $1 ]]; then
  echo "use: $ ./script <ip>";
  exit 1;
fi


# output/log function
rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}

rpicluster "starting upload_to_psi.sh"

# start agent if down
pgrep ssh-agent || eval $(ssh-agent -s -a ~/.ssh/ssh-agent.sock)
ssh-add -l | grep "/home/vagrant/.ssh/id_rsa" || ssh-add

ssh pi@${psi_ip} uptime || echo "Can not SSH in "

rsync -ar ~/rpi_cluster/* pi@${psi_ip}:/home/pi/rpi_cluster/ \
  --exclude '*.DS_Store' \
  --exclude '.vagrant' \
  --exclude '.git/' \
  --exclude 'vagrantvm/' \
  --exclude 'ignore_me/' \
  --exclude 'deploy/omegapyapi/flask/*' \
  --exclude 'deploy/ansible/*.pyc' \
  --exclude 'deploy/ansible/*.retry' \
  --exclude 'deploy/ansible/logs/*' \
  --exclude 'deploy/ansible/inventories/vagrant'

rpicluster "finished upload_to_psi.sh"
