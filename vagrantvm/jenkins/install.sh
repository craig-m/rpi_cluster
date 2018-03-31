#!/bin/bash
# https://pkg.jenkins.io/debian-stable/

logger -t rpicluster "install.sh installing jenkins "

# install ----------------------------------------------------------------------

/usr/bin/sudo apt-key add jenkins.io.key

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
