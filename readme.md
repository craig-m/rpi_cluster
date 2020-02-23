# rpi_cluster

An 8 node, Raspberry Pi powered, proof of concept beowulf cluster project.

See [doc/readme.md](https://github.com/craig-m/rpi_cluster/tree/master/doc) for the detailed cluster setup process.

<p align="center">
  <img width="515" height="538" src="https://github.com/craig-m/rpi_cluster/raw/master/doc/pictures/pi_towers1.jpg">
</p>

---

# Design decisions

* Start with vanilla Raspbian installations, with default SSH access - just flash the SDCard.
* Have the ability to easily rebuild any failed R-Pi node, expect that nodes might randomly fail (or be turned off).
* Operate all critical services in high availability (in either active-active, or primary and failover).
* The R-Pi cluster should be self contained, minimise any external DHCP + DNS dependencies.
* No requirements on admin laptop - just need SSH client + a text editor + git (most OS's provide these).


---


# Hardware Inventory

### R-Pi

The x8 R-Pi that I ended up with are of various models, I divided them into these groups:

<table>
<tbody>
<tr>
  <td>Ansible Group</td>
  <td>LAN main</td>
  <td>OpenWRT</td>
  <td>Deployer</td>
  <td>Compute</td>
  <td>Total</td>
</tr>
<tr>
  <td>R-Pi Model</td>
  <td>B Plus Rev 1.2</td>
  <td>2 B Rev 1.1</td>
  <td>2 B Rev 1.1</td>
  <td>3 B Rev 1.2</td>
  <td>&nbsp;</td>
</tr>
<tr>
  <td>quantity</td>
  <td>2</td>
  <td>1</td>
  <td>1</td>
  <td>4</td>
  <td>8</td>
</tr>
</tbody>
</table>

All run Raspbian GNU/Linux (stretch), a Debian-based OS.

### Other parts

The other bits and pieces in this cluster:

* D-Link 16 port Gbit ethernet switch
* x2 6 Port [RAVPower USB Chargers](https://www.ravpower.com/6-port-usb-wall-charger-black-.html) (each 60W 12A) 
* Raspberry Pi [Sense Hat](https://www.raspberrypi.org/products/sense-hat/)
* x9 ethernet cables
* x8 micro usb cables (for power)


---


# Overview of node groups


### Deployer

The Deployer runs from x1 R-Pi. This configures all of the other hosts. It also acts as a Certificate Authority, for TLS and SSH. Infrastructure for system admins.

And LEDs since it's equipped with a [Sense Hat](https://www.raspberrypi.org/products/sense-hat/)

* [Ansible](https://www.ansible.com/) - configuration management
* [ARA](https://ara.readthedocs.io/en/stable/) - web interface to analyze Ansible results
* [Redis](https://redis.io/) - for the Ansible fact cache
* [ServerSpec](http://serverspec.org/) - RSpec tests for infrastructure
* [Invoke](http://www.pyinvoke.org/) - a task execution tool
* [pass](https://www.passwordstore.org/) -  a password manager for unix (used with ansible-vault)


Redundancy: can fail and the cluster will continue to operate, but it cannot be altered. Small amounts of downtime for this host can be tolerated while it gets restored from backup.

This SD card can be cloned onto a spare one as a backup option, a USB key can also be used for regular backups of data. This is the only node that is not immutable.


### LanServices - Main

To provide redundant essential services for all hosts on this the LAN. Longer running infrastructure to handle services for the more ephemeral nodes.

* isc.org [DHCP Server](https://www.isc.org/downloads/dhcp/) (in high availability)
* isc.org [DNS Server](https://www.isc.org/downloads/bind/) (Bind with zone replication between primary and secondary)
* NTP Server
* FTP Daemon (for BOOTP clients)
* BusyBox httpd (running in chroot)
* [Keepalived](https://github.com/acassen/keepalived) - a floating IP address, over x2 nodes, that will be present in *at least* one place at any given time (no fencing).

Redundancy: any 1 of the 2 nodes can fail. Immutable - no data to backup from these nodes.

Scalability: load during regular operation is low. If load gets too high some serivces can be moved off this group.


### OpenWRT

[OpenWRT](https://openwrt.org/toh/raspberry_pi_foundation/raspberry_pi) is installed on this node for DHCP and DNS during the inital setup.

This is used only to bootstrap the Psi, Alpha and Beta nodes. Before ansible can configure them with static addresses, and bring up DHCP and DNS in HA.


### Compute / Worker

To play with services, and things like Kubernetes. These nodes run services for public consumption, this is "production".

* [DistCC](https://github.com/distcc/distcc) - for distributed compiling
* [C mpich](https://www.mpich.org/) - distributed code with the C Message Passing Interface
* [K3s](https://k3s.io/) - The certified Kubernetes distribution built for IoT & Edge computing

Redundancy: the herd. Immutable - no data to backup from these nodes.

Scalability: try to write code that scales, so more nodes can easily be added.

---
