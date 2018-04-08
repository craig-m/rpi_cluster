vagrantvm
---------


This folder contains files for the VagrantVM (stretch).


## Setup

Scripts that configure this VM:

* vagrantvm/vagrantfile_root.sh (automatic on 'vagrant up')
* vagrantvm/vagrantfile_user.sh (automatic on 'vagrant up')
* ansible/ (manual)
* ansible/roles/host-vagrantvm/ (called in )


## Using

If you get an error about mounting folders, this might be required:

```
$ vagrant plugin install vagrant-vbguest
```

If /home/vagrant/rpi_cluster becomes unmounted, just run the provisioning command.


```
$ vagrant reload
$ vagrant ssh
```


```
ssh-agent bash
pass ssh/id_rsa_pw
ssh-add
ssh-add -l
```

```
source ~/env/bin/activate
cd ~/rpi_cluster/ansible/
fab -l
```


Notes and links:
----------------

* https://www.vagrantup.com/docs/vagrantfile/
* https://github.com/dotless-de/vagrant-vbguest
* https://github.com/lfit/itpol/blob/master/linux-workstation-security.md


EOF
