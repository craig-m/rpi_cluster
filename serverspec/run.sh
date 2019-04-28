#!/bin/bash
# name: run.sh
# desc: run serverspec

# check env --------------------------------------------------------------------

if [ ! -f ~/.serverspecinstall ]; then
  echo "first run serverspec/install-serverspec.sh";
  exit 1;
fi

# check executed as non-root user
if [[ root = "$(whoami)" ]]; then
  echo "Error: do not run as root";
  exit 1;
fi

rpilogit () {
	echo -e "rpicluster: $1 \\n";
	logger -t rpicluster "$1";
}

# reset path
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"


# Run tests --------------------------------------------------------------------
start_time=$(date)

rpilogit "started serverspec tests at ${start_time}";

# ruby env
source ~/.rvm/scripts/rvm
rvm gemset use serverspec

# get password from pass
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

# ssh add key with password
expect << EOF
  spawn ssh-add /home/pi/.ssh/id_rsa
  expect "Enter passphrase for /home/pi/.ssh/id_rsa:"
  send "$pass\r"
  expect eof
EOF

pass="x";

# remove old reports
rm -rf -- reports/*.html reports/*.json

echo -e "running rake \n"

# run
#bundle exec rake spec
rake -j 10 spec


# close ssh-agent
eval `ssh-agent -k`


# make reports/index.html file
rake gen_report

fin_time=$(date)
rpilogit "finished serverspec tests at ${fin_time}";

# EOF --------------------------------------------------------------------------
