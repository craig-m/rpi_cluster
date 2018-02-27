#!/bin/bash
# Disable Swap
/usr/bin/sudo dphys-swapfile swapoff

/usr/bin/sudo dphys-swapfile uninstall

/usr/bin/sudo update-rc.d dphys-swapfile remove
