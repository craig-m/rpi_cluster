#!/bin/bash

source /opt/cluster/docker/compose/venv/bin/activate || exit 1;

docker-compose up;
