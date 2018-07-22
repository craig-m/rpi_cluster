Setup guide
===========

Directions for bootstrapping this Raspberry Pi cluster.


---


Preparation
-----------

* Download Raspbian lite, flash the image on to each SD card with DD or Etcher etc. I am using the 2018-06-27 Raspbian stretch lite image.

* Create the empty file /boot/ssh on each SDcard to enable SSH access. Read https://www.raspberrypi.org/blog/a-security-update-for-raspbian-pixel/ for info.

* Join The R-Pi to a switch. Setup a DHCP server and make sure it is configured to only give out IP addresses to known hosts, I use my pfSense firewall. You need to set static IPs for the Alpha, Beta, Omega and Psi hosts.

  The R-Pi in the Compute group (zeta, epsilon, gamma, delta) will get IP addresses from the Alpha and Beta R-Pi, once they have been configured. After the setup process the Alpha and Beta nodes will have static IP addresses, DHCP is needed for initial setup/bootstrap only (the cluster is not reliant on the DHCP server anymore).

* Place the SD cards into the R-Pi and power them on. The four admin hosts should respond to PING and SSH should be available (the default username is pi, with a default password of 'raspberry').


---


Setup the Deployer
------------------


Copy the code (this repo) to the R-Pi that will be the deployer. I have port forwarding setup infront of my Pi so the port is different:

```
$ scp -P 2222 -r rpi_cluster/ pi@192.168.6.200:~/
```

It expects to be stored in /home/pi/rpi_cluster/


Connect to the deployer R-Pi:

```
$ ssh -p 2222 pi@192.168.6.200
```


Install our tools (ansible, ARA, invoke etc) and requirements for the deployer:

```
$ cd rpi_cluster/ansible/setup/
pi@raspberrypi:~/rpi_cluster/ansible/setup $ ./install-deploy-tools.sh
```


Edit ~/rpi_cluster/ansible/setup/defaults to suit your environment.


Generate SSH CA and GPG keys, encrypt Ansible vault files:

```
pi@raspberrypi:~/rpi_cluster/ansible/setup $ ./keysandconf-new.sh
```


Activate the virtual python environment:

```
pi@raspberrypi:~ $ cd ~/rpi_cluster/ansible/
pi@raspberrypi:~/rpi_cluster/ansible $ source ~/env/bin/activate
```


List the tasks:

```
(env) pi@raspberrypi:~/rpi_cluster/ansible $ invoke -l
Available tasks:
```


Setup the deployer, this runs Ansible on the local deployer:

```
(env) pi@raspberrypi:~/rpi_cluster/ansible $ invoke deployer-ansible
Running play-rpi-deployer.yml
```


Create ~/.ssh/config on the deployer (from the hosts in the Ansible inventory):

```
(env) pi@raspberrypi:~/rpi_cluster/ansible $ invoke deployer-ssh-config
```


The deployer is all setup now, you can reboot it (optional but recommended).


---


Setup the cluster hosts
-----------------------


## LanServices group

The new Alpha, Beta and Omega nodes should all be up, with the default SSH settings/password. The other hosts will not have IP addresses yet.

```
(env) pi@psi:~/rpi_cluster/ansible $ invoke ansible-test-default
```

Change default SSH access on the hosts (disable password auth):

```
(env) pi@psi:~/rpi_cluster/ansible $ invoke ansible-sshd alpha
(env) pi@psi:~/rpi_cluster/ansible $ invoke ansible-sshd beta
(env) pi@psi:~/rpi_cluster/ansible $ invoke ansible-sshd omega
```

Configure Alpha + Beta nodes:

```
(env) pi@psi:~/rpi_cluster/ansible $ invoke lanservices-main-ansible
```

Configure Omega node:

```
(env) pi@psi:~/rpi_cluster/ansible $ invoke lanservices-misc-ansible
```


## Compute group

Change the default password on the new hosts:

```
(env) pi@psi:~/rpi_cluster/ansible $ invoke ansible-sshd zeta
(env) pi@psi:~/rpi_cluster/ansible $ invoke ansible-sshd epsilon
(env) pi@psi:~/rpi_cluster/ansible $ invoke ansible-sshd gamma
(env) pi@psi:~/rpi_cluster/ansible $ invoke ansible-sshd delta
```

Compute base setup:

```
(env) pi@psi:~/rpi_cluster/ansible $ invoke ansible_gather_facts
(env) pi@psi:~/rpi_cluster/ansible $ invoke compute_ansible
```

Compute hosting setup:

```
(env) pi@psi:~/rpi_cluster/ansible $ invoke compute-web-ansible
(env) pi@psi:~/rpi_cluster/ansible $ invoke compute-cont-ansible
```


## Cluster admin

Test the cluster, all hosts and services:

```
(env) pi@psi:~/rpi_cluster/ansible $ invoke cluster-serverspec
```

A role to apt-upgrade and reboot all servers (one by one):

```
(env) pi@psi:~/rpi_cluster/ansible $ invoke ansible-maint
```


---
