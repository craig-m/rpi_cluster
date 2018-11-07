# Message Passing Interface

https://www.mpich.org/
https://wiki.mpich.org/mpich/index.php/Developer_Documentation
https://packages.debian.org/sid/mpich

## setup

The Omega node sends hobs to the x4 compute nodes.

```
mpiuser@omega:~ $ mpirun -l -np 16 --hostfile mpihosts.txt /home/mpiuser/bin/mpi_sample
[0] Host gamma, Process 0. Total proc 16.
[0] Host zeta, Process 1.
[0] Host delta, Process 2.
[0] Host epsilon, Process 3.
[0] Host gamma, Process 4.
[0] Host zeta, Process 5.[0]
[0] Host delta, Process 6.
[0] Host epsilon, Process 7.
[0] Host gamma, Process 8.
[0] Host zeta, Process 9.
[0] Host delta, Process 10.
[0] Host epsilon, Process 11.[0]
[0] Host gamma, Process 12.
[0] Host zeta, Process 13.
[0] Host delta, Process 14.
[0] Host epsilon, Process 15.
```
