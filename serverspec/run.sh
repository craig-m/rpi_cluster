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
rm -rvf -- reports/192.168.6.*

# run
#bundle exec rake spec
rake spec

# make reports/index.html file
rake gen_report

if [ "$(whoami)" == "vagrant" ]; then
  rake pub_report:vbox
fi

rsync -avr -- reports/* pi@omega.local:/srv/nginx/hugo-site/serverspec/reports

rpilogit "finished serverspec tests";

# EOF --------------------------------------------------------------------------
