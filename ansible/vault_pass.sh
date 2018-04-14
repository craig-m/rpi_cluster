#!/bin/bash
# provide vault password. Run automatically by ansible, specified in ansible.cfg

rpi_hw=$(/etc/ansible/facts.d/rpihw.fact | jq '.rpi_hw_mac' | tr -d '"')

case "$rpi_hw" in
  True)
  cat /mnt/ramstore/data/.vaultpassword || exit 1;
  ;;
  False)
  /usr/bin/pass ansible/vault/current || exit 1;
  ;;

  *)
  echo "ERROR: keys not setup"
  exit 1
esac

# EOF
