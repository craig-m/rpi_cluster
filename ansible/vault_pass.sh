#!/bin/bash

# script to get ansible vault password, this script is called from
# the vault_password_file option in ansible.cfg
#
# instead of using --vault-password-file with ansiblie on command line.

# https://www.passwordstore.org/

/usr/bin/pass ansible/vault/current

if [ $? -eq 1 ]; then
  echo "ERROR: missing ansible vault pass";
  exit 1;
fi
