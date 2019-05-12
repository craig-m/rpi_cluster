#!/bin/bash

# do not run this as root
if [[ root = "$(whoami)" ]]; then
  echo "ERROR: do not run as root";
  exit 1;
fi

gunicorn omegapyapi:app \
  --pid /app/pyapi-gunicorn.pid \
  --bind unix:/app/omegapyapi.socket \
  --bind 0.0.0.0:8382 \
  --workers 2 --preload \
  --timeout 30 --backlog 200 \
  --limit-request-fields 50;

# eof
