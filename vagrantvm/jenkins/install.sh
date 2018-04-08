#!/bin/bash
# https://pkg.jenkins.io/debian-stable/

logger -t rpicluster "install.sh installing jenkins "

# move to this dir
cd $(dirname $(realpath $0)) || exit 1;
pwd;

# install ----------------------------------------------------------------------

/usr/bin/sudo apt-key add ~/rpi_cluster/vagrantvm/jenkins/jenkins.io.key || exit 1

cat > jenkins.list << EOF
#
deb http://pkg.jenkins.io/debian-stable binary/
#
EOF
/usr/bin/sudo mv jenkins.list /etc/apt/sources.list.d/

DEBIAN_FRONTEND=noninteractive

/usr/bin/sudo apt-get update
/usr/bin/sudo apt-get install -y -q jenkins

/usr/bin/sudo systemctl start jenkins.service

sleep 20s;

/usr/bin/sudo cat /var/lib/jenkins/secrets/initialAdminPassword

echo -e "\n From your desktop Jenkins can be found at: http://localhost:5553/ \n"

logger -t rpicluster "install.sh installed jenkins "

# EOF --------------------------------------------------------------------------
