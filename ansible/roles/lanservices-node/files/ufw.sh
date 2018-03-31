#!/bin/bash

apt-get install ufw -y

ufw status verbose

echo 1 > /proc/sys/net/ipv4/tcp_syncookies
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts

# defaults
ufw default deny incoming
ufw default deny outgoing

# incoming SSH
ufw allow 22/tcp
ufw allow 2220/tcp

# incoming busybox httpd
ufw allow 1080/tcp

# incoming named
ufw allow 53/tcp
ufw allow 53/udp
allow from 192.168.6.0/24 to any port 953 proto tcp

# incoming dhcpd
allow from 192.168.6.0/24 to any port 647 proto tcp
allow from 192.168.6.0/24 to any port 38995 proto udp
allow from 192.168.6.0/24 to any port 55108 proto udp

# outbound
ufw allow out 20,21,22,53,67,68,69,80,443,8080,647,953,123/tcp
ufw allow out 20,21,22,53,67,68,69,80,443,8080,647,953,123/udp

# services
allow from 192.168.6.0/24 to any port 8080 proto tcp


# enable FW
ufw enable
ufw status
