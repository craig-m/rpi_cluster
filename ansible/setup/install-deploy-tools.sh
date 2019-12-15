#!/bin/bash
#
# name: install-deploy-tools.sh
#
# desc: install tools in requirements.txt (ansible etc), and packages from apt.
# This is only run on the deployer R-Pi.

# functions ---------------------------------------------------------------------

# log
rpilogit () {
	echo -e "rpicluster: $1 \\n";
	logger -t rpicluster "$1";
}

# pre-run sanity checks --------------------------------------------------------

# do not run this script as root
if [[ root = "$(whoami)" ]]; then
  echo "ERROR: do not run as root";
  exit 1;
fi

# exit on use of uninitialized var
set -u

# test /usr/bin/sudo <cmd> works OK
/usr/bin/sudo id | grep --quiet "uid=0(root)" || { rpilogit "ERROR can not sudo"; exit 1; }

# only allow one copy of this script to execute at a time
pidof -o %PPID -x "$0" >/dev/null && echo "ERROR: $0 already running." && exit 1;


# Collect info -----------------------------------------------------------------

# output/log function

# get the name of this script
script_name=$(readlink -f "${BASH_SOURCE[0]}")

# get line count of this script
scriptlines=$(wc -l "${script_name}" | awk '{print $1}')

# output/log info
rpilogit "**** install deploy tools - in only ${scriptlines} lines of bash! PID $BASHPID ****";

# get SHA256 sum of this file
scriptshasum=$(sha256sum "${script_name}")
rpilogit "$scriptshasum";

# check if running from an interactive shell
if [ -t 1 ]; then
  rpilogit "run from interactive shell";
else
  rpilogit "run from NON-interactive shell";
  # notify any logged in users:
  #wall "rpicluster: started ";
fi

# test if R-Pi Hardware
if [ "pi" = "$(whoami)" ] && [ "arm" = "$(uname -m | cut -c 1-3)" ]; then
  # The "b8:27:eb" prefix belongs to the Raspberry Pi Foundation.
  rpi_mac=$(ip addr show | grep 'b8:27:eb:' | awk '{print $2'} | wc -c);
  if [ "$rpi_mac" -eq "18" ]; then
    rpilogit "running on R-Pi Hardware";
  else
    rpilogit "unsupported environment!";
    exit 1;
  fi
fi

# wait
sleep 2s;


# Environment ------------------------------------------------------------------

# Remount /proc with hidepid option to hide processes from other users
/usr/bin/sudo mount -o remount,rw,hidepid=2 /proc

# reset path
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# for apt-get
export DEBIAN_FRONTEND=noninteractive;

# make a directory under /tmp/tmp.xxxxxxxxxx (with each run)
bs_dep_temp=$(mktemp -d)
rpilogit "My temp dir is: ${bs_dep_temp}";

# create ~/.rpibs/ folder
if [ ! -d ~/.rpibs/ ]; then
  mkdir ~/.rpibs/
  chmod 770 ~/.rpibs/
fi

# stop "'action 17' suspended" error message in syslog
# https://github.com/RPi-Distro/repo/issues/28
/usr/bin/sudo sed -i '/# The named pipe \/dev\/xconsole/,$d' /etc/rsyslog.conf;

# get kernel config
if [ ! -f ~/.rpibs/kern.config ]; then
  /usr/bin/sudo modprobe configs;
  gunzip -dc /proc/config.gz > ~/.rpibs/kern.config
fi

# working dir
CDPATH=~/rpi_cluster
cd ansible || exit 1;

# wait
sleep 2s;

# create a 2MB tmpfs
if [ ! -f /mnt/ramstore/data/test.txt ]; then
  /usr/bin/sudo mkdir /mnt/ramstore;
  /usr/bin/sudo mount -t tmpfs -o size=2m tmpfs /mnt/ramstore;
  /usr/bin/sudo mkdir /mnt/ramstore/data;
  # these files exist in Volatile memory!
  /usr/bin/sudo touch /mnt/ramstore/data/test.txt
  /usr/bin/sudo chown pi:pi /mnt/ramstore/data;
  /usr/bin/sudo chmod 700 /mnt/ramstore/data;
  rpilogit "created /mnt/ramstore/data";
fi
if [ ! -f /mnt/ramstore/data/test.txt ]; then
  rpilogit "error: ramstore test.txt missing";
  exit 1;
fi


# Install / Upgrade base packages ----------------------------------------------

if [ ! -f ~/.rpibs/rpibs_packages ]; then
  # update package list
  /usr/bin/sudo apt-get update;
  # install packages
  rpilogit "install some apt packages";
  /usr/bin/sudo apt-get -q install -y \
  build-essential autoconf automake aptitude libtool bison flex dos2unix htop jq \
  sshpass scanssh wget curl git rsync vim nano lsof screen tmux pgpgpg bc gawk \
  sshfs tcpdump nmap socat netdiscover sqlite3 pwgen \
  libssl-dev libyaml-dev libgmp-dev libgdbm-dev libffi-dev libpython-all-dev \
  libxml2-dev libxslt1-dev libncurses5-dev libsqlite3-dev \
  monitoring-plugins-common monitoring-plugins-basic inotify-tools unzip pass \
  python-pip python-dev python3-pip python3-dev \
  uuid-runtime uuid reptyr secure-delete mpich alpine shellcheck \
  lynx socat dirmngr mc tftp \
  software-properties-common || { rpilogit "ERROR with apt-get install"; exit 1; }
  sleep 2s;
  # upgrade
  rpilogit "upgrade apt packages";
  /usr/bin/sudo apt-get -q -y upgrade || { rpilogit "ERROR with apt upgrade"; exit 1; }
  # apt cleanup
  /usr/bin/sudo apt clean
  /usr/bin/sudo apt autoremove --purge -y
  # ok
  touch ~/.rpibs/rpibs_packages;
  sleep 2s;
fi

# check all packages current
if /usr/lib/nagios/plugins/check_apt --timeout=45 --list; then
  rpilogit "packages are current"
else
  rpilogit "apt packages need upgrade ERROR"
	exit 1;
fi

# checks (processes are hidden from non-root users)
rpilogit "check host";
/usr/bin/sudo /usr/lib/nagios/plugins/check_procs -w 200 -c 250 --metric=CPU || exit 1;
/usr/bin/sudo /usr/lib/nagios/plugins/check_users -w 10 -c 15 || exit 1;

# haveged - an unpredictable random number generator
if [ ! -f /usr/sbin/haveged ]; then
  rpilogit "install haveged";
  /usr/bin/sudo apt-get install -y haveged;
  /usr/bin/sudo systemctl start haveged.service;
  /usr/bin/sudo systemctl enable haveged.service;
  /usr/bin/sudo /usr/lib/nagios/plugins/check_procs -C haveged 1:3 || exit 1;
  rpilogit "haveged has been installed";
  sleep 2s;
fi


# Install Redis ----------------------------------------------------------------

# Redis server (for Ansible fact cache)
if [ ! -f ~/.rpibs/rpibs_redis ]; then
  rpilogit "installing redis \\n"
  # apt-get install
  /usr/bin/sudo apt-get install -y redis-server;
  # start and enable
  /usr/bin/sudo systemctl start redis-server;
  /usr/bin/sudo systemctl enable redis-server;
  /usr/bin/sudo sysctl vm.overcommit_memory=1;
  sleep 2s;
  # test
  rpilogit "test redis \\n"
  redis-cli -h localhost -p 6379 ping || { rpilogit "ERROR redis ping failed"; exit 1; }
  redis-cli set /rpi/deployer/test test || { rpilogit "ERROR redis test failed"; exit 1; }
  # ok
  touch ~/.rpibs/rpibs_redis;
  redis-server -v >> ~/.rpibs/rpibs_redis;
  sleep 1s;
fi

# check redis running
rpilogit "check_procs redis";
/usr/bin/sudo /usr/lib/nagios/plugins/check_procs -C redis-server -w 1:2 -c 1:2 || exit 1;


# Python tools installation ----------------------------------------------------
# install requirements.txt
PS1=""

# install pip + dependencies and virtualenv
if [ ! -f /usr/local/bin/virtualenv ]; then
  rpilogit "pip install virtualenv"
  # create isolated Python environments with virtualenv.
  # https://pypi.python.org/pypi/virtualenv/
  /usr/bin/sudo pip3 install virtualenv;
  /usr/bin/sudo pip3 install --upgrade setuptools
  sleep 1s;
fi

# create + activate virtual environment
if [ ! -d ~/env/ ]; then
  /usr/local/bin/virtualenv --python=python3.7 --no-site-packages ~/env;
  sleep 1s;
fi

# activate venv
source ~/env/bin/activate || { rpilogit "ERROR activating virtual env"; exit 1; }

# install python packages
stat -t requirements.txt || exit 1;
pip3 install -r requirements.txt
sleep 1s;

# Check programs were installed and are now in our path
# (ref: http://wiki.bash-hackers.org/scripting/style)
my_needed_commands="ansible ansible-lint invoke diceware http py.test nmap screen tmux scanssh vim sshpass"
missing_counter=0
for needed_command in $my_needed_commands; do
  if ! hash "$needed_command" >/dev/null 2>&1; then
    printf "Command not found in PATH: %s\\n" "$needed_command" >&2
    ((missing_counter++))
  fi
done
if ((missing_counter > 0)); then
  printf "Minimum %d requirement missing from PATH, aborting\\n" "$missing_counter" >&2
  exit 1
fi


# Ansible ----------------------------------------------------------------------

# Ansible log dir
if [ ! -d /var/log/ansible/ ]; then
  /usr/bin/sudo mkdir -pv /var/log/ansible/;
  /usr/bin/sudo chown "$USER:$USER" /var/log/ansible/;
fi

# symlink to ansible log
if [ ! -f ~/ansible.log ]; then
  ln -s /var/log/ansible/ansible.log ~/ansible.log
fi

# Ansible etc dir
if [ ! -d /etc/ansible/ ]; then
  rpilogit "creating /etc/ansible dirs";
  /usr/bin/sudo mkdir -pv /etc/ansible/;
  /usr/bin/sudo chmod 750 /etc/ansible/;
  /usr/bin/sudo chown "$USER:$USER" /etc/ansible/;
  mkdir -pv /etc/ansible/facts.d/;
  mkdir -pv /etc/ansible/inventory/;
  mkdir -pv /etc/ansible/group_vars/{all,compute,lanservices}/;
  mkdir -pv /etc/ansible/host_vars/{alpha,beta,psi}/;
fi

# check ansible .cfg
stat -t ansible.cfg || exit 1;
export ANSIBLE_CONFIG="$PWD"

# Load environment variables that inform Ansible to use ARA
# regardless of its location or python version
#source <(python3 -m ara.setup.env)

# check ansible version
if ansible --version; then
  rpilogit "ansible installed";
  sleep 1s;
else
  rpilogit "ERROR installing ansible";
  exit 1;
fi

# Finished ---------------------------------------------------------------------

# -- file start --
cat > /etc/ansible/facts.d/deploytool.fact << EOF
#!/bin/bash
echo '{ "deploytool" : "installed" }';
EOF
# -- file stop --

chmod 755 /etc/ansible/facts.d/deploytool.fact;

# done
touch ~/.rpibs/completed;
echo "${script_name} completed" >> ~/.rpibs/completed
rpilogit "**** finished ****";

#-------------------------------------------------------------------------------
