#!/bin/sh
# vboxphpcms install.sh

# pre-run tasks ----------------------------------------------------------------

if [ "$(whoami)" != "vagrant" ]; then
  echo "Error: vagrant user only";
  exit 1;
fi

# Only run on stretch
if [ "$(hostname)" != "stretch" ]; then
  echo "Error: vbox only";
  exit 1;
fi

if [ ! -d /var/www/html/ ]; then
  echo "Error: install path missing";
  exit 1;
fi

# check vagrantvm (created by vagrantfile_root.sh)
/etc/ansible/facts.d/vagrantvm.fact | grep boxbuild_id || exit 1;

# move to dir script is running from
cd "$(dirname "$0")"

rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}

rpilogit "starting vboxphpcms install.sh";

# Install composer + deps ------------------------------------------------------

if [ ! -f /opt/cluster/bin/composer.phar ]; then

  # https://getcomposer.org/doc/faqs/how-to-install-composer-programmatically.md
  EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig)
  php -r "copy('https://getcomposer.org/installer', '/home/$USER/tmp/composer-setup.php');"
  ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', '/home/$USER/tmp/composer-setup.php');")
  if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]
  then
    >&2 echo 'ERROR: Invalid installer signature'
    rm /home/$USER/tmp/composer-setup.php
    exit 1
  fi

  echo "call /composer-setup.php"
  php /home/$USER/tmp/composer-setup.php --quiet --install-dir=/opt/cluster/bin/
  rm -v /home/$USER/tmp/composer-setup.php

fi

# installs requirements listed in composer.json
echo "composer.phar install"
if [ ! -d /var/www/vendor/ ]; then
  mkdir -v /var/www/vendor/
fi
export COMPOSER_VENDOR_DIR="/var/www/vendor/"
php /opt/cluster/bin/composer.phar install
sleep 1s;

# Run yarn ---------------------------------------------------------------------

echo "yarn install"
if [ ! -d /var/www/html/node_modules/ ]; then
  mkdir -vp /var/www/html/node_modules/
fi
yarn install --modules-folder=/var/www/html/node_modules/
sleep 1s;

# http files -------------------------------------------------------------------

# copy code
rsync -a /home/vagrant/rpi_cluster/vagrantvm/vboxphpcms/inc_mysql.php /var/www/inc_mysql.php
rsync -a /home/vagrant/rpi_cluster/vagrantvm/vboxphpcms/inc_vboxphpcms.php /var/www/inc_vboxphpcms.php
rsync -a /home/vagrant/rpi_cluster/vagrantvm/vboxphpcms/html/ /var/www/html/

# copy MD Doc files
mkdir -pv /var/www/md/
cp -v -- /home/vagrant/rpi_cluster/readme.md /var/www/md/rpi_readme.md
cp -v -- /home/vagrant/rpi_cluster/doc/readme.md /var/www/md/doc_readme.md
cp -v -- /home/vagrant/rpi_cluster/vagrantvm/readme.md /var/www/md/vagrant_readme.md
chmod -v 755 /var/www/md/
mkdir -pv /var/www/html/pub/doc
rsync -a /home/vagrant/rpi_cluster/doc/ /var/www/html/pub/doc/

toilet -f letter --filter border:metal 'b33ry.clust0r' --html > /var/www/html/pub/B3rryClust0r.html

rpilogit "finished vboxphpcms install.sh";

# EOF
