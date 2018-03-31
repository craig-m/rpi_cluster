#!/bin/bash 

ossecver="2.9.3"

mkdir ossec;
cd ossec;

wget https://github.com/ossec/ossec-hids/archive/${ossecver}.tar.gz
wget https://github.com/ossec/ossec-hids/releases/download/${ossecver}/ossec-hids-${ossecver}.tar.gz.asc
tar -xf ${ossecver}.tar.gz

cd ossec-hids-{ossecver}/;

sudo ./install.sh
