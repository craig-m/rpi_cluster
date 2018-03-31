#!/bin/bash
# https://github.com/PowerShell/PowerShell/blob/master/docs/installation/linux.md#debian-9

# pre-run checks ---------------------------------------------------------------

# Only run Vagrantfile.sh on Debian stretch
if [[ stretch != "$(hostname)" ]]; then
  echo "Error: stretch vbox only";
  exit 1;
fi

# output/log function
rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}

rpicluster "starting install_powershell.sh"

#-------------------------------------------------------------------------------

export DEBIAN_FRONTEND=noninteractive;

# Install system components
/usr/bin/sudo apt-get update
/usr/bin/sudo apt-get install -y curl gnupg apt-transport-https

# Import the public repository GPG keys
curl https://packages.microsoft.com/keys/microsoft.asc | /usr/bin/sudo apt-key add -

# Register the Microsoft Product feed
/usr/bin/sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-stretch-prod stretch main" > /etc/apt/sources.list.d/microsoft.list'

# Update the list of products
/usr/bin/sudo apt-get update

# Install PowerShell
/usr/bin/sudo apt-get install -y powershell

rpicluster "finished install_powershell.sh"

# Start PowerShell
pwsh
