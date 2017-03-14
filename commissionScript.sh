#!/bin/bash

# Setup the correct hostname 
if [ "$1" == "" ]; then
  echo "usage commissionScript newHostname"
  exit 1
fi

# Modify the /etc/hosts file
# sendmail needs the <hostname.local> entry
hosts="$1 $1.local"
resp=$(grep "127.0.1.1" /etc/hosts)
echo "Removing from /etc/hosts:    $resp"
sudo sed -i '/127.0.1.1/d' /etc/hosts
echo "Adding to /etc/hosts:        127.0.1.1    $hosts"
echo "127.0.1.1 $hosts" | sudo tee -a /etc/hosts > /dev/null

# Modify the /etc/hostname file
resp=$(cat /etc/hostname)
echo "Removing from /etc/hostname: $resp"
echo "Adding to /etc/hostname:     $1"
echo $1 | sudo tee /etc/hostname > /dev/null

# Check and modify vim settings if required
vimPath=/home/pi/.vimrc
vimCmds=(
  "set nocp"
  "set backspace=2"
)
# Check the file exists and if not the create it
if [ ! -e $vimPath ]; then
    touch $vimPath
fi
# Add the commands if they are not already there
for cmd in "${vimCmds[@]}"; do
    grep -q "$cmd" $vimPath
    if [ $? -eq 1 ]; then
        echo "Adding '$cmd' to $vimPath"
        echo $cmd >> $vimPath
    fi
done

# Update the distro, remove some junk and install some dependencies
apt-get remove --purge libreoffice-*
apt-get remove --purge wolfram-engine
apt-get remove --purge plymouth
apt-get remove --purge nodered
apt-get remove --purge sonic-pi
apt-get clean

apt-get update
apt-get -y dist-upgrade
apt-get -y install screen avahi-daemon netatalk redis-server minicom
apt-get -y install mailutils
apt-get -y install postfix

# Modify the postfix config file if necessary
if ! grep -q "inet_protocols = ipv4" /etc/postfix/main.cf; then
    echo "Adding line to end of /etc/postfix/main.cf to force ipv4 only"
    echo inet_protocols = ipv4 | sudo tee -a /etc/postfix/main.cf
fi

# Update rc.local to send an email with ip addr on reboot and
# restart the postfix service after raspian has had a chance to setup the resolv.conf (DNS).
# Postfix copies this file and if it start too soon after boot it copies an empty file.
# Restarting later resolves this…
cat rc.local.backup | sudo tee /etc/rc.local > /dev/null

# Configure Python
sudo apt-get -y install python3-pip
sudo pip3 install redis
sudo pip3 install pyserial
