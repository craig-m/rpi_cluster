#!/bin/bash

imgname="rpiwwwpyapp"

ID_IMAGE="$(/usr/bin/sudo -u $USER docker images | grep $imgname | head -n 1 | wc -l)"

# dockerfile build
echo "[*] Building image"
docker build -t $imgname . || echo "[x] failed to build image"

# test
echo "[.] -- test image --"
docker run --rm -ti $imgname id
docker run --rm -ti $imgname hostname
echo "[.] -- test finished --"

# Save image as .tar
echo "[*] Saving image"
docker save -o $imgname.tar $imgname
ls -lah $imgname.tar

DOCKER_IMG_ID=$(docker images | grep $imgname | awk '{print $3}')

docker image rm $imgname

docker image ls

echo ${DOCKER_IMG_ID};

# EOF
