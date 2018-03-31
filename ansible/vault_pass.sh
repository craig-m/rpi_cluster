#!/bin/bash

#logger -t rpicluster "valut_pass.sh running"

if [ -f /mnt/ramstore/data/.vaultpassword ]; then

  cat /mnt/ramstore/data/.vaultpassword

else

  /usr/bin/pass ansible/vault/current || exit 1;

fi

# EOF
