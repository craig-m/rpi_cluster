#!/bin/bash
#
# name: setup-deployer.sh
# desc: run ansible playbooks locally, sets up ~/.ssh/config
# Run on vagrant VM and the R-Pi psi.

# pre-run checks ---------------------------------------------------------------

# get arch
bs_my_arch=$(uname -m | cut -c 1-3)

# check if R-Pi
if [ "pi" = "$(whoami)" ] && [ "arm" = "${bs_my_arch}" ]; then
  rpi_mac=$(ip addr show eth0 | grep 'b8:27:eb:' | awk '{print $2'} | wc -c);
  if [ $rpi_mac -eq "18" ]; then
    rpi_hw="rpideployer";
  else
    rpi_hw="error";
  fi
fi

# check if VagrantVM
if [ "vagrant" = "$(whoami)" ] && [ "x86" = "${bs_my_arch}" ]; then
  rpi_hw="vmdeployer";
  # check vagrantvm (created by vagrantfile_root.sh)
  /etc/ansible/facts.d/vagrantvm.fact | grep boxbuild_id > /dev/null 2>&1 || exit 1;
  if [ ! -f ~/.ansible_local ]; then
  # inventory for localhost
cat > ~/.ansible_local << EOF
[deploy]
stretch ansible_host=stretch.local rpi_ip="10.0.2.15" rpi_racked="vm" rpi_mac="zz:zz:zz:zz:zz:zz"
EOF
  fi
fi

# log
rpilogit () {
	echo -e "rpicluster: $1 \\n";
	logger -t rpicluster "$1";
}

#-------------------------------------------------------------------------------

source ~/env/bin/activate

case "$rpi_hw" in
  rpideployer)
  rpilogit 'Setting up psi';
  ansible-playbook --connection=local play-rpi-deployer.yml
  ansible-playbook -e "runtherole=group-deployer-ssh-client" single-role.yml --connection=local
  ;;
  vmdeployer)
  rpilogit 'Setting up Deployer VM';
  ansible-playbook --connection=local play-vbox-deployer.yml -i ~/.ansible_local
  ansible-playbook -e "runtherole=group-deployer-ssh-client" single-role.yml --connection=local
  ;;
  *)
  rpilogit "ERROR: keys not setup";
  exit 1
esac

#-------------------------------------------------------------------------------
