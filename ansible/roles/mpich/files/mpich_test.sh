#!/bin/bash

# run on omega
hostname | grep omega || exit 1;
whoami | grep mpiuser || exit 1;

rm -f /home/mpiuser/mpihosts.txt
touch -f /home/mpiuser/mpihosts.txt

hosts="gamma zeta delta epsilon"
for i in $hosts;
do
  getent hosts $i | awk '{print $1}' >> /home/mpiuser/mpihosts.txt
done

# man page:
# https://www.open-mpi.org/doc/v2.0/man1/mpirun.1.php

mpirun -l -np 16 --hostfile /home/mpiuser/mpihosts.txt /home/mpiuser/bin/mpi_sample
