# Test VagrntVM

# pi cluster deployer ----------------------------------------------------------

def test_hostinfor_file(host):
    hostname = host.file("/opt/cluster/data/info_host.txt")
    assert hostname.contains("Raspberry Pi Cluster")

def test_hostname_file(host):
    infotxt = host.file("/opt/cluster/data/info_roles.txt")
    assert infotxt.contains("Ansible Roles run against this host")

def test_folder_vagrant_home(host):
    userfold = host.file("/home/piclust")
    assert userfold.user == "piclust"
    assert userfold.group == "piclust"

# Vagrant VM -------------------------------------------------------------------

def test_hostname_file(host):
    hostname = host.file("/etc/hostname")
    assert hostname.contains("stretch")

def test_vagrantvm_file(host):
    vagrantvm = host.file("/etc/ansible/facts.d/vagrantvm.fact")
    assert vagrantvm.contains("boxbuild_id")

def test_folder_vagrant_home(host):
    userfold = host.file("/home/vagrant")
    assert userfold.user == "vagrant"
    assert userfold.group == "vagrant"
    assert userfold.mode == 0700


# LAMP -------------------------------------------------------------------------

def test_apache_running_and_enabled(host):
    apache2 = host.service("apache2")
    assert apache2.is_running
    assert apache2.is_enabled

def test_mysql_running_and_enabled(host):
    mysql = host.service("mysql")
    assert mysql.is_running
    assert mysql.is_enabled

def test_haveged_running_and_enabled(host):
    haveged = host.service("haveged")
    assert haveged.is_running
    assert haveged.is_enabled

#-------------------------------------------------------------------------------
