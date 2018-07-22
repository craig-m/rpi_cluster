#!/bin/bash
# name: run.sh
# desc: run serverspec

# pre-run tasks ----------------------------------------------------------------

if [ ! -f ~/.serverspecinstall ]; then
  echo "first run serverspec/install.sh";
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

# no ld_preload
unset LD_PRELOAD;

# Run tests --------------------------------------------------------------------

rpilogit "started serverspec tests";

source ~/.rvm/scripts/rvm
rvm gemset use serverspec

# remove old reports
rm -rvf -- reports/*.html reports/*.json

# run
#bundle exec rake spec
rake spec

# make reports/index.html file
rake gen_report

#rake pub_report:vbox
#rsync -avr -- reports/* pi@omega.local:/srv/nginx/hugo-site/serverspec/reports

rpilogit "finished serverspec tests";

# EOF --------------------------------------------------------------------------
