#!/bin/bash

cd ..

docker build -t adminclient -f  admin-client/Dockerfile .

docker run --interactive --tty adminclient
