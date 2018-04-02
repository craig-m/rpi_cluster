About
------

bootstrap-deployer.sh will setup the deploy host (Vagrant VM or 'psi' R-Pi).

Assumes working from:

```
vagrant@stretch:~$ pass ssh/id_rsa_pw
vagrant@stretch:~$ ssh-agent bash
vagrant@stretch:~$ ssh-add
Enter passphrase for /home/vagrant/.ssh/id_rsa:
vagrant@stretch:~$ source ~/env/bin/activate
(env) vagrant@stretch:~$ cd rpi_cluster/deploy/ansible/
```

---

Cheat notes below:

# SSH

Execute a command via a Jump Box

```
$ ssh -J pi@psi.local pi@omega.local hostname
omega
```

or two:

```
$ ssh -J pi@omega.local,pi@psi.local pi@alpha.local hostname
alpha
```

---

Fabric
------
http://www.fabfile.org/

List all tasks in a specific fabric file (fab command by default reads fabfile.py):

```
$ fab -f fab_cluster_control.py -l
```

Run Ad hoc command with Fabric (on all hosts):

```
$ fab -f fab_cluster_control.py -- uname -a | grep Linux
<snip>
```


Ansible
-------
http://docs.ansible.com/ansible/latest/index.html

Run 'id' as root on compute:

```
$ ansible compute -a "id" -f 10 --become
```

Run 'uname -a' on all hosts:

```
$ ansible all -a "uname -a" -f 10
```

Ad hoc command on a single host:

```
$ ansible omega -a "hostname"
```


Gather facts:

```
ansible all -m setup
```

ping:

```
ansible all -m ping
``


ansible-lint
------------
https://github.com/willthames/ansible-lint

```
vagrant@stretch:~$ source ~/env/bin/activate
(env) vagrant@stretch:~$ cd rpi_cluster/ansible/
(env) vagrant@stretch:~/rpi_cluster/ansible$ ansible-lint play-rpi-all-maint.yml
```

testinfra
---------
https://testinfra.readthedocs.io/en/latest/

bootstrap-deployer.sh runs this to test the deployment host is setup OK.


diceware
---------
https://github.com/ulif/diceware

Used to generate passwords kept in 'pass'.


httpie
-------
https://httpie.org/


passlib
-------
https://passlib.readthedocs.io/en/stable/
