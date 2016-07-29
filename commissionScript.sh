#!/bin/bash
set -e             # Exit at once if we get any errors

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

# Update the distro and install some dependencies
apt-get update
apt-get -y upgrade
apt-get -y dist-upgrade
apt-get install screen avahi-daemon netatalk redis-server minicom
apt-get install sendmail

# Configure Python
sudo apt-get install python3-pip
sudo pip3 install redis
sudo pip3 install pyserial
