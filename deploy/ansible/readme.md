About
------

Cheat Notes on the utilities installed from requirements.txt

Assumes working from:

```
vagrant@stretch:~$ pass keys/ssh
vagrant@stretch:~$ ssh-agent bash
vagrant@stretch:~$ ssh-add
Enter passphrase for /home/vagrant/.ssh/id_rsa:
vagrant@stretch:~$ source ~/env/bin/activate
(env) vagrant@stretch:~$ cd rpi_cluster/deploy/ansible/
```

# SSH

Execute a command via a Jump Box, or two:

```
$ ssh -J pi@192.168.6.100 pi@192.168.6.16 hostname
omega
$ ssh -J pi@192.168.6.16,pi@192.168.6.100 pi@192.168.6.66 hostname
alpha
```


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


Gather facts

```
ansible all -m setup
```


ansible-lint
------------
https://github.com/willthames/ansible-lint


testinfra
---------
https://testinfra.readthedocs.io/en/latest/


diceware
---------
https://github.com/ulif/diceware


httpie
-------
https://httpie.org/


passlib
-------
https://passlib.readthedocs.io/en/stable/
