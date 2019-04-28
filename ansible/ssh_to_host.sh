#!/bin/bash
#
# name: ssh_agent_load.sh
# desc: add password to ssh keyfile automatically and then connect to the host.
#
# use: ./ssh_agent_load.sh omega

if [ $# -eq 0 ]; then
    echo "error no host specified."
    exit 1;
fi

# get ssh key password from pass
pass=$(pass ssh/id_rsa)

# check expect is installed
which expect | exit 1;

# check we have a password
pass_leng=$(echo $pass | wc -c)
if [ ${pass_leng} -lt 10 ]; then
  echo "password too short"
  exit 1;
else
  # start ssh-agent
  eval `ssh-agent`
fi

# enter ssh-key password into agent
expect << EOF
  spawn ssh-add /home/pi/.ssh/id_rsa
  expect "Enter passphrase for /home/pi/.ssh/id_rsa:"
  send "$pass\r"
  expect eof
EOF

pass="x";

# connect to host
ssh $1;

# close ssh-agent
eval `ssh-agent -k`

echo done;
