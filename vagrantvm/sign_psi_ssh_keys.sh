#!/bin/bash

thesshcapw=$(pass ssh/CA)

ssh-keygen -s ~/rpi_cluster/local_data/ssh/my-ssh-ca/ca -P "${thesshcapw}" \
  -N "" -I vagrant -n pi -V +1w -z 1 /opt/cluster/backup/psi/home/pi/.ssh/id_rsa

rsync -avr -- /opt/cluster/backup/psi/home/pi/.ssh/id_rsa* \
  pi@psi:~/.ssh/

rsync -avr -- ~/.ssh/my-ssh-ca/ca.pub pi@psi:~/.ssh/my-ssh-ca/ca.pub
