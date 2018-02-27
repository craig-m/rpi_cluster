Setup guide
===========

Directions for bootstrapping this Raspberry Pi cluster.

Requires:

- Linux, MacOS or Windows desktop
- Vagrant (https://www.vagrantup.com/)
- VirtualBox (https://www.virtualbox.org/wiki/Downloads)


Raspberry Pi preparation
------------------------

* Download Raspbian lite, copy the image to each SD card with DD or Etcher etc.

  I am using the 2017-11-29-raspbian-stretch-lite image.

* Create the empty file /boot/ssh on each SDcard to enable SSH access.

  Read https://www.raspberrypi.org/blog/a-security-update-for-raspbian-pixel/ for info.

* Join The R-Pi to a switch, enable DHCP somewhere on the LAN.

  I have a small LEDE (formerly OpenWRT) router for this (my cluster has its own vlan + subnet). This has been configured to only give out IPs to known/static hosts.

* Place the SD cards into the R-Pi and power them on. They should all respond to PING.


Admin VM
--------

* Create the admin VM with Vagrant:

```
craig@desktop rpi_cluster (master) $ vagrant up
< SNIP >
==> default:
==> default: ----[ BerryClusterAdmin VM up! ]----
```

  see /vagrantvm/readme.md for more information on Vagrant.


* Login to the new VM:

```
craig@desktop rpi_cluster (master) $ vagrant ssh
Linux stretch 4.9.0-4-amd64 #1 SMP Debian 4.9.51-1 (2017-09-28) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
vagrant@stretch:~$
```

* Finish AdminVM setup:

```
vagrant@stretch:~$ cd rpi_cluster/deploy/ansible/
vagrant@stretch:~/rpi_cluster/deploy/ansible$ ./bootstrap-deployer.sh
```
  Note: You will be asked for the PGP key password.

* Activate the environment. The tools we installed in requirements.txt are available now (ansible and fabric etc)

```
vagrant@stretch:~$ pass keys/ssh
vagrant@stretch:~$ ssh-agent bash
vagrant@stretch:~$ ssh-add
Enter passphrase for /home/vagrant/.ssh/id_rsa:
vagrant@stretch:~$ source ~/env/bin/activate
(env) vagrant@stretch:~$ cd rpi_cluster/deploy/ansible/
```

Configure
---------

* Alter the settings in all of the variable and inventory files to suit your environment:

  - rpi_cluster/admin/ansible/group_vars/*
  - rpi_cluster/admin/ansible/host_vars/*
  - rpi_cluster/admin/ansible/inventories/*

  Note: Any files you add/edit/remove in /home/vagrant/rpi_cluster/ will also change on your host.. And vice-versa. Passthrough is enabled :)

* Use Ansible Vault to edit the encrypted files:

```
(env) vagrant@stretch:~/rpi_cluster/deploy/ansible$ ansible-vault edit group_vars/all/vault
```

---


Cluster setup
-------------

* setup SSH keys:

```
(env) vagrant@stretch:~/rpi_cluster/deploy/ansible$ ./install_ssh_key.sh
```

* List the fabric tasks:

```
(env) vagrant@stretch:~/rpi_cluster/deploy/ansible$ fab -l
```

## LanServices

* Configure Lan Services main (Alpha, Beta):

```
(env) vagrant@stretch:~/rpi_cluster/deploy/ansible$ fab ansible_lansrv_main
```

* Configure Lan Services misc (Omega):

```
(env) vagrant@stretch:~/rpi_cluster/deploy/ansible$ fab ansible_lansrv_misc
```

## Compute nodes

* Run Ansible on the Compute nodes (zeta, epsilon, delta, gamma):

```
(env) vagrant@stretch:~/rpi_cluster/deploy/ansible$ fab ansible_compute
```

## Web app


```
(env) vagrant@stretch:~/rpi_cluster/deploy/ansible$ fab ansible_compute_webapp
```

## deployer

* Setup the deployer R-Pi, psi, so we can also run Ansible + Fabric etc from there too.

```
(env) vagrant@stretch:~/rpi_cluster/deploy/ansible$ cd ~
(env) vagrant@stretch:~$ fab -l
(env) vagrant@stretch:~$ fab bs_deployer_psi -H 192.168.6.16
```

  This will upload ~/rpi_cluster/ to psi and run the bootstrap-deployer.sh script (detached, under screen).


EOF
