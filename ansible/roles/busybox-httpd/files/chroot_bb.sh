#!/bin/bash
#
# name: chroot_bb.sh
# desc: Build a minimal chroot for Busybox - run as root


# vars:
chroot_dir="/opt/chroot_bb"
chroot_user="bbweb"

# cd into the dir this script is located in
cd "$(dirname "$0")" | { echo "ERROR changing dir"; exit 1; }
pwd

#-------------------------------------------------------------------------------

script_name=$(basename -- "$0")

rpilogit () {
	echo -e "rpicluster: $script_name $1 \n";
	logger -t rpicluster "$script_name $1";
}

rpilogit "starting busybox httpd chroot install"

systemctl stop bbhttpd

if id -u ${chroot_user}; then
  rpilogit "user exists";
else
  adduser $chroot_user --disabled-password --gecos "" --no-create-home --shell /bin/false || exit 1;
  rpilogit "added ${chroot_user}";
fi

# file and folders -------------------------------------------------------------

if [ -d /${chroot_dir}/ ]; then
	rpilogit "/${chroot_dir}/ exists"
else
  mkdir -v /${chroot_dir}/
  rpilogit "/${chroot_dir}/ created"
fi

mkdir -pv \
  /${chroot_dir}/dev/pts \
  /${chroot_dir}/proc \
  /${chroot_dir}/etc \
  /${chroot_dir}/lib \
  /${chroot_dir}/usr/lib \
  /${chroot_dir}/bin \
  /${chroot_dir}/var/run \
  /${chroot_dir}/var/log \
  /${chroot_dir}/home/${chroot_dir} \
  /${chroot_dir}/www/cgi-bin \
  /${chroot_dir}/www/reports \
  /${chroot_dir}/www/static/img

sleep 1s;

cp -v httpd.conf /${chroot_dir}/etc/httpd.conf

#cp -v index.html /opt/chroot_bb/www/index.html
cp -v glinder1.png /opt/chroot_bb/www/static/glinder1.png

cp -v hello /${chroot_dir}/www/cgi-bin/hello
chmod 555 /${chroot_dir}/www/cgi-bin/hello

chown pi:pi -R /${chroot_dir}/www/

# create dev/urandom if not exists
if [ ! -e /${chroot_dir}/dev/urandom ]; then
  mknod /${chroot_dir}/dev/urandom c 1 9
  chmod 0666 /${chroot_dir}/dev/urandom
fi

# create dev/ptmx if not exists
if [ ! -e /${chroot_dir}/dev/ptmx ]; then
  mknod /${chroot_dir}/dev/ptmx c 5 2
  chmod 0666 /${chroot_dir}/dev/ptmx
fi

mount -o bind /proc /${chroot_dir}/proc/

cp -v /etc/localtime /${chroot_dir}/etc/
cp -v /etc/nsswitch.conf /${chroot_dir}/etc/
cp -v /etc/resolv.conf /${chroot_dir}/etc/
cp -v /etc/host.conf /${chroot_dir}/etc/
cp -v /etc/hosts /${chroot_dir}/etc/
cp -v /etc/shells /${chroot_dir}/etc/

# touch /${chroot_dir}/var/log/lastlog
# touch /${chroot_dir}/var/run/utmp
# touch /${chroot_dir}/var/log/wtmp

cp -v /bin/busybox /${chroot_dir}/bin/

# systemctl script
cp -v bbhttpd.service /lib/systemd/system/bbhttpd.service

# Enter chroot dir and make symlinks
cd /${chroot_dir}/bin/
pwd
ln -sf busybox ash
ls -la

cp -v /lib/arm-linux-gnueabihf/libresolv.so.2 /${chroot_dir}/lib/
cp -v /usr/lib/arm-linux-gnueabihf/libarmmem-v6l.so /${chroot_dir}/usr/lib/
cp -v /lib/ld-linux-armhf.so.3 /${chroot_dir}/lib/
cp -v /lib/arm-linux-gnueabihf/libc.so.6 /${chroot_dir}/lib/

grep ^root /etc/passwd > /${chroot_dir}/etc/passwd
grep ^root /etc/group > /${chroot_dir}/etc/group
grep ^root /etc/shadow > /${chroot_dir}/etc/shadow

grep ^${chroot_user} /etc/passwd >> /${chroot_dir}/etc/passwd
grep ^${chroot_user} /etc/group >> /${chroot_dir}/etc/group
grep ^${chroot_user} /etc/shadow >> /${chroot_dir}/etc/shadow

#-------------------------------------------------------------------------------

# test chroot
chroot --userspec=${chroot_user}:${chroot_user} /${chroot_dir}/ /bin/busybox id 
if [ $? -eq 0 ]; then
  echo "chroot tested OK";
  touch -f /opt/chroot_bb/etc/tested
else
  echo "error testing chroot"
  exit 1;
fi

rpilogit "starting service"

# systemd service
systemctl daemon-reload
systemctl enable bbhttpd.service
systemctl start bbhttpd.service

echo "done"
#-------------------------------------------------------------------------------
