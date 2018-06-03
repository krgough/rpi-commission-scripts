#!/bin/bash

# Change to the wanted working directory
cd /home/pi/repositories/rpi-commission-scripts

# Setup the correct hostname 
if [ -z $1 ] || [ -z $2 ] || [ -z $3 ]; then
  echo "usage: $0 newHostname aws_port kgpython_password"
  exit 1
fi

HN=$1
AWS_PORT=$2
EMAIL_PASS=$3

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
apt-get -y -qq install i2c-tools
# apt-get -y -qq install python3-smbus (depricated in favour of pip3 install smbus2)

# Install the email server
apt-get -y -qq install ssmtp mailutils

# Modify the ssmtp config file
SSMTP_CFG="/etc/ssmtp/ssmtp.conf"
EMAIL="kgpython@gmail.com"
sed -i "s/root=postmaster/root=$EMAIL/" $SSMTP_CFG
sed -i "s/mailhub=mail/mailhub=smtp.gmail.com:587/" $SSMTP_CFG
sed -i "s/#FromLineOverride=YES/FromLineOverride=YES/" $SSMTP_CFG
echo -e "/nAuthUser=$EMAIL/nAuthPass=$EMAIL_PASS/nUseSTARTTLS=YES/nUseTLS=YES" >> $SSMTP_CFG

# Update rc.local to send an email with ip addr on reboot
echo "Updating rc.local to send ip addr email on boot..."
cat rc.local.backup | sudo tee /etc/rc.local > /dev/null

# Configure Python
echo "Installing python libs..."
sudo apt-get -y -qq install python3-pip
sudo pip3 install -q redis requests pyserial smbus2
