#!/bin/bash
# Reset R-Pi password and sshd to default

{

if [[ root != "$(whoami)" ]]; then
  echo "Error: requires root";
  exit 1;
fi

echo "loading INSECURE defaults";

rm -fv -- /home/pi/.ssh/*
rm -fv -- /home/root/.ssh/*

cat > /etc/ssh/sshd_config << EOF
# sshd defaults
Port 22
ListenAddress 0.0.0.0
Protocol 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
SyslogFacility AUTH
LogLevel INFO
LoginGraceTime 120
PermitRootLogin Yes
StrictModes yes
IgnoreRhosts yes
PermitEmptyPasswords no
ChallengeResponseAuthentication no
PasswordAuthentication yes
X11Forwarding no
X11DisplayOffset 10
PrintMotd no
PrintLastLog no
TCPKeepAlive yes
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
UsePAM yes
EOF

systemctl restart ssh
systemctl status ssh

cat > /etc/sudoers.d/010_pi-nopasswd << EOF
pi ALL=(ALL) NOPASSWD: ALL
EOF

echo "pi:raspberry" | chpasswd

dpkg-reconfigure openssh-server

echo "finished";

}
