"""
Raspberry Pi Cluster Admin tasks.
"""
# Use this file with Invoke - http://www.pyinvoke.org/

from invoke import task, run

# deployer ---------------------------------------------------------------------

@task
def deployer_ansible(c):
    """ ansible deployer role on Psi (localhost). """
    print("Running play-rpi-deployer.yml")
    c.run('ansible-playbook --connection=local -i /etc/ansible/inventory/deploy -v play-rpi-deployer.yml')

@task
def deployer_ssh_config(c):
    """ Generate ~/.ssh/config file from Ansible inventory. """
    print("Creating new ssh config file")
    c.run('ansible-playbook --connection=local -e "runtherole=group-deployer-ssh-client" -v single-role.yml')

# specific hosts ---------------------------------------------------------------

@task
def ansible_ping(c, hostname):
    """ Ansible Ping a host. Eg: invoke ansible-ping omega """
    c.run("ansible %s -m ping;" % hostname)

@task
def ansible_sshd(c, hostname):
    """ Change default SSH login on new R-Pi. """
    print("Running ssh-server role")
    c.run('ansible-playbook --limit "%s" -e "ansible_user=pi ansible_ssh_pass=raspberry host_key_checking=False runtherole=ssh-server" -v single-role.yml' % hostname)

# lanservices group ------------------------------------------------------------

@task
def lanservices_main_ansible(c):
    """ ansible services-main playbook on Alpha and Beta. """
    print("Running play-rpi-services-main.yml")
    c.run('ansible-playbook -v play-rpi-services-main.yml')

@task
def lanservices_misc_ansible(c):
    """ ansible services-misc playbook on Omega. """
    print("Running play-rpi-services-misc.yml")
    c.run('ansible-playbook -v play-rpi-services-misc.yml')

# compute cluster (x4 rpi) -----------------------------------------------------

@task
def compute_ansible_base(c):
    """ ansible base playbook on compute group. """
    print("Running play-rpi-compute.yml")
    c.run('ansible-playbook -v play-rpi-compute.yml')

@task
def compute_ansible_web(c):
    """ Setup Web frontend. """
    print("Running play-rpi-compute-webfront.yml")
    c.run('ansible-playbook -v play-rpi-compute-webfront.yml')

@task
def compute_ansible_container(c):
    """ Setup Docker k8 cluster. """
    print("Running play-rpi-compute-containers.yml")
    c.run('ansible-playbook -v play-rpi-compute-containers.yml')

@task
def compute_ansible_container_rm(c):
    """ shutdown and remove docker and k8 cluster. """
    print("Removing docker and kubernetes cluster on compute nodes")
    c.run('ansible docker -i /etc/ansible/inventory/compute -m shell -a "/bin/bash -c /opt/cluster/docker/scripts/remove-kube.sh"')


# tasks fo all hosts  ----------------------------------------------------------

@task
def ansible_gather_facts(c):
    """ Gather facts on all hosts. """
    print("Gathering facts")
    c.run('ansible all -m setup &> /dev/null')

@task
def ansible_test_default(c):
    """ Test default SSH creds on all hosts. """
    print("Testing default SSH password of raspberry")
    c.run('ansible all -a "uname -a" -f 10 -e "ansible_user=pi ansible_ssh_pass=raspberry host_key_checking=False"')

# R-Pi Cluster maint - excludes the Deployer R-Pi.
@task
def ansible_maint(c):
    """ upgrade all R-Pi server hosts (includes rolling reboots). """
    print("Running play-rpi-all-maint.yml")
    c.run('ansible-playbook -v play-rpi-all-maint.yml')

# test Deployer, lanservices main + misc
@task
def cluster_serverspec(c):
    """ ServerSpec tests. """
    print("Running ServerSpec")
    c.run('cd ../serverspec/ && bash run.sh')

# end --------------------------------------------------------------------------
