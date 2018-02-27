#!/bin/bash
# install_ssh_key.sh

# Uses scanssh to find all live Raspbian SSH hosts on the network.
# Then uses ssh-keygen, ssh-keyscan, ssh-copy-id (with sshpass), on each host.

# make tempfile
tmp_hostsout=$(mktemp)

# log
rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}
rpilogit "starting install_ssh_key.sh";

# Scan lan for Raspbian SSHD
echo -e "[*] running scanssh on 192.168.6.0/24 ";
sudo scanssh -n 22 -s ssh 192.168.6.0/24 | grep Raspbian | grep "192.168.6" | awk '{print $1}' | sed -s 's/\:22//' > ${tmp_hostsout};
echo -e "[*] processing list: ${tmp_hostsout} \n";

IFS=$'\n'
for livehost in $(cat $tmp_hostsout)
do
	echo -e "------ ${livehost} ------";
  echo -e "(*) removing any old key:";
  ssh-keygen -R ${livehost};
  echo -e "(*) scan/add key:";
  /usr/bin/timeout 8s ssh-keyscan -H ${livehost} >> ~/.ssh/known_hosts;
  echo "(*) copy key:";
  /usr/bin/timeout 8s sshpass -p raspberry ssh-copy-id -i ~/.ssh/id_rsa.pub pi@${livehost};
	# test connection
	thehostname=$(/usr/bin/timeout 4s ssh -y -2 -S none -a -4 pi@${livehost} hostname;)
  echo "(*) test SSH (get hostname): ${thehostname}";
done

# Summary
hostcount=$(wc -l ${tmp_hostsout} | awk {'print $1'})
echo -e "[*] processed $hostcount hosts ";

# do localhost also
ssh-keygen -R 127.0.0.1
ssh-keyscan -H 127.0.0.1 >> ~/.ssh/known_hosts;

# done
rpilogit "install_ssh_key.sh ran on $hostcount hosts ";
echo -e "[*] Done ";

# EOF
