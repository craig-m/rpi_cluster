#!/bin/bash
#
# name: install-deploy-tools.sh
# desc: install tools in requirements.txt (ansible etc), and packages from apt.

# pre-run sanity checks --------------------------------------------------------

# do not run this script as root
if [[ root = "$(whoami)" ]]; then
  echo "ERROR: do not run as root";
  exit 1;
fi

# test /usr/bin/sudo <cmd> works OK
/usr/bin/sudo id | grep "uid=0(root)" > /dev/null 2>&1 || exit 1;

# only allow one copy of this script to execute at a time
pidof -o %PPID -x "$0" >/dev/null && echo "ERROR: $0 already running." && exit 1;

# Collect info -----------------------------------------------------------------

# output/log function

# log
rpilogit () {
	echo -e "rpicluster: $1 \\n";
	logger -t rpicluster "$1";
}

# get the name of this script
script_name=$(readlink -f "${BASH_SOURCE[0]}")

# get line count of this script
scriptlines=$(cat "${script_name}" | wc -l)

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
  rpi_mac=$(ip addr show eth0 | grep 'b8:27:eb:' | awk '{print $2'} | wc -c);
  if [ $rpi_mac -eq "18" ]; then
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

CDPATH=~/rpi_cluster
cd ansible;

# wait
sleep 2s;

# create a 2MB tmpfs
if [ ! -f /mnt/ramstore/data/test.txt ]; then
  sudo mkdir /mnt/ramstore;
  sudo mount -t tmpfs -o size=2m tmpfs /mnt/ramstore;
  sudo mkdir /mnt/ramstore/data;
  # these files exist in Volatile memory!
  sudo touch /mnt/ramstore/data/test.txt
  sudo chown pi:pi /mnt/ramstore/data;
  sudo chmod 700 /mnt/ramstore/data;
  rpilogit "created /mnt/ramstore/data";
fi

# Install / Upgrade base packages ----------------------------------------------

if [ ! -f ~/.rpibs/rpibs_packages ]; then
  # update package list
  /usr/bin/sudo apt-get update;
  # install packages
  rpilogit "rpicluster: Install apt packages";
  /usr/bin/sudo apt-get install -q -y \
  build-essential autoconf automake libtool bison flex dos2unix socat htop jq \
  sshpass scanssh wget curl git rsync vim nano lsof screen tmux pgpgpg bc gawk \
  sshfs tcpdump nmap netdiscover libncurses5-dev libsqlite3-dev sqlite3 pwgen \
  libssl-dev libyaml-dev libgmp-dev libgdbm-dev libffi-dev libpython-all-dev \
  monitoring-plugins-common monitoring-plugins-basic inotify-tools unzip pass \
  python-pip python-dev uuid-runtime uuid reptyr secure-delete mpich alpine \
  telnet lynx socat dirmngr;
  sleep 2s;
  # upgrade
  /usr/bin/sudo apt-get -q -y upgrade || rpilogit "ERROR with apt upgrade";
  # ok
  touch ~/.rpibs/rpibs_packages;
  sleep 2s;
fi

# upgrade firmware in /boot/
if [ ! -f ~/.rpibs/rpibs_firm ]; then
  if [ -f /usr/bin/rpi-update ]; then
    rpilogit "updating rpi firmware";
    export SKIP_WARNING=1;
    /usr/bin/sudo /usr/bin/rpi-update || rpilogit "ERROR rpi-update failed";
    touch ~/.rpibs/rpibs_firm;
  fi
  sleep 2s;
fi

# checks (processes are hidden from non-root users)
rpilogit "rpicluster: check host"
/usr/bin/sudo /usr/lib/nagios/plugins/check_procs -w 200 -c 250 --metric=CPU || exit 1;
/usr/bin/sudo /usr/lib/nagios/plugins/check_users -w 10 -c 15 || exit 1;

# haveged - an unpredictable random number generator
/usr/bin/sudo apt-get install -y haveged;
/usr/bin/sudo systemctl start haveged.service;
/usr/bin/sudo systemctl enable haveged.service;
/usr/bin/sudo /usr/lib/nagios/plugins/check_procs -C haveged 1:3 || exit 1;

# Install Redis ----------------------------------------------------------------

# Redis server (for Ansible fact cache)
if [ ! -f ~/.rpibs/rpibs_redis ]; then
  rpilogit "rpicluster: installing redis \\n"
  # apt-get install
  /usr/bin/sudo apt-get install -y redis-server;
  # start and enable
  /usr/bin/sudo systemctl start redis-server;
  /usr/bin/sudo systemctl enable redis-server;
  /usr/bin/sudo sysctl vm.overcommit_memory=1;
  sleep 2s;
  # test
  rpilogit "rpicluster: test redis \\n"
  redis-cli -h localhost -p 6379 ping || echo "ERROR redis down";
  redis-cli set /rpi/deployer/test test || echo "ERROR redis down";
  touch ~/.rpibs/rpibs_redis;
  sleep 1s;
fi

# check redis running
rpilogit "rpicluster: check_procs redis"
/usr/bin/sudo /usr/lib/nagios/plugins/check_procs -C redis-server -w 1:2 -c 1:2 || exit 1;

# Python tools installation ----------------------------------------------------
# install requirements.txt

# install pip + dependencies and virtualenv
if [ ! -f /usr/local/bin/virtualenv ]; then
  # create isolated Python environments with virtualenv.
  # https://pypi.python.org/pypi/virtualenv/
  /usr/bin/sudo pip install virtualenv;
  sleep 1s;
fi

# create + activate virtual environment
if [ ! -d ~/env/ ]; then
  virtualenv --no-site-packages ~/env;
  sleep 1s;
fi

# install python packages in venv
PS1=""
source ~/env/bin/activate;
stat -t requirements.txt || exit 1;
pip install -r requirements.txt
sleep 1s;

# Check programs were installed and are now in our path
# (ref: http://wiki.bash-hackers.org/scripting/style)
my_needed_commands="ansible fab diceware http testinfra py.test nmap screen tmux scanssh vim sshpass"
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

# Ansible etc dir
if [ ! -d /etc/ansible/ ]; then
  /usr/bin/sudo mkdir -pv /etc/ansible/;
  /usr/bin/sudo chmod 750 /etc/ansible/;
  /usr/bin/sudo chown "$USER:$USER" /etc/ansible/;
  mkdir -pv /etc/ansible/facts.d/;
  mkdir -pv /etc/ansible/group_vars/{all,compute,lanservices}/;
  mkdir -pv /etc/ansible/host_vars/{alpha,beta,omega,psi}/;
fi

# -- file start --
cat > /etc/ansible/facts.d/deploytool.fact << EOF
#!/bin/bash
echo '{ "deploytool" : "installed" }';
EOF
# -- file stop --

chmod 755 /etc/ansible/facts.d/deploytool.fact


# check ansible .cfg and version
stat -t ansible.cfg || exit 1;
export ANSIBLE_CONFIG="$PWD"
ansible --version || exit 1;
sleep 1s;

# Make Ansible use the ARA callback plugin regardless of python version
export ANSIBLE_CALLBACK_PLUGINS="$(python -c 'import os,ara; print(os.path.dirname(ara.__file__))')/plugins/callbacks";

touch ~/.rpibs/completed;
rpilogit "**** finished ****";

#-------------------------------------------------------------------------------
