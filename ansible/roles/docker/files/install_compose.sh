#!/bin/bash

rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}


if [ ! -d /opt/cluster/docker/compose ]; then
  mkdir -pv /opt/cluster/docker/compose
fi

cd /opt/cluster/docker/compose || exit 1;

if [ ! -d /opt/cluster/docker/compose/venv/ ]; then
  /usr/local/bin/virtualenv --no-site-packages venv;

  source /opt/cluster/docker/compose/venv/bin/activate || exit 1;

  pip install docker-compose
  docker-compose --version
  if [ $? -eq 0 ]; then
  	rpilogit "installed docker-compose"
  else
    rpilogit "error installing docker-compose"
  	exit 1;
  fi
fi
