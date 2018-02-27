# check deployer

def test_hostname_file(host):
    infotxt = host.file("/opt/cluster/data/info_roles.txt")
    assert infotxt.contains("Ansible Roles run against this host")

def test_folder_vagrant_home(host):
    userfold = host.file("/home/piclust")
    assert userfold.user == "piclust"
    assert userfold.group == "piclust"

def test_haveged_running_and_enabled(host):
    haveged = host.service("haveged")
    assert haveged.is_running
    assert haveged.is_enabled
