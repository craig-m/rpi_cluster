# rpi_cluster

A PoC Raspberry Pi Beowulf cluster project.

See doc/readme.me for the detailed cluster setup process, or to also view the readme.md (if you have a working Vagrant + VirtualBox setup), type "vagrant up" from a shell in this directory and then after a few moments open http://localhost:5550/ on your desktop.

---

# Hardware Inventory

### R-Pi

The x8 boards I ended up with are divided into these groups. All run Raspbian GNU/Linux 9.3 (stretch), a Debian-based OS.

<table>
<tbody>
<tr>
  <td>&nbsp;Group&nbsp;</td>
  <td>&nbsp;LanServices main&nbsp;</td>
  <td>&nbsp;LanServices misc&nbsp;</td>
  <td>&nbsp;Deployer&nbsp;</td>
  <td>&nbsp;Compute/Worker&nbsp;</td>
</tr>
<tr>
  <td>&nbsp;Model&nbsp;</td>
  <td>&nbsp;V 1&nbsp;</td>
  <td>&nbsp;V 2&nbsp;</td>
  <td>&nbsp;V 2&nbsp;</td>
  <td>&nbsp;V 3&nbsp;</td>
</tr>
<tr>
  <td>&nbsp;Count&nbsp;</td>
  <td>&nbsp;x 2&nbsp;</td>
  <td>&nbsp;x 1&nbsp;</td>
  <td>&nbsp;x 1&nbsp;</td>
  <td>&nbsp;x 4&nbsp;</td>
</tr>
</tbody>
</table>


### Other parts

The other bits and pieces:

* a router (https://lede-project.org/ + https://www.gl-inet.com/)
* my laptop
* x1 16 port D-Link switch (Gbit ethernet, unmanaged)
* x2 6 Port RAVPower USB Chargers (each 60W 12A) (https://www.ravpower.com/6-port-usb-wall-charger-black-.html)
* A Raspberry Pi SenseHat (https://www.raspberrypi.org/products/sense-hat/)
* A Raspberry Pi Camera

---

# Overview of roles

What the cluster is doing, more or less. The software stack for each group.

### Deployer

The Deployer role runs on x1 R-Pi, and in the Virtual Machine. This configures all of the other hosts.

* Fabric (http://www.fabfile.org/)
* Ansible (https://www.ansible.com/)
* ServerSpec (http://serverspec.org/)
* Redis DB for Ansible fact cache (https://redis.io/)

### LanServices - Main

To provide redundant essential services for the LAN.

* DHCP Server (in high availability)
* DNS (Bind with zone replication between master/slave)
* NTPD Server
* FTP Daemon
* BusyBox httpd (running in chroot)

### LanServices - Misc

For miscellaneous, non-essential, net services.

* Used for dev, reporting, testing
* Nginx + PHP-fpm
* Haproxy
* Hugo website generator
* NFS server

### Compute/Worker

To play with services.

* Consul (x2 clients, x2 server)
* Keepalived (floating IP over x2 nodes)
* Haproxy
* NFS Client
* DistCC (for distributed compiling)
* Hadoop (to do)
* Docker cluster (x2 frontend, x2 backend) (to do)
* Python MPICH (to do)
