"""
Raspberry Pi Cluster Admin tasks.
"""

# This file is used with Invoke - http://www.pyinvoke.org/
#
# Ansible is not a good task runner, repetitive actions with long command line
# arguments are easier with Invoke.

import os
import sys
import ansible_runner
from invoke import task, run

if os.getuid() == 0:
    print ("ERROR: Do not run as root.")
    sys.exit(1)

print('\n')
print(' --== Raspberry Pi Cluster administration ==-- ')
print('\n')


#
# tasks for deployer (localhost)
#

@task
def deployer_ansible(c):
    """ Ansible deployer playbook on Psi (localhost). """
    print("Running playbook-rpi-deployer.yml")
    r = ansible_runner.run(private_data_dir='/home/pi/rpi_cluster/ansible', 
                           inventory='/etc/ansible/inventory/deploy', 
                           playbook='playbook-rpi-deployer.yml')
    print("{}: {}".format(r.status, r.rc))
    print("Final status:")
    print(r.stats)

@task
def deployer_ssh_config(c):
    """ Generate ~/.ssh/config file from Ansible inventory. """
    print("Creating new ssh config file")
    c.run('ansible-playbook --connection=local -e "runtherole=group-deployer-ssh-client" -v playbook-rpi-single-role.yml')

@task
def deployer_upgrade(c):
    """ Run upgrade maint role on Deployer. """
    print("Updating")
    c.run('ansible-playbook --connection=local -i /etc/ansible/inventory/deploy -e "runtherole=upgrades" -v playbook-rpi-single-role.yml')


#
# tasks for specific hosts. 
# 
# Examples:
#
# invoke ansible-ping compute
# invoke ansible-ping all

@task
def ansible_ping(c, hostname):
    """ Ansible Ping a host. example: invoke ansible-ping compute """
    c.run("ansible %s -m ping;" % hostname)

@task
def ansible_sshd(c, hostname):
    """ Change default SSH login on new R-Pi. example: invoke ansible_sshd beta """
    print("Running ssh-server role")
    c.run('ansible-playbook --limit "%s" -e "ansible_user=pi ansible_ssh_pass=raspberry host_key_checking=False runtherole=ssh-server" -v playbook-rpi-single-role.yml' % hostname)

@task
def serverspec_host(c, hostname):
    """ ServerSpec test a specific host. """
    print("Running ServerSpec")
    c.run("cd ../serverspec/ && bash run.sh %s" % hostname)


#
# lanservices group
#

@task
def lanservices_main_ansible(c):
    """ Ansible services-main playbook on Alpha and Beta. """
    print("Running playbook-rpi-lanservices.yml")
    c.run('ansible-playbook -v playbook-rpi-lanservices.yml')


#
# compute group
#

@task
def compute_ansible_base(c):
    """ Ansible base playbook on compute group. """
    print("Running playbook-rpi-compute.yml")
    r = ansible_runner.run(private_data_dir='/home/pi/rpi_cluster/ansible', 
                           playbook='playbook-rpi-compute.yml')
    print("{}: {}".format(r.status, r.rc))
    print("Final status:")
    print(r.stats) 

@task
def compute_ansible_k3s(c):
    """ Setup lightweight Kubernetes cluster. """
    print("Running playbook-rpi-compute-k3s.yml")
    r = ansible_runner.run(private_data_dir='/home/pi/rpi_cluster/ansible', 
                           playbook='playbook-rpi-compute-k3s.yml')
    print("{}: {}".format(r.status, r.rc))
    print("Final status:")
    print(r.stats) 


#
# tasks for all hosts
#

@task
def ansible_gather_facts(c):
    """ Gather facts on all hosts. """
    print("Gathering facts")
    c.run('ansible all -m setup &> /dev/null')

@task
def ansible_maint(c):
    """ upgrade all R-Pi server hosts (includes rolling reboots). """
    print("Running playbook-rpi-all-maint.yml")
    r = ansible_runner.run(private_data_dir='/home/pi/rpi_cluster/ansible', 
                           playbook='playbook-rpi-all-maint.yml')
    print("{}: {}".format(r.status, r.rc))
    print("Final status:")
    print(r.stats) 

@task
def serverspec_cluster(c):
    """ ServerSpec tests. """
    print("Running ServerSpec")
    c.run('cd ../serverspec/ && bash run.sh')
