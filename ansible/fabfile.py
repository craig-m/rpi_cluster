"""
rpi_cluster deployer fabric file
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

def default_host_init():
    " default Raspbian password "
    env.user = 'pi'
    env.password = 'raspberry'
    env.disable_known_hosts = False
    env.reject_unknown_hosts = False
    env.no_agent = True
    env.connection_attempts = 2
    env.output_prefix = True


"""
Tasks
"""

@task
def rpi_sshtest():
    """ test default login """
    with settings(warn_only=True):
        """ test default ssh is up """
        print("[*] testing SSH using password on %(host)s as %(user)s" % env)
        execute(default_host_init)
        run("hostname")
        run("hostname -I")
        print "MAC of eth0:"
        run("cat /sys/class/net/eth0/address")
        print "SSH fingerprints:"
        sudo("ssh-keygen -lf /etc/ssh/ssh_host_ecdsa_key")
        sudo("ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key")


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
def ansible_1_deploy_rpi():
    local('ansible-playbook play-deployer.yml -i inventory/deploy')

@task
def ansible_2_lansrv_main():
    """ Playbook - LanServices - (alpha, beta, omega)  """
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
