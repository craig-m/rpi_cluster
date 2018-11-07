
BusyBox contains a small httpd server.

* https://busybox.net/about.html
* https://wiki.openwrt.org/doc/howto/http.httpd
* https://git.busybox.net/busybox/tree/networking/httpd.c

files/chroot_bb.sh builds a chroot for it to run under, and installs a systemd service.

The Alpha and Beta nodes run this (port 1080)
