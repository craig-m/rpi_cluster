# Message Passing Interface

https://www.mpich.org/
https://wiki.mpich.org/mpich/index.php/Developer_Documentation
https://packages.debian.org/sid/mpich

## Setup

The mpich role is run on Lanservices-Misc, and the Compute groups.

The LanService-Misc node has SSH access to the compute nodes as the mpiuser user, who run tasks and then report back.


```
(env) pi@psi:/opt/cluster/deploy-script $ ./mpich_keygen.sh
```
