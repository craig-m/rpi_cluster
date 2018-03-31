#!/bin/bash
# name: app_install.sh
# desc: install omegapyapi.py virtualenv

# pre-run checks ---------------------------------------------------------------

# run by omegapyapi user only
if [[ omegapyapi != "$(whoami)" ]]; then
  echo "Error: requires omegapyapi user";
  exit 1;
fi

if [ ! -d /opt/omegapyapi/app/ ]; then
  echo "Error: app path missing";
  exit 1;
fi

# install ----------------------------------------------------------------------

cd /opt/omegapyapi/app/;

logger -t rpicluster "omegapyapi app_install.sh starting ";

echo "[*] install virtualenv";
pip install virtualenv;

echo "[*] virtualenv";
virtualenv --no-site-packages env || exit 1;

echo "[*] activate";
source env/bin/activate || exit 1;

echo "[*] install requirements.txt";
pip install -r requirements.txt || exit 1;

logger -t rpicluster "omegapyapi app_install.sh finished ";

# EOF --------------------------------------------------------------------------
