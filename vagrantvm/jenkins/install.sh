#!/bin/bash
# https://pkg.jenkins.io/debian-stable/

logger -t rpicluster "install.sh installing jenkins "

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

/usr/bin/sudo cat /var/lib/jenkins/secrets/initialAdminPassword

logger -t rpicluster "install.sh installed jenkins "
