#!/bin/bash
# name: install.sh
# desc: Setup OS env for OmegaPyAPI flask app

# pre-run tasks ----------------------------------------------------------------

echo "[*] installing OmegaPyAPI"

runas=$(id | cut -c5-5)
if [ $runas -eq "0" ]; then
  echo -e "* Do NOT run this as root";
  exit 1;
fi

runas=$(/usr/bin/sudo id | cut -c5-5)
if [ $runas -eq "0" ]; then
  echo -e "* Can sudo OK";
else
  echo -e "* ERROR: no sudo use";
  exit 1;
fi

rpilogit () {
	echo -e "rpicluster: $1 \n";
	logger -t rpicluster "$1";
}

rpilogit "omegapyapi starting install.sh";

if [ -f /etc/systemd/system/omegapyapi.service ]; then
  /usr/bin/sudo systemctl stop omegapyapi.service
fi

# install ----------------------------------------------------------------------

# create user account if missing
if [ ! -d /opt/omegapyapi ]; then
  echo "[*] creating user"
  /usr/bin/sudo mkdir /opt/omegapyapi
  /usr/bin/sudo useradd omegapyapi --home-dir /opt/omegapyapi --shell /bin/bash
  /usr/bin/sudo chown omegapyapi:pi /opt/omegapyapi
fi

echo "[*] copy code"
/usr/bin/sudo cp -r -- app/ /opt/omegapyapi

echo "[*] fix perms"
/usr/bin/sudo chown omegapyapi:omegapyapi /opt/omegapyapi/* -R
/usr/bin/sudo chmod 755 /opt/omegapyapi/app/start.sh
/usr/bin/sudo chmod 755 /opt/omegapyapi/app/app_install.sh

echo "[*] running app_install.sh"
/usr/bin/sudo su -l omegapyapi /opt/omegapyapi/app/app_install.sh

echo "[*] copy omegapyapi.service and reload"
/usr/bin/sudo cp -- omegapyapi.service /etc/systemd/system/omegapyapi.service
/usr/bin/sudo systemctl daemon-reload

# setup finished ---------------------------------------------------------------

echo "[*] starting"
/usr/bin/sudo systemctl start omegapyapi.service
/usr/bin/sudo ps aux | grep omegapyapi | grep python

echo "[*] test unix socket: "
omegapiget=$(curl -s -X GET --unix-socket /opt/omegapyapi/omegapyapi.socket http:)
echo "${omegapiget}";

rpilogit "omegapyapi finished install.sh";

# EOF --------------------------------------------------------------------------
