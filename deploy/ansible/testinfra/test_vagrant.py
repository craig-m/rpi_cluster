# Test VagrntVM

def test_hostname_file(host):
    hostname = host.file("/etc/hostname")
    assert hostname.contains("stretch")

def test_apache_running_and_enabled(host):
    apache2 = host.service("apache2")
    assert apache2.is_running
    assert apache2.is_enabled

def test_mysql_running_and_enabled(host):
    mysql = host.service("mysql")
    assert mysql.is_running
    assert mysql.is_enabled

def test_folder_vagrant_home(host):
    userfold = host.file("/home/vagrant")
    assert userfold.user == "vagrant"
    assert userfold.group == "vagrant"
    assert userfold.mode == 0700

def test_folder_vboxdev_home(host):
    userfold = host.file("/home/vboxdev")
    assert userfold.user == "vboxdev"
    assert userfold.group == "vboxdev"
