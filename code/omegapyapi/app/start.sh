#!/bin/bash
# name: start.sh
# desc: run omegapyapi.py

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

# start ------------------------------------------------------------------------

cd /opt/omegapyapi/app/ || exit 1;

source env/bin/activate || exit 1;

logger -t rpicluster "omegapyapi start.sh running gunicorn"

gunicorn omegapyapi:app \
  --pid /opt/omegapyapi/pyapi-gunicorn.pid \
  --bind unix:/opt/omegapyapi/omegapyapi.socket \
  --workers 2 --preload \
  --timeout 30 --backlog 200 \
  --limit-request-fields 50 \
  || echo "ERROR starting gunicorn";

logger -t rpicluster "omegapyapi start.sh ran OK"

# EOF --------------------------------------------------------------------------
