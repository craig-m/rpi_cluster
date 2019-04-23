Setup guide
===========

Directions for bootstrapping this Raspberry Pi cluster.

Tested on `2019-04-08-raspbian-stretch-lite.img`

---


Preparation
-----------

* Download Raspbian lite, flash the image on to each SD card with DD or Etcher etc.

* Create the empty file /boot/ssh on each SDcard to enable SSH access. Read https://www.raspberrypi.org/blog/a-security-update-for-raspbian-pixel/ for info.

* Join The R-Pi to a switch. Setup a DHCP server and make sure it is configured to only give out IP addresses to known hosts. You need to set static IPs for the Alpha, Beta, Omega and Psi hosts.

  The R-Pi in the Compute group (zeta, epsilon, gamma, delta) will get IP addresses from the Alpha and Beta R-Pi, once they have been configured. After the setup process the Alpha and Beta nodes will have static IP addresses, DHCP is needed for initial setup/bootstrap only (the cluster is not reliant on the DHCP server anymore).

* Place the SD cards into the R-Pi and power them on. The four admin hosts should respond to PING and SSH should be available (the default username is pi, with a default password of 'raspberry').


---


Setup the Deployer
------------------


Copy the code (this repo) to the R-Pi that will become the deployer, it **needs** to be copied to /home/pi/rpi_cluster/

note: no data/files/logs will be created in this dir - it does not need to be backed up.

```
$ rsync -avr --exclude='.git' --exclude='ignore_me' rpi_cluster/ pi@20.20.20.20:~/rpi_cluster
```

Connect to the deployer R-Pi:

```
$ ssh pi@20.20.20.20
```


Install our tools (ansible, ARA, invoke etc) and setup the deployer:

```
pi@raspberrypi:~ $ cd rpi_cluster/ansible/setup/
pi@raspberrypi:~/rpi_cluster/ansible/setup $ nohup ./install-deploy-tools.sh >> ~/install.log &
```


Setup keys and config

```
pi@raspberrypi:~/rpi_cluster/ansible/setup $ ./setup-keys.sh
pi@raspberrypi:~/rpi_cluster/ansible/setup $ ./setup-conf.sh
```


## run tasks

Activate the virtual python environment:

```
pi@raspberrypi:~ $ cd ~/rpi_cluster/ansible/
pi@raspberrypi:~/rpi_cluster/ansible $ source ~/env/bin/activate
```


List the tasks:

```
(env) pi@psi:~/rpi_cluster/ansible $ invoke -l
Available tasks:

  ansible-gather-facts           Gather facts on all hosts.
  ansible-maint                  upgrade all R-Pi server hosts (includes rolling reboots).
  ansible-ping                   Ansible Ping a host. ex: invoke ansible-ping omega
  ansible-sshd                   Change default SSH login on new R-Pi.
  ansible-test-default           Test default SSH creds on all hosts.
  cluster-serverspec             ServerSpec tests.
  compute-ansible-base           ansible base playbook on compute group.
  compute-ansible-container      Setup Docker k8 cluster.
  compute-ansible-container-rm   shutdown and remove docker and k8 cluster.
  compute-ansible-web            Setup Web frontend.
  deployer-ansible               ansible deployer role on Psi (localhost).
  deployer-ssh-config            Generate ~/.ssh/config file from Ansible inventory.
  lanservices-main-ansible       ansible services-main playbook on Alpha and Beta.
  lanservices-misc-ansible       ansible services-misc playbook on Omega.

```

Setup the deployer, this runs Ansible on the local deployer:

```
(env) pi@raspberrypi:~/rpi_cluster/ansible $ invoke deployer-ansible
Running play-rpi-deployer.yml
```


Create ~/.ssh/config on the deployer (from the hosts in the Ansible inventory):

```
(env) pi@psi:~/rpi_cluster/ansible $ invoke deployer-ssh-config
```


The deployer is all setup now, you can reboot it (optional but recommended).


---


```
(env) pi@psi:~/rpi_cluster/ansible $ eval `ssh-agent`
(env) pi@psi:~/rpi_cluster/ansible $ pass ssh/id_rsa
(env) pi@psi:~/rpi_cluster/ansible $ ssh-add
```


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
(env) pi@psi:~/rpi_cluster/ansible $ invoke ansible-gather-facts
(env) pi@psi:~/rpi_cluster/ansible $ invoke compute-ansible-base
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
