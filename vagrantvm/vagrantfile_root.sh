#!/bin/bash
# name: vagrantfile_root.sh
# desc: Runs on Vagrant Provision, as root user. Install all dependencies.
# output logged to ~/vagrantfile.sh.log

# pre-run checks and info ------------------------------------------------------

# send output to screen
set -o verbose

# only run Vagrantfile.sh as root
if [[ root != "$(whoami)" ]]; then
  echo "Error: requires root";
  exit 1;
fi

# Only run Vagrantfile.sh on Debian stretch
if [[ stretch != "$(hostname)" ]]; then
  echo "Error: stretch vbox only";
  exit 1;
fi

# log all output from this script
exec > >(tee /home/vagrant/vagrantfile.sh.log)
exec 2>&1

# script info
echo -e "Vagrantfile.sh starting";
script_name=$(readlink -f ${BASH_SOURCE[0]});
script_pwd=$(pwd);

# log function
rpilogit () {
	echo -e "rpicluster: $1";
	logger -t rpicluster "$1";
}

myoutput="started $script_name with pid $BASHPID from $script_pwd";
rpilogit "$myoutput";

# run before?
if [ ! -f /home/Vagrantfile.sh.txt ]; then
  echo -e "Frist time running - new box!";
  touch /home/Vagrantfile.sh.txt;
  chmod 444 /home/Vagrantfile.sh.txt;
  firtrun="true";
  sleep 2s;
fi

# no LD_PRELOAD
unset LD_PRELOAD

# does not exist on fresh vanilla x86 Debian install
if [ -f /etc/ld.so.preload ]; then
  echo "Error: ld.so.preload should not exist";
  exit 1;
fi

# Remount /proc with hidepid option to hide processes from other users
/usr/bin/sudo mount -o remount,rw,hidepid=2 /proc

# kernel info
uname -a;

# apt packages -----------------------------------------------------------------

# update/upgrade packages
export DEBIAN_FRONTEND=noninteractive;
apt-get update;
sleep 1s;
apt-get upgrade -y -q;
sleep 1s;

# install packages
apt-get install -y -q \
  apt-transport-https apt-file aptitude apparmor apparmor-utils wipe secure-delete \
  build-essential dos2unix git autoconf automake libtool bison net-tools htop \
  gpgv2 pwgen sshpass keychain stow pass dosfstools libsqlite3-dev sqlite3 libgmp-dev \
  xsltproc multitail ccze parted libffi-dev libssl-dev libyaml-dev multistrap \
  libgdbm-dev libncurses5-dev python-pip python-dev libpython-all-dev screen \
  nftables iptables-nftables-compat arptables ebtables iptables-nftables-compat \
  uuid uuid-dev;

apt-get install -y -q \
  monitoring-plugins-common monitoring-plugins-basic netcat-traditional \
  tcpdump lynx telnet wget curl alpine hydra socat sshfs nmap;

# Test programs were installed and are now in our path
# ( ref http://wiki.bash-hackers.org/scripting/style )
my_needed_commands="pass stow sshpass screen gpg2 nmap htop tcpdump wget curl"
missing_counter=0
for needed_command in $my_needed_commands; do
  if ! hash "$needed_command" >/dev/null 2>&1; then
    printf "Command not found in PATH: %s\n" "$needed_command" >&2
    ((missing_counter++))
  fi
done
if ((missing_counter > 0)); then
  printf "Minimum %d requirement missing from PATH, aborting\n" "$missing_counter" >&2
  exit 1
fi

# System -----------------------------------------------------------------------

# grub.d apparmor config
mkdir /etc/default/grub.d
echo 'GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT apparmor=1 security=apparmor"' \
  | sudo tee /etc/default/grub.d/apparmor.cfg;

update-grub;
ulimit -c ulimited;
aa-status | grep module;

# hide processes from other users
mount -o remount,rw,hidepid=2 /proc

# LAMP -------------------------------------------------------------------------

# Apache + PHP install
apt-get -y -q install \
  apache2 apache2-doc libapache2-mod-php7.0 php-pear \
  php7.0-mcrypt php7.0-mbstring php7.0-cli php7.0-mysql \
  php7.0-gd php7.0-curl php7.0-sqlite3;

# get PHP version
php7.0 --version || exit 1;

# Enable + Start Apache2
systemctl enable apache2.service;
systemctl start apache2.service;
sleep 2s;

# -- .php start --
cat > /var/www/html/phpinfo.php << EOF
<?php
  phpinfo();
?>
EOF
# -- .php stop --

# www file perms
rm -v -- /var/www/html/index.html;
chown -v vagrant:vagrant /var/www/ /var/www/html;
chmod -v 775 /var/www/ /var/www/html;
chmod -v 644 /var/www/html/phpinfo.php;
sleep 2s;

# Check http server
/usr/lib/nagios/plugins/check_http -I localhost -p 80 -u /phpinfo.php || echo "ERROR phpinfo page down";
/usr/lib/nagios/plugins/check_procs -C apache2 -c2:10 || exit 1;

# MariaDB server install
debconf-set-selections <<< "mariadb-server-10.1 mysql-server/root_password password 5up3rcse4devs4ap23";
debconf-set-selections <<< "mariadb-server-10.1 mysql-server/root_password_again password 5up3rcse4devs4ap23";
apt-get install -y -q mariadb-server-10.1;
sleep 3s;

# Check mysqld up
/usr/lib/nagios/plugins/check_procs -C mysqld -w 1:2 -c 1:2 || exit 1;

# DB schema import
if [ ! -f /root/setup_db.sql ]; then

  # generate a new random password for the DB
  thenewsqlpw=$(pwgen -s -1 20)

  # store in /root/.mariadbpw
  touch -f /root/.mariadbpw
  echo "${thenewsqlpw}" > /root/.mariadbpw
  chmod 400 /root/.mariadbpw

  # create sql script
# -- .sql start --
cat > /root/setup_db.sql << EOF
-- php db
create database vagrantdb;
show databases;
create user vphpcms;
grant all on vagrantdb.* to 'vphpcms'@'localhost' identified by '${thenewsqlpw}';
-- dev1 db
create database dev1;
-- reload privs
FLUSH PRIVILEGES;
EOF
# -- .sql stop --

  # run the setup_db.sql script
  mysql -uroot < /root/setup_db.sql;

  # log
  rpilogit "imported setup_db.sql";
fi

sleep 2s;

# folders / files  etc ---------------------------------------------------------

# create a 6MB tmpfs
if [ ! -f /mnt/ramstore/data/test.txt ]; then
  mkdir /mnt/ramstore;
  mount -t tmpfs -o size=6m tmpfs /mnt/ramstore;
  mkdir /mnt/ramstore/data;
  # these files exist in Volatile memory!
  touch /mnt/ramstore/data/test.txt
  chown vagrant:vagrant /mnt/ramstore/data;
  chmod 700 /mnt/ramstore/data;
  rpilogit "created /mnt/ramstore/data";
fi

# /etc/ansible
mkdir -pv /etc/ansible/facts.d/;
chown -Rv vagrant:vagrant /etc/ansible;

# /var/log/ansible
mkdir -pv /var/log/ansible/;
chown -v vagrant:vagrant /var/log/ansible/;

# /var/run/rpiclust/
mkdir -pv /var/run/rpiclust/
chown -v vagrant:vagrant /var/run/rpiclust/

# finish up --------------------------------------------------------------------

updatedb;
apt-file update;
rm -f -- /var/cache/apt/archives/*.deb;
sleep 2s;

# note any SETUID files
find / -user root -perm -4000 -exec ls -ldb {} \; > /root/setuid_list.txt

# check process count
echo "check process count";
/usr/lib/nagios/plugins/check_procs -w 200 -c 300;

# check disk use
echo "check disk usage";
/usr/lib/nagios/plugins/check_disk -x /dev/sda1;

# set ansible facts
if [ ! -f /etc/ansible/facts.d/vagrantvm.fact ]; then

  # generate an ID for this VM installation
  boxbuild_id=$(uuid)

  # -- file start --
cat > /etc/ansible/facts.d/vagrantvm.fact << EOF
#!/bin/bash
echo '{ "vagrantvm" : "true", "boxbuild_id": "${boxbuild_id}" }';
EOF
  # -- file stop --

  # set executable
  chmod 755 /etc/ansible/facts.d/vagrantvm.fact;
fi

# done
echo "Vagrantfile.sh ran" >> /home/Vagrantfile.sh.txt
rpilogit "Vagrantfile.sh finished OK";

# EOF --------------------------------------------------------------------------
