#!/bin/bash
echo "Installing Hugo";

# create a temp dir
hugo_inst_tmpdir=$(mktemp -d)

wget https://github.com/gohugoio/hugo/releases/download/v0.54.0/hugo_0.54.0_Linux-ARM.deb -O ${hugo_inst_tmpdir}/hugo.deb;
if [ $? -eq 0 ]; then
  echo "downloaded hugo deb";
else
  rpilogit "FAILED to download hugo deb"
	exit 1;
fi

# get filesum
checkpgpkey=$(sha256sum ${hugo_inst_tmpdir}/hugo.deb | awk {'print $1'})

# check sum of file before adding
if [ $checkpgpkey = "1ad870d5047d8ace276b2a8a286c9a42bb20e75d048a4517e0422b549d515284" ]; then
	echo "hugo sha OK"
else
	rpilogit "BAD FILESUM"
	exit 1;
fi

sudo dpkg -i ${hugo_inst_tmpdir}/hugo.deb
