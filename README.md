# rpi_cluster

An 8 node PoC Raspberry Pi Beowulf cluster project.

See doc/readme.md for the detailed cluster setup process.

This is an experiment, and exists mainly for my own learning and tinkering when I have time.


<p align="center">
  <img width="515" height="538" src="https://github.com/craig-m/rpi_cluster/raw/master/doc/pictures/pi_towers1.jpg">
</p>


---


# Hardware Inventory

### R-Pi

The x8 Raspberry's I ended up with are divided into these groups:

<table>
<tbody>
<tr>
  <td>Group</td>
  <td>LAN main</td>
  <td>LAN misc</td>
  <td>Deployer</td>
  <td>Compute</td>
  <td>Total</td>
</tr>
<tr>
  <td>Model</td>
  <td>1</td>
  <td>2</td>
  <td>2</td>
  <td>3</td>
  <td>&nbsp;</td>
</tr>
<tr>
  <td>Count</td>
  <td>2</td>
  <td>1</td>
  <td>1</td>
  <td>4</td>
  <td>8</td>
</tr>
</tbody>
</table>

All run Raspbian GNU/Linux 9.3 (stretch), a Debian-based OS.

### Other parts

The other bits and pieces in this cluster:

* PC Engines APU1 - Firewall with x3 ethernet ports for LAN, WAN, DMZ (https://www.pcengines.ch/apu.htm)
* D-Link 16 port switch (Gbit ethernet, unmanaged)
* x2 6 Port RAVPower USB Chargers (each 60W 12A) (https://www.ravpower.com/6-port-usb-wall-charger-black-.html)
* Raspberry Pi SenseHat (https://www.raspberrypi.org/products/sense-hat/)
* Raspberry Pi Camera



---


# Network

<p align="center">
  <img width="515" height="538" src="https://github.com/craig-m/rpi_cluster/raw/master/doc/pictures/rpi_clust_network.png">
</p>


---


# Overview of roles

What the cluster is doing, more or less. The software stack for each group.


### Deployer

The Deployer runs from x1 R-Pi. This configures all of the other hosts using:

* Fabric (http://www.fabfile.org/)
* Ansible (https://www.ansible.com/)
* ServerSpec (http://serverspec.org/)

It also acts as a Certificate Authority, for TLS and SSH. The deployer is in a different subnet, everything else is in a DMZ.


### LanServices - Main

To provide redundant essential services for the LAN.

* DHCP Server (in high availability)
* DNS Server (Bind with zone replication between master/slave)
* NTP Server
* FTP Daemon
* BusyBox httpd (running in chroot)

Redundancy: x1 node can fail.


### LanServices - Misc

For miscellaneous, non-essential, net services. Used for dev, reporting, testing , monitoring etc.

* Redis
* Nginx + PHP-FPM
* Haproxy
* Hugo (static website generator)
* Yarn
* NFS server
* Docker

Redundancy: not redundant, does not provide services for the LAN.


### Compute / Worker

To play with services and offer hosting. Subdivided into a frontend and backend group.

* Keepalived (floating IP over x2 nodes)
* Haproxy
* Nginx
* NFS Client
* DistCC (for distributed compiling)
* Python MPICH (Message Passing Interface)
* Docker swarm
* Hadoop (to do)

Redundancy: x1 front and x1 back node can fail.


---
