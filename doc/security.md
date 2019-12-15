security practices
------------------

Some general guidelines and rules for keeping the cluster secure.


guidelines
----------

* change the default password for the pi and root users

* avoid running daemons/code as the pi (which has passwordless sudo to root) or root user (where possible)

* no network services to run as pi or root users (where possible)

* no network services to run on the 'deployer' R-Pi node (excluding sshd)

* the Admin Service nodes have static arp entries set in /etc/ethers

* sshd: PasswordAuthentication no, AuthorizedKeysFile yes, PermitRootLogin No

* use passwords on ssh and pgp keys

* avoid logging in as the root user, only use "pi@host:~ $ sudo <cmd>"

* check sha256 sums or PGP sigs of all downloaded files

* do NOT pipe commands into shells, especially like: wget -O - http://example.net/install.sh | sudo sh

* inspect any 3rd party install scripts before saving/using (eg: getdocker.sh)

* Try to avoid bad bash, test often and exit early
  - http://mywiki.wooledge.org/BashPitfalls


Raspbian issues
---------------

To get the kernel config:
```
sudo modprobe configs;
gunzip -dc /proc/config.gz
```

Without rebuilding the kernel:

* No AppArmor or SELinux support
* No support for auditd

---


some hardening tips
-------------------


Hide all processes from other users:

```
$ sudo mount -o remount,rw,hidepid=2 /proc
```

in /etc/fstab to make it permanent:

```
proc  /proc proc  efaults,hidepid=2,gid=1001  0 0
```

Notes: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=0499680a42141d86417a8fbaa8c8db806bea1201


Set immutable files:
```
$ sudo chattr +i /etc/services
```

what setuid files are there?
```
$ sudo find / -user root -perm -4000 -exec ls -ldb {} \;
```

Fix homedir perms
```
$ chmod 700 /home/pi/
```
Most files on Raspbian by default are world readable.


#### usb devices

Disable new USB devices from being added:

Set new devices connected to hostX to be deauthorized by default (ie:
lock down):

```
echo 0 > /sys/bus/usb/devices/usbX/authorized_default
```

https://www.kernel.org/doc/Documentation/usb/authorization.txt


Tools
-----

Use tools to help audit server configs. For example Gixy can be used to help find security misconfigurations in Nginx https://github.com/yandex/gixy


The 'to do' list
----------------

* remove the 'pi' user from all Raspbian installs
* stop sudo without password for all sudo users
* don't add user to docker group:

```
# A user in the docker group can get root by:
#
docker run -it --rm --privileged -v /:/mnt ubuntu bash
echo 'ALL=(ALL) NOPASSWD:ALL' >> /mnt/etc/sudoers
```

* use something like SmallStep for SSH CA auth - https://github.com/smallstep/certificates


---

# Tech docs


"Detecting ATT&CK techniques & tactics for Linux"
https://github.com/Kirtar22/Litmus_Test


"Linux Atomic Tests by ATT&CK Tactic & Technique"
https://github.com/redcanaryco/atomic-red-team/blob/master/atomics/linux-index.md
