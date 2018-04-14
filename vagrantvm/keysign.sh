#!/bin/bash

# ~/rpi_cluster/vagrantvm/keysign.sh /opt/cluster/backup/psi/home/pi/.ssh/id_rsa

thecount=$(redis-cli get /rpi/deployer/keysign/count)

thesshcapw=$(pass ssh/CA)

ssh-keygen -s ~/rpi_cluster/local_data/ssh/my-ssh-ca/ca -P ${thesshcapw} -I vagrant -n pi -V +4w -z 1 $1

redis-cli incr /rpi/deployer/keysign/count
