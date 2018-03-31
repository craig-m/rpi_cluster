security practices
------------------

Some general guidelines and rules for keeping the cluster secure.

guidelines
----------

* change the default password for the pi and root users

* avoid running daemons/code as the pi (which has passwordless sudo to root) or root user (where possible)

* no network services to run as pi or root users (where possible)

* no network services to run on 'deployer' R-Pi node (excluding sshd etc)

* the Admin Service nodes have static arp entries set in /etc/ethers

* sshd: PasswordAuthentication no, AuthorizedKeysFile yes, PermitRootLogin No

* use passwords on ssh and pgp keys

* avoid logging in as the root user, only use "pi@host:~ $ sudo <cmd>"

* check sha256 sums or pgp sigs of all downloaded files

* do NOT pipe commands into shells, especially like: wget -O - http://example.net/install.sh | sudo sh

* inspect any 3rd party install scripts before saving/using (eg: getdocker.sh)

* Try to avoid bad bash, test often and exit early
  - http://mywiki.wooledge.org/BashPitfalls


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
