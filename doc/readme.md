Setup guide
===========

Directions for bootstrapping this Raspberry Pi cluster.

Requires:

- Linux, MacOS or Windows desktop
- Vagrant (https://www.vagrantup.com/)
- VirtualBox (https://www.virtualbox.org/wiki/Downloads)


Raspberry Pi preparation
------------------------

* Download Raspbian lite, flash the image on to each SD card with DD or Etcher etc.

  I am using the 2017-11-29-raspbian-stretch-lite image.

* Create the empty file /boot/ssh on each SDcard to enable SSH access.

  Read https://www.raspberrypi.org/blog/a-security-update-for-raspbian-pixel/ for info.

* Join The R-Pi to a switch, enable DHCP somewhere on the LAN. I have a small OpenWRT router for this (my cluster has its own VLAN + subnet) for this. Changing from the 192.168.6.x subnet is untested so far (to do..).

  Make sure your DHCP server is configured to only give out IP addresses to known hosts. You need to set static IPs for the Alpha, Beta, Omega and Psi hosts.

  The R-Pi in the Compute group will get IP addresses from the Alpha and Beta R-Pi, once they have been configured (from Vagrant). After the setup process the Alpha and Beta nodes will have static IP addresses, DHCP is needed for initial setup/bootstrap only.

* Place the SD cards into the R-Pi and power them on. The four admin hosts should respond to PING and SSH should be available (the default username is pi, with a default password of 'raspberry').


---


Create the Admin VM
--------------------

* Create the Virtual admin Machine with Vagrant:

```
craig@desktop:~$ git clone git@github.com:craig-m/rpi_cluster.git
craig@desktop:~$ cd rpi_cluster
craig@desktop: rpi_cluster $ vagrant up

< SNIP >

==> default: ----[ BerryClusterAdmin VM up! ]----
```

  See /vagrantvm/readme.md for more information and notes on Vagrant.


* Login to the new VM:

```
craig@desktop: rpi_cluster $ vagrant ssh
Linux stretch 4.9.0-4-amd64 #1 SMP Debian 4.9.51-1 (2017-09-28) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
vagrant@stretch:~$
```

  Now we have an isolated environment for all our tools and config files.

  The folder ./rpi_cluster/ on your desktop is mounted at /home/vagrant/rpi_cluster/ - you can use a text editor from your desktop to alter these files.

  ```
  vagrant@stretch:~$ df -h | grep -e Filesystem -e rpi_cluster
  Filesystem                Size  Used Avail Use% Mounted on
  home_vagrant_rpi_cluster  xxxG  xxxG   xxG  50% /home/vagrant/rpi_cluster
  ```

  You can carry on reading this document at http://localhost:5550/index.php?p=doc


---


Key setup and Cluster Config
----------------------------

### New deploy

* For a new deployment, run new_keysandconf.sh. This will:
  - wipe all old files (!)
  - create a new PGP key (with password, the only one we need to remember)
  - create a password store (https://www.passwordstore.org/)
  - generate an SSH key pair (with a random password, saved in pass)
  - generate a random password to use ansible-vault with
  - copy /docs/defaults/{group_vars,host_vars} to /ansible/ (and encrypt the vault files)
    (you will be prompted to edit them)

```
vagrant@stretch:~$ cd ~/rpi_cluster/vagrantvm/
vagrant@stretch:~/rpi_cluster/vagrantvm$ ./keysandconf_new.sh
```

### Existing cluster

* If you have the cluster up and running already:

```
vagrant@stretch:~$ cd ~/rpi_cluster/vagrantvm/
vagrant@stretch:~/rpi_cluster/vagrantvm$ ./keysandconf_restore.sh
```


---


Admin VM setup
--------------

* Activate the environment. The tools we installed in requirements.txt are available now (ansible and fabric etc)

```
vagrant@stretch:~/rpi_cluster/ansible$ pass ssh/id_rsa_pw
vagrant@stretch:~/rpi_cluster/ansible$ ssh-agent bash
vagrant@stretch:~/rpi_cluster/ansible$ ssh-add
Enter passphrase for /home/vagrant/.ssh/id_rsa:
vagrant@stretch:~/rpi_cluster/ansible$ source ~/env/bin/activate
(env) vagrant@stretch:~/rpi_cluster/ansible$
```


---


Cluster setup
-------------

* setup SSH keys, this will copy our public key to all of the new R-Pi:

```
(env) vagrant@stretch:~/rpi_cluster/ansible$ ./copy_ssh_key.sh
```

* List the fabric tasks:

```
(env) vagrant@stretch:~/rpi_cluster/ansible$ fab -l
(env) vagrant@stretch:~/rpi_cluster/ansible$ fab ansible_hostinfo
```

  At this stage only the x4 admin nodes should respond.

## deployer

* Setup the deployer R-Pi, psi, so we can also run Ansible + Fabric etc from there too.

```
(env) vagrant@stretch:~/rpi_cluster/ansible$ fab ansible_0_lansrv_deploy
```

## LanServices

* Configure Lan Services main (Alpha, Beta). After this finishes the x4 compute nodes should have IP addresses.

```
(env) vagrant@stretch:~/rpi_cluster/ansible$ fab ansible_1_lansrv_main
```

* Configure Lan Services misc (Omega):

```
(env) vagrant@stretch:~/rpi_cluster/ansible$ fab ansible_2_lansrv_misc
```

## Compute nodes

* Run Ansible on the Compute nodes (zeta, epsilon, delta, gamma):

```
(env) vagrant@stretch:~/rpi_cluster/ansible$ fab ansible_3_compute
(env) vagrant@stretch:~/rpi_cluster/ansible$ fab ansible_4_compute_webapp
(env) vagrant@stretch:~/rpi_cluster/ansible$ fab ansible_5_compute_containers
```

EOF
