About
------

After following the setup procedure described in `doc/readme.md` the usual workflow is:

```
pi@psi:~ $ source ~/env/bin/activate
(env) pi@psi:~ $ cd rpi_cluster/ansible/
(env) pi@psi:~/rpi_cluster/ansible $ pass ssh/id_rsa
(env) pi@psi:~/rpi_cluster/ansible $ eval `ssh-agent`
(env) pi@psi:~/rpi_cluster/ansible $ ssh-add
Enter passphrase for /home/pi/.ssh/id_rsa:
(env) pi@psi:~/rpi_cluster/ansible $ invoke -l
```

---


# SSH

Execute a command via a Jump Box

```
(env) pi@psi:~ $ ssh -J alpha beta hostname
beta
```

or three:

```
(env) pi@psi:~ $ ssh -J pi@alpha.local,pi@beta.local,pi@omega.local pi@zeta.local hostname;
zeta
```

ssh port forwarding also works (the httpd on zeta is available on deployer at localhost:8888):

```
(env) pi@psi:~ $ ssh -J pi@alpha.local,pi@beta.local,pi@omega.local pi@zeta.local -L 8888:127.0.0.1:80
```


## key renew

The SSHD will only accept keys signed by a CA key.
As per: https://code.facebook.com/posts/365787980419535/scalable-and-secure-access-with-ssh/

When SSH from Psi to the other hosts stops working...

```
(env) pi@psi:/opt/cluster/bin $ /opt/cluster/bin/renew-ssh-priv-key.sh
```

This will generate a new set of keys:

```
Signed user key /home/pi/.ssh/id_rsa-cert.pub: id "pi" serial 5 for pi valid from 2018-10-28T22:09:00 to 2018-11-04T22:10:49
done
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

```
$ invoke ansible-ping all
```

Run all roles

```
$ ansible-playbook site.yml
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
https://github.com/ansible/ansible-lint

```
pi@psi:~ $ source ~/env/bin/activate
(env) pi@psi:~ $ cd rpi_cluster/ansible/
(env) pi@psi:~/rpi_cluster/ansible $ ansible-lint site.yml
```

Of the [https://docs.ansible.com/ansible-lint/rules/default_rules.html](default_rules) list there are a couple of little issues to fix up ;)


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
pytest files/test-rpideployer.py
```

---


Upgrade Ansible, and all other python packages:

```
pip install --upgrade pip
pip install --upgrade -r requirements.txt
```