#!/bin/bash
# Install MS DotNet
# https://github.com/dotnet/core/blob/master/samples/RaspberryPiInstructions.md

rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}

rpilogit "starting dotnetinst.sh"

export DEBIAN_FRONTEND=noninteractive

/usr/bin/sudo apt-get -y update;
/usr/bin/sudo apt-get -y install libunwind8 gettext;

# Download the nightly binaries for .NET Core 2
wget https://dotnetcli.blob.core.windows.net/dotnet/Runtime/release/2.0.0/dotnet-runtime-latest-linux-arm.tar.gz;

dotnet_tar_sha=$(sha512sum dotnet-runtime-latest-linux-arm.tar.gz | awk '{print $1}')

# check filesum
if [ $dotnet_tar_sha = "2cab7b9b3597a3c911b48f8f47e6d0118e14939793a97cd3e847a5b20382b4c0de33e91f67bc5853e33f763027396be41cee7c19ea74c4889e8be06b9a771b8b" ]; then
	echo "sha512sum OK"
else
	echo "BAD FILESUM"
	exit 1;
fi

# Create a folder to hold the .NET Core 2 installation
/usr/bin/sudo mkdir /opt/dotnet/srv -pv;

# Unzip the dotnet zip into the dotnet installation folder
/usr/bin/sudo tar -xvf dotnet-runtime-latest-linux-arm.tar.gz -C /opt/dotnet/ --;

# set up a symbolic link to a directory on the path so we can call dotnet
/usr/bin/sudo ln -s /opt/dotnet/dotnet /usr/local/bin;

dotnet --info || exit 1;

/usr/bin/sudo chown $USER:$USER /opt/dotnet/srv/;

sleep 2s;

rpilogit "finished dotnetinst.sh";
