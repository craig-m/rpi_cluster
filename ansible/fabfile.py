"""
--==  rpi_cluster deployer fabric file  ==--
"""
# http://www.fabfile.org/

from fabric.tasks import *
from fabric.api import *
from fabric.network import *
from fabric.context_managers import *
from fabric.contrib.files import *
from datetime import datetime
from os import path
from glob import glob
import os
import sys

"""
environment varibles
"""

env.user = 'pi'
env.use_ssh_config = False
env.output_prefix = False
env.timeout = 30
env.keepalive = 20
env.connection_attempts = 3
env.parallel = False
env.forward_agent = False

"""
Tasks
"""

# ansible commands -------------------------------------------------------------

@task
def ansible_hostinfo():
    """ Run setup module to gather facts on all hosts.  """
    local('export ANSIBLE_CONFIG="$PWD"')
    local('ansible all -m setup')


@task
def ansible_ping():
    """ Run ping module.  """
    local('export ANSIBLE_CONFIG="$PWD"')
    local('ansible all -m ping')


@task
def ansible_0_rpi_default():
    """ setup ssh access - configure default raspbian install (all)  """
    local('ansible all -a "uname -a" -f 10 -e "ansible_user=pi ansible_ssh_pass=raspberry ansible_sudo_pass:raspberry host_key_checking=False"')
    local('ansible-playbook play-rpi-all-ssh.yml -e "ansible_user=pi ansible_ssh_pass=raspberry ansible_sudo_pass:raspberry host_key_checking=False"')


@task
def ansible_1_deploy_rpi():
    """ Playbook - Setup Deployer (psi) """
    local('ansible-playbook play-rpi-deployer.yml -i inventory/deploy -e "ansible_user=pi"')


@task
def ansible_2_lan_services():
    """ Playbook - LanServices (alpha, beta, omega)  """
    local('ansible-playbook play-rpi-services-main.yml -v')
    local('ansible-playbook play-rpi-services-misc.yml -v')


@task
def ansible_3_compute():
    """ Playbook - Compute - base (gamma, delta, epsilon, zeta) """
    local('ansible-playbook play-rpi-compute.yml -v')


@task
def ansible_4_compute_webapp():
    """ Playbook - Compute - hosting """
    local('ansible-playbook play-rpi-compute-webfront.yml -v')


@task
def ansible_5_compute_containers():
    """ Playbook - Compute - Containers """
    local('ansible-playbook play-rpi-compute-containers.yml -v')


@task
def cluster_maintainence():
    """ upgrades (includes rolling reboots) """
    local('ansible-playbook play-rpi-all-maint.yml -v')
    #local('ansible-playbook -e "runtherole=upgrades" single-role.yml')


@task
def cluster_shutdown():
    """ shutdown cluster - ansible (excludes deployer) """
    with settings(warn_only=True):
        print('Powering down all nodes')
        local('ansible compute -a "shutdown -h now" -f 4 --become')
        local('ansible lanservices -a "shutdown -h now" -f 1 --become')
        local('ansible misc -a "shutdown -h now" -f 2 --become')
        local('ansible all -m ping')


# code deploy ------------------------------------------------------------------

@task
def deploy_omega_site():
    """ code/hugo-site """
    local ('logger -t rpicluster "fabfile.py start deploy_omega_site "')
    print('building with hugo')
    local('cd ../code/hugo-site/ && hugo')
    print('uploading public web code')
    local('cd ../code/hugo-site/ && rsync -avr -- public/ pi@omega.local:/srv/nginx/hugo-site/')
    local ('logger -t rpicluster "fabfile.py finish deploy_omega_site "')


# testing ----------------------------------------------------------------------

@task
def serverspec_tests():
    """ Run ServerSpec tests on cluster. """
    local('cd ../serverspec/ && bash run.sh')


# EOF
