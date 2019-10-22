#!/bin/bash
# name: install.sh
# desc: install serverspec - http://serverspec.org/

# pre-run tasks ----------------------------------------------------------------

# check executed as non-root user
if [[ root = "$(whoami)" ]]; then
  echo "Error: do not run as root";
  exit 1;
fi

rpilogit () {
	echo -e "rpicluster: $1 \\n";
	logger -t rpicluster "$1";
}


# install ----------------------------------------------------------------------

rpilogit "serverspec install started";

cd ~/rpi_cluster/serverspec || exit 1;

# install Ruby Version Manager
if [ ! -f ~/.rvm/scripts/rvm ]; then
  gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
  # Verify the installer signature (might need `gpg2`), and if it validates run the installer
  gpg --verify rvm-installer.asc && bash rvm-installer stable || echo -e "[*] ERROR: RVM installer "
fi

# activate RVM env
source ~/.rvm/scripts/rvm || echo -e "[*] ERROR: install RVM first "
rvm install ruby --latest || echo -e "[*] ERROR: installing RVM "
rvm use 2.6.0 || echo -e "[*] ERROR: using rvm "

# install ServerSpec
rvm gemset create serverspec
rvm gemset use serverspec
gem install bundle
bundle install || exit 1

chmod -v 755 run.sh

echo -e "[*] rake task list: "
rake --tasks || exit 1

# finish up --------------------------------------------------------------------

touch ~/.serverspecinstall
echo "install-serverspec.sh completed" > ~/.serverspecinstall

rpilogit "serverspec install finished";

# EOF --------------------------------------------------------------------------
