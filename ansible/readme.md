About
------

On the Deployer R-Pi (psi) run ~/rpi_cluster/ansible/setup/install-deploye-tools.sh to install these tools (Ansible).

Then ~/rpi_cluster/ansible/setup/keysandconf-new.sh to create new host/group var, and inventory files.

Assumes working from:

```
pi@psi:~ $ source ~/env/bin/activate
(env) pi@psi:~ $ cd rpi_cluster/ansible/
(env) pi@psi:~/rpi_cluster/ansible $
```

```
(env) pi@psi:~ $ pass ssh/id_rsa
(env) pi@psi:~ $ eval `ssh-agent`
(env) pi@psi:~ $ ssh-add
Enter passphrase for /home/pi/.ssh/id_rsa:
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


Ansible
-------
http://docs.ansible.com/ansible/latest/index.html

Store facts in local Redis DB, from ansible.cfg

```
gathering = smart
fact_caching = redis
fact_caching_connection = localhost:6379:0
fact_caching_timeout = 86400
```

login with default creds

```
$ ansible all -a "uname -a" -f 10 -e "ansible_user=pi ansible_ssh_pass=raspberry ansible_sudo_pass:raspberry" -e 'host_key_checking=False'
```


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

see all hosts in inventory

```
ansible all -m debug | grep SUCCESS | awk '{print $1}'
```

copy a file to a host:

```
ansible psi -m copy -a "src=~/foo dest=/tmp/bar"
```


Gather facts:

```
$ ansible all -m setup
```

ping:

```
$ ansible all -m ping
```


ARA
---
https://github.com/openstack/ara

```
(env) pi@psi:~/rpi_cluster/ansible $ ansible-playbook play-deployer.yml
(env) pi@psi:~/rpi_cluster/ansible $ ara-manage runserver
```


ansible-lint
------------
https://github.com/willthames/ansible-lint

```
pi@psi:~ $ source ~/env/bin/activate
(env) pi@psi:~ $ cd rpi_cluster/ansible/
(env) pi@psi:~/rpi_cluster/ansible $ ansible-lint play-rpi-all-maint.yml
```


testinfra
---------
https://testinfra.readthedocs.io/en/latest/


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


pytest
------
https://docs.pytest.org/en/latest/

Test the local deployer:

```
pytest test-rpideployer.py
```

---
