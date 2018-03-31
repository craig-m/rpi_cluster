#!/bin/bash
# UFW setup script for psi
logger -t rpicluster "ufw.sh started";

apt-get install -y ufw

ufw status verbose

echo 1 > /proc/sys/net/ipv4/tcp_syncookies
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts

# defaults
ufw default deny incoming
ufw default allow outgoing

# log
ufw logging on

# incoming SSH
ufw allow 22/tcp
ufw allow 2222/tcp

# if a temp server is needed
allow from 192.168.6.0/24 to any port 8080 proto tcp

# enable FW
ufw enable
ufw status

touch -f /root/.ufw

logger -t rpicluster "ufw enabled";

# eof
