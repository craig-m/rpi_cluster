#!/bin/bash
# Test if cgroup options are set in cmdline.txt.
# 0 = no
# 1 = yes
grep "cgroup_enable=memory cgroup_memory=1" /boot/cmdline.txt | wc -l
