#!/bin/bash
#
# name: vault_pass.sh
# desc: provide vault password. Run automatically by ansible, specified in ansible.cfg
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
  /etc/ansible/facts.d/vagrantvm.fact | grep boxbuild_id > /dev/null 2>&1
  if [ $? -eq 1 ]; then
    echo "ERROR: missing vagrantvm";
    exit 1;
  fi
  # check if keys in place (new, or restored)
  cat /etc/ansible/facts.d/keysandconf.fact | grep true > /dev/null 2>&1
  if [ $? -eq 1 ]; then
    echo "ERROR: missing keysandconf";
    exit 1;
  fi
fi

#-------------------------------------------------------------------------------

case "$rpi_hw" in
  rpideployer)
  cat /mnt/ramstore/data/.vaultpassword || exit 1;
  ;;
  vmdeployer)
  /usr/bin/pass ansible/vault/current || exit 1;
  ;;
  *)
  echo "ERROR: keys not setup"
  exit 1
esac

#-------------------------------------------------------------------------------
