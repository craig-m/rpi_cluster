#!/bin/bash

systemctl stop puppet.service
systemctl disable puppet.service

rm -rf -- /etc/puppetlabs/
rm -rf -- /etc/default/puppet
rm -rf -- /etc/systemd/system/multi-user.target.wants/puppet.service

systemctl daemon-reload
