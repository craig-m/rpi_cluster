#!/bin/bash

/usr/bin/pass ansible/vault/current

if [ $? -eq 1 ]; then
  echo "ERROR: missing ansible vault pass";
  exit 1;
fi
