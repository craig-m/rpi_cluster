admin-client
------------

A docker container to run:

* PGP (https://www.gnupg.org/)
* pass (https://www.passwordstore.org/)
* OpenSSH client (https://www.openssh.com/)

Used to SSH into the R-Pi servers from your Desktop, after the cluster has been setup. This can be used in place of the Vagrant VM.

---

Build and run:

```
./run.sh
```

The pgp-agent program will prompt you for the password to your pgp keys

```
admin@efz64c0c8ceg:~$ thesshcapw=$(pass ssh/CA)
```

Sign the ssh keys in our container (created by Dockerfile) with our CA keys:

```
admin@efz64c0c8ceg:~$ ssh-keygen -s ~/.ssh/my-ssh-ca/ca -P ${thesshcapw} -I admin -n pi -V +4w -z 1 ~/.ssh/id_rsa
```

```
admin@efz64c0c8ceg:~$ ssh pi@192.168.6.xx
```
