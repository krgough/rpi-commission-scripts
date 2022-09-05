#!/bin/bash

if [ "$(id -u)" -ne "0" ]; then
    echo "This script must be executed with root privileges"
    exit 1
fi

usage() {
  echo ""
  echo "Usage: sudo $0 newHostname email_username email_password aws_port"
  echo ""
  echo "newHostname           Hostname you want to give the new rPI"
  echo "emailUsername         USername for gmail.  Used for sending emails"
  echo "emailPassword         Password for gmail.  Used for sending emails."
  echo "aws_port              Optional: Port number on remote server if using reverse tunnel"
  echo ""
}

# Check we were given a hostname and email as parameters
if [ -z $1 ] || [ -z $2 ] || [ -z $3 ]; then
  usage
  exit 1
fi

# Save the parameters to variables
HN=$1
EMAIL_USER=$2
EMAIL_PASS=$3
if [ $4 ]; then AWS_PORT=$4; fi

# Change to the wanted working directory
cd /home/pi/repositories/rpi-commission-scripts

# Modify the /etc/hosts file
# sendmail needs the <hostname.local> entry
#hosts="$HN $HN.local"
resp=$(grep "127.0.1.1" /etc/hosts)
echo "Removing from /etc/hosts:    $resp"
sudo sed -i '/127.0.1.1/d' /etc/hosts
echo "Adding to /etc/hosts:        127.0.1.1    $HN"
echo "127.0.1.1 $HN" | sudo tee -a /etc/hosts > /dev/null

# Modify the /etc/hostname file
resp=$(cat /etc/hostname)
echo "Removing from /etc/hostname: $resp"
echo "Adding to /etc/hostname:     $HN"
echo $HN | sudo tee /etc/hostname > /dev/null

# If user supplied a port number for the tunnel then 
# we setup the tunnel configuration
if [ $AWS_PORT ]; then
  # Create the tunnel.conf file
  echo "Creating tunnel configuration..."
  echo "port="$AWS_PORT"" > /home/pi/repositories/rpi-commission-scripts/tunnel.conf
  echo "server_alias="sniffer_aws"" >> /home/pi/repositories/rpi-commission-scripts/tunnel.conf

  # Create a basic crontab with the tunnel task
  echo "Adding tunnel setup to crontab..."
  crontab -u pi /home/pi/repositories/rpi-commission-scripts/crontabBackup.txt
fi

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
apt-get -y -qq full-upgrade
apt-get -y -qq install screen avahi-daemon netatalk minicom i2c-tools msmtp msmtp-mta mailutils rsync

# ssmtp is deprecated use msmtp instead (see below)
# Modify the ssmtp config file
# SSMTP_CFG="/etc/ssmtp/ssmtp.conf"
# EMAIL="kgpython@gmail.com"
# sed -i "s/root=postmaster/root=$EMAIL/" $SSMTP_CFG
# sed -i "s/mailhub=mail/mailhub=smtp.gmail.com:587/" $SSMTP_CFG
# sed -i "s/#FromLineOverride=YES/FromLineOverride=YES/" $SSMTP_CFG
# echo -e "\nAuthUser=$EMAIL\nAuthPass=$EMAIL_PASS\nUseSTARTTLS=YES\nUseTLS=YES" >> $SSMTP_CFG

# Setup msmtp
echo "Setting up /etc/msmtprc for email..."
cp msmtprc.template /etc/msmtprc
sed -i "s/<INSERT GMAIL EMAIL HERE>/$EMAIL_USER/" /etc/msmtprc
sed -i "s/<INSERT PASSWORD HERE>/$EMAIL_PASS/" /etc/msmtprc

# Update rc.local to send an email with ip addr on reboot
echo "Updating rc.local to send ip addr email on boot..."
cat rc.local.backup | sudo tee /etc/rc.local > /dev/null

# Configure Python
echo "Installing python libs..."
pip3 install -q requests pyserial smbus2

echo ""
echo "Reboot the hub first and then sort out the ssh keys"
echo "Run ssh-keygen to create ssh keys"
echo "Copy the public key to the aws server authorized_users file for user sniffer-user"
