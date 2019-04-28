#!/bin/bash

mkdir -pv /etc/modulefiles/rpitest
cp ${MODULESHOME}/modulefiles/null /etc/modulefiles/rpitest/2.0
cp ${MODULESHOME}/modulefiles/module-info /etc/modulefiles/rpitest/1.0
module avail
module show rpitest

echo '#%Module' > /etc/modulefiles/rpitest/.version
echo 'set ModulesVersion "1.0"' >> /etc/modulefiles/rpitest/.version
module avail
module show rpitest
