Setup guide
===========

Directions for bootstrapping this Raspberry Pi cluster.


---


Preparation
-----------

* Download Raspbian lite, flash the image on to each SD card with DD or Etcher etc. I am using the 2017-11-29-raspbian-stretch-lite image.

* Create the empty file /boot/ssh on each SDcard to enable SSH access. Read https://www.raspberrypi.org/blog/a-security-update-for-raspbian-pixel/ for info.

* Join The R-Pi to a switch. Setup a DHCP server and make sure it is configured to only give out IP addresses to known hosts. You need to set static IPs for the Alpha, Beta, Omega and Psi hosts.

  The R-Pi in the Compute group (zeta, epsilon, gamma, delta) will get IP addresses from the Alpha and Beta R-Pi, once they have been configured. After the setup process the Alpha and Beta nodes will have static IP addresses, DHCP is needed for initial setup/bootstrap only (the cluster is not reliant on the DHCP server anymore).

* Place the SD cards into the R-Pi and power them on. The four admin hosts should respond to PING and SSH should be available (the default username is pi, with a default password of 'raspberry').


---


new deploy
----------

Copy the code to the R-Pi that will be the deployer. I have port forwarding setup infront of my Pi so the port is different:

```
$ scp -P 2222 -r rpi_cluster/ pi@192.168.6.200:~/
```

Connect to the deployer:

```
$ ssh -p 2222 pi@192.168.6.200
$ cd rpi_cluster/ansible/setup/
pi@raspberrypi:~/rpi_cluster/ansible/setup $
```

Install tools and their requirements:

```
pi@raspberrypi:~/rpi_cluster/ansible/setup $ ./install-deploy-tools.sh
```

```
pi@raspberrypi:~/rpi_cluster/ansible/setup $ ./keysandconf_new.sh
```

activate the environment

```
pi@psi:~ $ cd rpi_cluster/ansible/
pi@psi:~/rpi_cluster/ansible $ source ~/env/bin/activate
(env) pi@psi:~/rpi_cluster/ansible $
```

The fabric tasks

```
(env) pi@psi:~/rpi_cluster/ansible $ fab -l


--==  rpi_cluster deployer fabric file  ==--

Available commands:

    ansible_1_lan_services        setup ssh access - configure default SSHD (setup keys)
    ansible_2_lan_services        Playbook - LanServices (alpha, beta, omega)
    ansible_3_compute             Playbook - Compute - base (gamma, delta, epsilon, zeta)
    ansible_4_compute_webapp      Playbook - Compute - hosting
    ansible_5_compute_containers  Playbook - Compute - Containers
    ansible_hostinfo              Run setup module to gather facts on all hosts.
    ansible_localhost             run on local deployer
    ansible_ping                  Run ping module.
    ansible_test_default          test default login creds.
    cluster_maintainence          upgrades (includes rolling reboots)
    cluster_shutdown              shutdown cluster - ansible (excludes deployer)
    deploy_omega_site             code/hugo-site
    serverspec_tests              Run ServerSpec tests on cluster.
```

---
