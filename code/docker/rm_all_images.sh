#!/bin/bash

# stop all
docker stop $(sudo docker ps -a -q)

# Delete all containers
docker rm $(sudo docker ps -a -q)

# Delete all images (forced)
docker rmi -f $(sudo docker images -q)
