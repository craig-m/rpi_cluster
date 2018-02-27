security practices
------------------

Some general guidelines and rules for keeping the cluster secure.

rules
-----

* change the default password for the 'pi' user, set a root password

* avoid running daemons/code as pi or root users (where possible)

* no network services to run as pi or root users (where possible)

* no network services to run on 'deployer' R-Pi node (excluding sshd)

* the Admin Service nodes have static arp entries set in /etc/ethers

* sshd: PasswordAuthentication no, AuthorizedKeysFile yes, PermitRootLogin No

* use passwords on ssh and pgp keys

* avoid logging in as the root user, only use "pi@host:~ $ sudo <cmd>"

* check sha256 sums or pgp sigs of all downloaded files

* do NOT run commands like: wget -O - http://example.net/install.sh | sudo sh

* inspect any 3rd party install scripts before saving/using (eg: getdocker.sh)

* Try to avoid bad bash, test often and exit early
  - http://mywiki.wooledge.org/BashPitfalls
