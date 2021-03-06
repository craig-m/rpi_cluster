#!/bin/bash

echo "start.sh: starting gunicorn";

# do some sanity checks before starting gunicorn

if [[ rpyapi = "$(whoami)" ]]; then
  echo "running as rpyapi - good";
else
  echo "ERROR: not running as rpyapi";
  exit 1;
fi

if [ ! -f /app/rpyapi.py ]; then
  echo "ERROR: missing app";
  exit 1;
fi

if [ ! -d /logs/ ]; then
  echo "ERROR: missing /logs/ dir";
  exit 1;
fi


# check we have python version 3
python --version | awk '{print $2}' | cut -c1-1 | grep 3 || exit 1


gunicorn rpyapi:app \
  --pid /app/pyapi-gunicorn.pid \
  --bind unix:/app/rpyapi.socket \
  --bind 0.0.0.0:8382 \
  --workers 2 \
  --preload \
  --timeout 30 \
  --backlog 200 \
  --limit-request-fields 50 \
  --log-file=/logs/gunicorn.log

# eof
