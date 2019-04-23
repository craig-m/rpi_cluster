#!/bin/bash
# name: run.sh
# desc: run serverspec

# pre-run tasks ----------------------------------------------------------------

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

source ~/.rvm/scripts/rvm
rvm gemset use serverspec

# remove old reports
rm -rf -- reports/*.html reports/*.json

# run
#bundle exec rake spec
rake -j 10 spec

# make reports/index.html file
rake gen_report

fin_time=$(date)
rpilogit "finished serverspec tests at ${fin_time}";

# EOF --------------------------------------------------------------------------
