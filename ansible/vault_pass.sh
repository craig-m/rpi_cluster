#!/bin/bash
# https://www.passwordstore.org/

/usr/bin/pass ansible/vault/current

if [ $? -eq 1 ]; then
  echo "ERROR: missing ansible vault pass";
  exit 1;
fi
