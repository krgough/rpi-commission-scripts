#!/bin/bash

# KG: 01/06/2018 - Carry out apt-get updates
# apt-get update
# apt-get dist-upgrade
# apt-get auto-remove
# apt-get clean

# Check we have root privileges
if [ "$(id -u)" -ne "0" ] ; then
    echo "This script must be executed with root privileges."
    exit 1
fi

# Exit on any error
set -e

# Carry out upgrades
apt-get -y update
apt-get -y dist-upgrade
apt-get -y autoremove
apt-get -y clean



