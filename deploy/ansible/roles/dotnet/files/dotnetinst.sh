#!/bin/bash

# Install MS DotNet
# https://github.com/dotnet/core/blob/master/samples/RaspberryPiInstructions.md

rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}

rpilogit "starting dotnetinst.sh"

sudo apt-get -y update
sudo apt-get -y install libunwind8 gettext

# Download the nightly binaries for .NET Core 2
wget https://dotnetcli.blob.core.windows.net/dotnet/Runtime/release/2.0.0/dotnet-runtime-latest-linux-arm.tar.gz

# Create a folder to hold the .NET Core 2 installation
sudo mkdir /opt/dotnet/srv -pv

# Unzip the dotnet zip into the dotnet installation folder
sudo tar -xvf dotnet-runtime-latest-linux-arm.tar.gz -C /opt/dotnet

# set up a symbolic link to a directory on the path so we can call dotnet
sudo ln -s /opt/dotnet/dotnet /usr/local/bin

dotnet --info

sudo chown $USER:$USER /opt/dotnet/srv/

rpilogit "finished dotnetinst.sh"
