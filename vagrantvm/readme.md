vagrantvm
---------

This folder contains files for the VagrantVM.

Related files: ./deploy/ansible/roles/host-vagrantvm/

## Using

If you get an error about mounting folders, this might be required:

```
$ vagrant plugin install vagrant-vbguest
```

If rpi_cluster becomes unmounted, just run the provisioning command.

```
$ vagrant provision
```


Notes and links:
----------------

* https://www.vagrantup.com/docs/vagrantfile/
* https://github.com/dotless-de/vagrant-vbguest
* https://github.com/lfit/itpol/blob/master/linux-workstation-security.md


EOF
