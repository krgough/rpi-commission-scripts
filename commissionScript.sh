#!/bin/bash

# Change to the wanted working directory
cd /home/pi/repositories/rpi-commission-scripts

# Setup the correct hostname 
if [ -z $1 ] || [ -z $2 ]; then
  echo "usage: $0 newHostname aws_port"
  exit 1
fi

HN=$1
AWS_PORT=$2

# Modify the /etc/hosts file
# sendmail needs the <hostname.local> entry
hosts="$HN $HN.local"
resp=$(grep "127.0.1.1" /etc/hosts)
echo "Removing from /etc/hosts:    $resp"
sudo sed -i '/127.0.1.1/d' /etc/hosts
echo "Adding to /etc/hosts:        127.0.1.1    $hosts"
echo "127.0.1.1 $hosts" | sudo tee -a /etc/hosts > /dev/null

# Modify the /etc/hostname file
resp=$(cat /etc/hostname)
echo "Removing from /etc/hostname: $resp"
echo "Adding to /etc/hostname:     $HN"
echo $HN | sudo tee /etc/hostname > /dev/null

# Create the tunnel.conf file
echo "Creating tunnel configuration..."
echo "port="$AWS_PORT"" > /home/pi/repositories/rpi-commission-scripts/tunnel.conf
echo "server_alias="audio_aws"" >> /home/pi/repositories/rpi-commission-scripts/tunnel.conf

# Create a basic crontab with the tunnel task
echo "Adding tunnel setup to crontab..."
crontab -u pi /home/pi/repositories/rpi-commission-scripts/crontabBackup.txt

# Check and modify vim settings if required
echo "Modifying vi config..."
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
echo "Updating package files..."
apt-get -qq remove --purge libreoffice-* wolfram-engine plymouth nodered sonic-pi
apt-get -qq clean

apt-get update
apt-get -y -qq dist-upgrade
apt-get -y -qq install screen avahi-daemon netatalk redis-server minicom
apt-get -y -qq install mailutils postfix
apt-get -y -qq install i2c-tools python3-smbus

# Modify the postfix config file if necessary
if ! grep -q "inet_protocols = ipv4" /etc/postfix/main.cf; then
    echo "Adding line to end of /etc/postfix/main.cf to force ipv4 only"
    echo inet_protocols = ipv4 | sudo tee -a /etc/postfix/main.cf
fi

# Update rc.local to send an email with ip addr on reboot and
# restart the postfix service after raspian has had a chance to setup the resolv.conf (DNS).
# Postfix copies this file and if it start too soon after boot it copies an empty file.
# Restarting later resolves this…
echo "Updating rc.local to send ip addr email on boot..."
cat rc.local.backup | sudo tee /etc/rc.local > /dev/null

# Configure Python
echo "Installing python libs..."
sudo apt-get -y -qq install python3-pip
sudo pip3 install -q redis requests pyserial
