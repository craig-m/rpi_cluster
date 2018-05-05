# check deployer

# pi cluster deployer ----------------------------------------------------------

def test_hostinfor_file(host):
    hostname = host.file("/opt/cluster/data/info_host.txt")
    assert hostname.contains("Raspberry Pi Cluster")

def test_hostname_file(host):
    infotxt = host.file("/opt/cluster/data/info_roles.txt")
    assert infotxt.contains("Ansible Roles run against this host")

# general rpi deployer role (psi) ----------------------------------------------

def test_haveged_running_and_enabled(host):
    haveged = host.service("haveged")
    assert haveged.is_running
    assert haveged.is_enabled

#-------------------------------------------------------------------------------
