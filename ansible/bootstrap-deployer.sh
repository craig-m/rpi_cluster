#!/bin/bash
#
# bootstrap-deployer.sh
#
# Run locally on the VagrantVM and R-Pi deployer (psi). This will setup a new
# system to administrate the cluster from. Will install requirements.txt
# (ansible + fabric etc) and then run play-local-deployer.yml
#
# pre-run sanity checks --------------------------------------------------------

# do not run this script as root
if [[ root = "$(whoami)" ]]; then
  echo "ERROR: do not run as root";
  exit 1;
fi

# test /usr/bin/sudo <cmd> works. Raspbian default. Todo: add sudo pw.
sudo id | grep "uid=0(root)" || exit 1;

# only allow one copy of this script to execute at a time
pidof -o %PPID -x "$0" >/dev/null && echo "ERROR: $0 already running." && exit 1;

# Script info ------------------------------------------------------------------

# output/log function
rpilogit () {
	echo -e "rpicluster: $1 \\n";
	logger -t rpicluster "$1";
}

# get the name of this script
script_name=$(readlink -f "${BASH_SOURCE[0]}")

# get line count of this script
scriptlines=$(cat "${script_name}" | wc -l)

# output/log info
rpilogit "**** Bootstrapping Deployer node, in only ${scriptlines} lines of bash! PID $BASHPID ****";

# get SHA256 sum of this file
scriptshasum=$(sha256sum "${script_name}")
rpilogit "$scriptshasum";

# check if running from an interactive shell
if [ -t 1 ]; then
  rpilogit "run from interactive shell";
else
  rpilogit "run from NON-interactive shell";
  # notify any logged in users:
  wall "rpicluster: started bootstrap-deployer.sh";
fi

# get arch
bs_my_arch=$(uname -m | cut -c 1-3)

# wait
sleep 2s;

# Environment ------------------------------------------------------------------

# reset path
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# for apt-get
export DEBIAN_FRONTEND=noninteractive;

# make a directory under /tmp/tmp.xxxxxxxxxx (with each run)
bs_dep_temp=$(mktemp -d)
rpilogit "My temp dir is: ${bs_dep_temp}";

# ~/.rpibs/ folder
if [ ! -d ~/.rpibs/ ]; then
  mkdir ~/.rpibs/
  chmod 770 ~/.rpibs/
fi

# stop "'action 17' suspended" error message in syslog
# https://github.com/RPi-Distro/repo/issues/28
/usr/bin/sudo sed -i '/# The named pipe \/dev\/xconsole/,$d' /etc/rsyslog.conf;

# Remount /proc with hidepid option to hide processes from other users
/usr/bin/sudo mount -o remount,rw,hidepid=2 /proc

# wait
sleep 2s;

# Install / Upgrade base packages ----------------------------------------------

if [ ! -f ~/.rpibs/rpibs_packages ]; then
  # update package list
  /usr/bin/sudo apt-get update;
  # install packages
  echo -e "rpicluster: Install apt packages";
  /usr/bin/sudo apt-get install -q -y \
  build-essential autoconf automake libtool bison flex dos2unix socat htop \
  sshpass scanssh wget curl git rsync vim nano lsof screen tmux pgpgpg bc gawk \
  sshfs tcpdump nmap netdiscover libncurses5-dev libsqlite3-dev sqlite3 \
  libssl-dev libyaml-dev libgmp-dev libgdbm-dev libffi-dev libpython-all-dev \
  monitoring-plugins-common monitoring-plugins-basic inotify-tools \
  python-pip python-dev uuid-runtime uuid;
  sleep 2s;
  # upgrade
  /usr/bin/sudo apt-get -q -y upgrade || echo "ERROR with apt upgrade";
  # ok
  touch ~/.rpibs/rpibs_packages;
  sleep 2s;
fi

# upgrade firmware in /boot/
if [ ! -f ~/.rpibs/rpibs_firm ]; then
  # this is absent on the Vagrant VM.
  if [ -f /usr/bin/rpi-update ]; then
    echo -e "rpicluster: updating rpi firmware";
    export SKIP_WARNING=1;
    /usr/bin/sudo /usr/bin/rpi-update || echo "ERROR rpi-update failed";
    touch ~/.rpibs/rpibs_firm;
  fi
  sleep 2s;
fi

# checks (processes are hidden from non-root users)
echo -e "rpicluster: check host"
/usr/bin/sudo /usr/lib/nagios/plugins/check_procs -w 20 -c 30 --metric=CPU || exit 1;
/usr/bin/sudo /usr/lib/nagios/plugins/check_users -w 10 -c 15 || exit 1;

# Install Redis ----------------------------------------------------------------

# Redis server (for Ansible fact cache)
if [ ! -f ~/.rpibs/rpibs_redis ]; then
  echo -e "rpicluster: installing redis \\n"
  # apt-get install
  /usr/bin/sudo apt-get install -y redis-server;
  # start and enable
  /usr/bin/sudo systemctl start redis-server;
  /usr/bin/sudo systemctl enable redis-server;
  /usr/bin/sudo sysctl vm.overcommit_memory=1;
  sleep 2s;
  # test
  echo -e "rpicluster: test redis \\n"
  redis-cli -h localhost -p 6379 ping || echo "ERROR redis down";
  redis-cli set /rpi/deployer/test test || echo "ERROR redis down";
  touch ~/.rpibs/rpibs_redis;
  sleep 1s;
fi

# check redis running
echo -e "rpicluster: check_procs redis"
/usr/bin/sudo /usr/lib/nagios/plugins/check_procs -C redis-server -w 1:2 -c 1:2 || exit 1;

# Python tools installation ----------------------------------------------------

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

# install python packages
# activate venv
PS1=""
source ~/env/bin/activate;
stat -t requirements.txt || echo "ERROR Missing requirements.txt!"
pip install -r requirements.txt || echo "ERROR installing requirements.txt";
sleep 1s;

# Check programs were installed and are now in our path
# (ref: http://wiki.bash-hackers.org/scripting/style)
my_needed_commands="ansible fab diceware http testinfra py.test nmap screen tmux scanssh vim sshpass uuid"
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
  /usr/bin/sudo chown "$USER:$USER" /etc/ansible/;
fi

# check ansible .cfg and version
stat -t ansible.cfg || exit 1;
export ANSIBLE_CONFIG="$PWD"
ansible --version || exit 1;
sleep 2s;

# Run Ansible locally on this deployer
ansible-playbook play-deployer.yml -i deploy_local.ini --connection=local --limit "${ansible_inv_limit}"

# dump facts
ansible -i deploy -m setup --tree "${bs_dep_temp}"/facts > /dev/null 2>&1;

# Run testinfra tests on psi rpi -----------------------------------------------

## What is this deployer running on, a VirtualBox or R-Pi?
if [[ pi = "$(whoami)" && "arm" = "${bs_my_arch}" ]]; then
  # get arch
  bs_my_arch=$(uname -m | cut -c 1-3)
  ansible_inv_limit="psi";
  my_deployer_tests="test_rpideployer.py";
  py.test -v testinfra/"${my_deployer_tests}" --junit-xml="${bs_dep_temp}"/testinfra_deployer.xm
fi

# Finish up --------------------------------------------------------------------

# Check ansible.log has no failures from this playbook
myhostname=$(/bin/hostname)
ansible_tasks_ok=$(tail /var/log/ansible/ansible.log -n 5 | grep "${myhostname}" | grep -o "failed=0" | wc -l)

if [[ 1 -eq "$ansible_tasks_ok" ]]; then

  # Ansible playbook ran OK
  redis-cli set /rpi/deployer/bs-script "ok" > /dev/null 2>&1;
  rpilogit "**** bootstrap-deployer.sh ran successfully **** ";

else

  # Ansible playbook FAILED - EXIT
  redis-cli set /rpi/deployer/bs-script "error";
  rpilogit "ERROR setting up deployer ";
  exit 1;

fi

# EOF --------------------------------------------------------------------------
