#!/bin/bash
logger -t rpicluster "valut_pass.sh running"

if [ -f .vaultpassword ]; then
  cat .vaultpassword
else
  /usr/bin/pass ansible/vault
fi
# EOF
