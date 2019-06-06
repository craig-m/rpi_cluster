"""
Raspberry Pi Cluster Admin tasks.
"""
#
# This file is used with Invoke - http://www.pyinvoke.org/
#
# Ansible is not a good task runner, repetitive actions with long command line
# arguments are easier with Invoke.

from invoke import task, run

# tasks run on deployer ------------------------------------------------------

@task
def deployer_ansible(c):
    """ ansible deployer role on Psi (localhost). """
    print("Running playbook-rpi-deployer.yml")
    c.run('ansible-playbook --connection=local -i /etc/ansible/inventory/deploy -v playbook-rpi-deployer.yml')

@task
def deployer_ssh_config(c):
    """ Generate ~/.ssh/config file from Ansible inventory. """
    print("Creating new ssh config file")
    c.run('ansible-playbook --connection=local -e "runtherole=group-deployer-ssh-client" -v single-role.yml')

@task
def deployer_upgrade(c):
    """ Run upgrade maint role on Deployer """
    print("Updating")
    c.run('ansible-playbook --connection=local -i /etc/ansible/inventory/deploy -e "runtherole=upgrades" -v single-role.yml')



# specific hosts ---------------------------------------------------------------
# ex: invoke ansible-ping compute
# ex: invoke ansible-ping all

@task
def ansible_ping(c, hostname):
    """ Ansible Ping a host. example: invoke ansible-ping compute """
    c.run("ansible %s -m ping;" % hostname)

@task
def ansible_sshd(c, hostname):
    """ Change default SSH login on new R-Pi. example: invoke ansible_sshd beta """
    print("Running ssh-server role")
    c.run('ansible-playbook --limit "%s" -e "ansible_user=pi ansible_ssh_pass=raspberry host_key_checking=False runtherole=ssh-server" -v single-role.yml' % hostname)

# serverspec test a host
@task
def serverspec_host(c, hostname):
    """ ServerSpec test a specific host. """
    print("Running ServerSpec")
    c.run("cd ../serverspec/ && bash run.sh %s" % hostname)

# lanservices group ------------------------------------------------------------

@task
def lanservices_main_ansible(c):
    """ ansible services-main playbook on Alpha and Beta. """
    print("Running playbook-rpi-services-main.yml")
    c.run('ansible-playbook -v playbook-rpi-services-main.yml')

@task
def lanservices_misc_ansible(c):
    """ ansible services-misc playbook on Omega. """
    print("Running playbook-rpi-services-misc.yml")
    c.run('ansible-playbook -v playbook-rpi-services-misc.yml')


# compute cluster (x4 rpi) -----------------------------------------------------

@task
def compute_ansible_base(c):
    """ ansible base playbook on compute group. """
    print("Running playbook-rpi-compute.yml")
    c.run('ansible-playbook -v playbook-rpi-compute.yml')

@task
def compute_ansible_container(c):
    """ Setup Docker k8 cluster. """
    print("Running playbook-rpi-compute-containers.yml")
    c.run('ansible-playbook -v playbook-rpi-compute-containers.yml')

@task
def compute_ansible_container_rm(c):
    """ shutdown and remove docker and k8 cluster. """
    print("Removing docker and kubernetes cluster on compute nodes")
    c.run('ansible docker -i /etc/ansible/inventory/compute -m shell -a "/bin/bash -c /opt/cluster/docker/scripts/remove-kube.sh"')


# tasks for all hosts  ----------------------------------------------------------

@task
def ansible_gather_facts(c):
    """ Gather facts on all hosts. """
    print("Gathering facts")
    c.run('ansible all -m setup &> /dev/null')

# R-Pi Cluster maint - excludes the Deployer R-Pi.
@task
def ansible_maint(c):
    """ upgrade all R-Pi server hosts (includes rolling reboots). """
    print("Running playbook-rpi-all-maint.yml")
    c.run('ansible-playbook -v playbook-rpi-all-maint.yml')

# test all nodes in the clsuter with ServerSpec
@task
def serverspec_cluster(c):
    """ ServerSpec tests. """
    print("Running ServerSpec")
    c.run('cd ../serverspec/ && bash run.sh')

# end --------------------------------------------------------------------------
