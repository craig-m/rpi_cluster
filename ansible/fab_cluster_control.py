"""
R-Pi cluster control (task run on all nodes)
"""

from fabric.tasks import *
from fabric.api import *
from fabric.network import *
from fabric.context_managers import *
from fabric.contrib.files import *

import sys

env.parallel = True

env.use_ssh_config = True
env.output_prefix = True
env.timeout = 15
env.connection_attempts = 3
env.hosts = [ 'alpha.local', 'beta.local', 'omega.local', 'gamma.local', 'delta.local', 'epsilon.local', 'zeta.local', 'psi.local' ]

@task
@parallel
def rpi_sshtest():
    """ get ssh rsa keygen """
    run("/usr/bin/ssh-keygen -f /etc/ssh/ssh_host_rsa_key -l")

@task
@parallel
def rpi_rpiledblink():
    """ rpi blink """
    run("/opt/cluster/bin/led-blink.sh")

@task
@parallel
def rpi_get_info():
    """ rpi host """
    run("uname -a")
    run("uptime")
    run("cat /sys/class/net/eth0/address")

@task
@parallel
def rpi_get_temp():
    """ rpi temp """
    sudo("cat /sys/class/thermal/thermal_zone0/temp")

@task
@parallel
def rpi_powerdown():
    """ rpi powerdown """
    run("logger -t rpicluster 'fabric powering down'")
    sudo("shutdown -h now")

@task
@parallel
def rpi_reboot():
    """ rpi reboot all"""
    sudo("reboot")
