#!/bin/bash

rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}

rpilogit "started rm_all_images.sh";

# stop all
docker stop $(/usr/bin/sudo docker ps -a -q)

# Delete all containers
docker rm $(/usr/bin/sudo docker ps -a -q)

# Delete all images (forced)
docker rmi -f $(/usr/bin/sudo docker images -q)

rpilogit "finished rm_all_images.sh - all docker containers deleted";
