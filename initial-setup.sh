#!/bin/bash

# Initially we cannot clone repos without entering a username/password
# I don't want to hard code those (or show them in Bash history) so
# instead we setup the correct hostname on the rPi first then use
# local (i.e. laptop)# ssh config to forward our ssh key by setting
# "forwardAgent yes" for the new rPI hostname.
# Once hostname is working we can then ssh using that and git clone will
# work.  This script does the initial setup.

# 1. Use LED flash to physically id device matches IP address
# 2. Copy ssh config files (common ssh key, config and authorized_keys)
# 3. Prompt user to ssh into rPi and clone the rpi-commision repo

# Run this with an IP address for the rPi as a command line parameter
IP=$1

if [ -z $1 ]; then
    echo "usage initial-setup.sh ipaddress"
    exit 1
fi

echo "rPi Initial Setup script"
echo ""
echo "Before you run this login to the rPi using ssh@raspberrypi.local"
echo "and change the password."
echo ""

# Copy the SSH config files
echo "Copying SSH configuration files (stuff we don't want to share in github)..."
ssh pi@$1 mkdir -p "/home/pi/.ssh"
scp ssh-config/config ssh-config/id_rsa ssh-config/authorized_keys pi@$1:/home/pi/.ssh/

# Copy the rpi-commission scripts to the device
ssh pi@$1 mkdir -p "/home/pi/repositories/rpi-commission-scripts"
scp * pi@$1:/home/pi/repositories/rpi-commission-scripts/

# Prompt user to ssh into the device directly and do the rest
echo
echo "*************************"
echo "All done."
echo "Log onto the rpi and run commissionScript.sh"
