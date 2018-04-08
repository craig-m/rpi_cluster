"""
R-Pi Cluster VagrantVM fabfile.py
"""
# Remeber, run "source ~/env/bin/source" before using!

from fabric.tasks import *
from fabric.api import *
from fabric.network import *
from fabric.context_managers import *
from fabric.contrib.files import *

from datetime import datetime

import os
from os import path
from glob import glob
import sys

"""
environment varibles
"""

env.user = 'pi'
env.use_ssh_config = True
env.output_prefix = True
env.timeout = 30
env.connection_attempts = 3
env.parallel = False

"""
functions
"""

def setup_packages():
    print "[*] Installing apt packages "
    sudo("apt-get update -qq >/dev/null")
    sudo("apt-get install -qq -y screen rsync >/dev/null")

def bootstrap_remote():
    """ setup """
    print "[*] run bootstrap script on remote system and detach "
    local("logger 'rpicluster:  on %s@%s under screen'" % (env.user, env.host))
    run('screen -c  ~/rpi_cluster/deploy/ansible/files/fab_screenrc -L -d -m  ~/rpi_cluster/deploy/scripts/; sleep 3')

def check_bootstrap():
    """ check bootstrap is running  """
    print "[*] checking bootstrap-deployer  "
    run('sleep 2; ps aux | grep "" | grep -v grep')


"""
Tasks
"""

@task
def deployer_psi_upload():
    """ just push code to psi deployer (needs -H <ip>) """
    local('sh /opt/cluster/bin/upload_to_psi.sh %s' % (env.host))
    run('ls -la ~/rpi_cluster | grep rpi_cluster')


@task
def deployer_psi_bootstrap():
    """ run  on remote psi node (needs -H <ip>) """
    execute(setup_packages)
    execute(upload_to_psi)
    execute(bootstrap_remote)
    execute(check_bootstrap)


@task
def deployer_local_bootstrap():
    """ run  on local VagrantVM """
    local('sh ~/rpi_cluster/admin/ansible/scripts/')
