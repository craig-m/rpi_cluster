#!/bin/bash
#
# Writing to drop_caches will cause the kernel to free pagecache, dentries and inodes.
# This causes that memory to become free. non-destructive & safe for production
#
# ref: https://www.kernel.org/doc/Documentation/sysctl/vm.txt

freebefore=$(free -k | awk '/^Mem:/{print $4}')

# need to sync first
/usr/bin/sudo sync
/usr/bin/sudo echo 3 > /proc/sys/vm/drop_caches

freeafter=$(free -k | awk '/^Mem:/{print $4}')

freekb=$(expr $freeafter - $freebefore)
let freemb=($freekb/1024)

echo "freed $freekb kilobytes ($freemb MB)"
