#!/bin/bash

echo "start.sh: starting gunicorn";

if [[ root = "$(whoami)" ]]; then
  echo "ERROR: do not run as root";
  exit 1;
fi

if [ ! -f /app/omegapyapi.py ]; then
  echo "ERROR: missing app";
  exit 1;
fi

if [ ! -d /logs/ ]; then
  echo "ERROR: missing /logs/ dir";
  exit 1;
fi

gunicorn omegapyapi:app \
  --pid /app/pyapi-gunicorn.pid \
  --bind unix:/app/omegapyapi.socket \
  --bind 0.0.0.0:8382 \
  --workers 2 \
  --preload \
  --timeout 30 \
  --backlog 200 \
  --limit-request-fields 50 \
  --log-file=/logs/gunicorn.log \
  --access-logfile=/logs/gunicorn-access.log \
  --daemon;

# keep container from exiting:
tail -f /logs/gunicorn-access.log -f /logs/gunicorn.log


# eof
