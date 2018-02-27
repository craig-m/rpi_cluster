#!/bin/bash

runas=$(id | cut -c5-5)
if [ $runas -eq "0" ]; then
  echo -e "Do NOT run this as root";
  exit 1;
fi

script_name=$(readlink -f ${BASH_SOURCE[0]})
myoutput="rpicluster: started $script_name"
echo -e $myoutput
logger -t rpicluster $myoutput
pwd

virtualenv --no-site-packages env

source ./env/bin/activate

pip install docker-compose
