+++
title = "Hosting Updates"
date = 2018-03-15T09:32:51Z
tags = ["hugo","webdev"]
categories = ["webdev","rpi-cluster"]

+++

It has been a long time since posting.

## creating the post

To create our blog post, from in the Vagrant VM:

```
(env) vagrant@stretch:~$ cd rpi_cluster/code/hugo-site/
(env) vagrant@stretch:~/rpi_cluster/code/hugo-site$ hugo new post/hosting-updates.md
```

## uploading

Pushing the post, from the Vagrant VM, to the Omega R-Pi:

```
(env) vagrant@stretch:~$ cd ~/rpi_cluster/deploy/ansible/
(env) vagrant@stretch:~/rpi_cluster/deploy/ansible$ fab deploy_omega_site
```

## haproxy

haproxy is the frontend you hit when visiting this site, with content served from the local Nginx webserver.

There are also some backends setup, to the Admin Alpha and Beta nodes.

Locally:
http://192.168.6.xx/api/alpha/hello

From the frontend http-in section of haproxy. the L7 rules:

```
acl url_admin_alpha path_beg /api/alpha/
use_backend alpha if url_admin_alpha
```

The backend section of haproxy:

```
# busybox httpd on alpha
backend alpha
	#
	mode http
	balance roundrobin
	option forwardfor
  #
  reqrep ^([^\ :]*)\ /api/alpha/(.*)     \1\ /cgi-bin/\2
	#
	# add IP header
	http-request set-header X-Forwarded-Port %[dst_port]
	http-request add-header X-CLIENT-IP %[src]
	#
  # security headers
  http-response set-header X-XSS-Protection 1;mode=block
  http-response set-header Referrer-Policy strict-origin
  http-response set-header X-Content-Type-Options nosniff
  #
	# backend servers
  server host {{ hostvars['alpha']['ansible_default_ipv4']['address'] }}:1080 maxconn 1000
```

The backend we reverse proxy to:
http://192.168.6.xx:1080/cgi-bin/hello
