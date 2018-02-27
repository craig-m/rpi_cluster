+++
title = "about"

+++

<h1>Hardware</h1>

<p> </p>

<table class="table table-striped">
  <thead>
    <tr>
      <th>#</th>
      <th>Left tower</th>
      <th>Right tower</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">1</th>
      <td> <span class="fa fa-linux"></span> LanServices omega (V2)</td>
      <td> <span class="fa fa-linux"></span> Deployer (V2)</td>
    </tr>
    <tr>
      <th scope="row">2</th>
      <td> <span class="fa fa-linux"></span> LanServices alpha (V1 b+)</td>
      <td> <span class="fa fa-linux"></span> LanServices beta (V1 b+)</td>
    </tr>
    <tr>
      <th scope="row">3</th>
      <td> <span class="fa fa-linux"></span> Compute (V3 b)</td>
      <td> <span class="fa fa-linux"></span> Compute (V3 b)</td>
    </tr>
    <tr>
      <th scope="row">4</th>
      <td> <span class="fa fa-linux"></span> Compute (V3 b)</td>
      <td> <span class="fa fa-linux"></span> Compute (V3 b)</td>
    </tr>
    <tr>
      <th scope="row">5</th>
      <td> <span class="fa fa-power-off"></span> power supply (12A)</td>
      <td> <span class="fa fa-power-off"></span> power supply (12A)</td>
    </tr>
  </tbody>
</table>

<p>Currently x8 Raspberry Pi's, and an OpenWRT Access Point, makeup the cluster.</p>

<h1>Software</h1>

<p>What is running accross the node types.</p>

<h3>Deployer</h3>
<p>This node setups up and controls the cluster.</p>
<ul>
  <li>Fabric</li>
  <li>Ansible</li>
  <li>ServerSpec</li>
  <li>NTPD</li>
  <li>Redis server (for ansible fact cache)</li>
</ul>

<h3>LanService</h3>
<ul>
  <li>DHCP (failover between Alpha and Beta)</li>
  <li>DNS (with zone replication and custom TLD)</li>
  <li>TFTP Server (for Network boot clients)</li>
  <li>Busybox httpd server (running in a chroot)</li>
  <li>Consul (server)</li>
</ul>

<h3>Omega</h3>
<p>miscellaneous services</p>
<ul>
  <li>NTPD</li>
  <li>haproxy</li>
  <li>Nginx</li>
  <li>php-fpm</li>
  <li>Consul (server)</li>
  <li>Redis server</li>
  <li>Hugo</li>
  <li>websocketd</li>
</ul>


<h3>compute</h3>
<ul>
  <li>docker</li>
  <li>distcc</li>
  <li>mpich</li>
</ul>
