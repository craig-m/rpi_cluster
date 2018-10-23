#!/bin/bash
# copy_ssh_key.sh

# Uses scanssh to find all live Raspbian SSH hosts on the network.
# Then uses ssh-keygen, ssh-keyscan, ssh-copy-id (with sshpass), on each host.
#
# (copies ~/.ssh/id_rsa.pub to all R-Pi on Lan with default creds)

# pre-run tasks ----------------------------------------------------------------

# do not run this script as root
if [[ root = "$(whoami)" ]]; then
  echo "ERROR: do not run as root";
  exit 1;
fi

# check for private key
file ~/.ssh/id_rsa | grep "PEM RSA private key" || exit 1

# make tempfile
tmp_hostsout=$(mktemp)

# log
rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}

rpilogit "starting copy_ssh_key.sh";

#-------------------------------------------------------------------------------

# Scan LAN for Raspbian SSHD
echo -e "[*] running scanssh on 192.168.6.0/24 ";
sudo scanssh -n 22 -s ssh 192.168.6.0/24 | grep Raspbian | grep "192.168.6" | awk '{print $1}' | sed -s 's/\:22//' > ${tmp_hostsout};
echo -e "[*] processing list: ${tmp_hostsout} \n";


IFS=$'\n'
for livehost in $(cat $tmp_hostsout)
do
	echo -e "------ ${livehost} ------ ";
  echo -e "(*) removing any old key from known_hosts:";
  ssh-keygen -R "${livehost}";

  echo -e "(*) scan/add to known_hosts:";
  /usr/bin/timeout 8s ssh-keyscan -H "${livehost}" >> ~/.ssh/known_hosts;

  echo "(*) try to copy public ssh key:";
  /usr/bin/timeout 10s sshpass -p raspberry ssh-copy-id -i ~/.ssh/id_rsa.pub pi@"${livehost}";
	if [ $? -eq 1 ]; then
    echo "(x) copying failed";
	fi

	# test connection
	thehostname=$(/usr/bin/timeout 4s ssh -y -2 -S none -a -4 pi@"${livehost}" hostname;)
	echo "(*) hostname is: ${thehostname}";
done

# Summary
hostcount=$(wc -l ${tmp_hostsout} | awk {'print $1'})
echo -e "[*] processed $hostcount hosts ";

# do localhost also
ssh-keygen -R 127.0.0.1
ssh-keyscan -H 127.0.0.1 >> ~/.ssh/known_hosts;


# done
rpilogit "copy_ssh_key.sh ran on $hostcount hosts ";
echo -e "[*] Done ";

# EOF --------------------------------------------------------------------------
