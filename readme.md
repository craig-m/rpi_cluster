# rpi_cluster

An 8 node, Raspberry Pi powered, proof of concept beowulf cluster project.

See doc/readme.md for the detailed cluster setup process.

<p align="center">
  <img width="515" height="538" src="https://github.com/craig-m/rpi_cluster/raw/master/doc/pictures/pi_towers1.jpg">
</p>

---

# Design decisions

* Start with vanilla Raspbian installations, with default SSH access.
* Ability to easily rebuild any failed R-Pi node, expect that nodes might randomly fail.
* Operate all critical services in high availability.
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
  <td>LAN misc</td>
  <td>Deployer</td>
  <td>Compute</td>
  <td>Total</td>
</tr>
<tr>
  <td>R-Pi Model:</td>
  <td>B+</td>
  <td>2 B</td>
  <td>2 B</td>
  <td>3 B</td>
  <td>&nbsp;</td>
</tr>
<tr>
  <td>count:</td>
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
* x2 6 Port RAVPower USB Chargers (each 60W 12A) (https://www.ravpower.com/6-port-usb-wall-charger-black-.html)
* Raspberry Pi SenseHat (https://www.raspberrypi.org/products/sense-hat/)
* x9 ethernet cables
* x8 micro usb cables (for power)


---


# Overview of node groups


### Deployer

The Deployer runs from x1 R-Pi. This configures all of the other hosts. It also acts as a Certificate Authority, for TLS and SSH. Infrastructure for system admins.

* [Ansible](https://www.ansible.com/) - configuration management
* [ARA](https://ara.readthedocs.io/en/stable/) - web interface to analyze Ansible results
* [Redis](https://redis.io/) - for the Ansible fact cache
* [ServerSpec](http://serverspec.org/) - RSpec tests for infrastructure
* [Invoke](http://www.pyinvoke.org/) - a task execution tool
* [pass](https://www.passwordstore.org/) -  a password manager for unix


Redundancy: can fail and the cluster will continue to operate, but it cannot be altered. Small amounts of downtime for this host can be tolerated while it gets restored from backup.

This SD card can be cloned onto a spare one as a backup option. This is the only node that is not immutable.


### LanServices - Main

To provide redundant essential services for the LAN. Longer running infrastructure to handle services for the more ephemeral nodes.

* isc.org [DHCP Server](https://www.isc.org/downloads/dhcp/) (in high availability)
* isc.org [DNS Server](https://www.isc.org/downloads/bind/) (Bind with zone replication between master/secondary)
* NTP Server
* FTP Daemon (for BOOTP clients)
* BusyBox httpd (running in chroot)
* [Keepalived](https://github.com/acassen/keepalived) - a floating IP address, over x2 nodes, that will be present in *at least* one place at any given time.

Redundancy: any 1 of the 2 nodes can fail.


### LanServices - Misc

For miscellaneous, non-essential, net services. Used for dev, reporting, building, monitoring etc. And LEDs since it's equipped with a [Sense Hat](https://www.raspberrypi.org/products/sense-hat/).

* [Redis](https://redis.io/)
* Nginx + PHP-FPM
* [HAproxy](https://www.haproxy.org/)
* [Hugo](https://github.com/gohugoio/hugo) - static website generator
* [Yarn](https://github.com/yarnpkg/yarn/)
* Docker

Redundancy: not redundant, does not provide services for the LAN. Immutable - no data to backup from this node.


### Compute / Worker

To play with services, and things like Kubernetes. Subdivided into a frontend and backend group. These nodes run services for public consumption, this is "production". Immutable infrastructure.

* [DistCC](https://github.com/distcc/distcc) - for distributed compiling
* [C mpich](https://www.mpich.org/) - distributed code with the C Message Passing Interface
* Docker + Kubernetes + Weave network addon

Redundancy: the herd.

---
