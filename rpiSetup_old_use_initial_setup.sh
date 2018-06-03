#!/bin/bash

# This is for personalising an rpi after dd'ing a new raw image onto the card
# We should make sure the raw image has a the default password changed and
# SSH enabled

# 1) Hostname - set the given hostname
#
# 2) SSH - login keys and AWS keys.  Copy the following to the .ssh directory on the rpi
#    id_rsa = Common ssh private key for access to AWS server
#    config = ssh config file, with details of aws server
#    authorized-keys = contains KG public key to allow direct login
# 
# 3) Copy & Run rpi-commission-script.sh to update os and install extra tools.
#
# 4) Create a tunnel.conf file for reverse tunnel script
#
# 5) Update the crontab include the tunnel service (to aws server)
#
# 6) Reboot.

set -e

WGET_IP=$1
HOSTNAME=$2
TUNNEL_PORT=$3
SCRIPT_PATH="/home/pi/respositories/rpi-commission-scripts"

if [ -z $1 ] || [ -z $2 ] || [ -z $3 ]; then
    echo "usage initial-setup.sh wget_ipaddr:port hostname aws_port"
    exit 1
fi

function setHostname{
  # Modify the /etc/hosts file
  # sendmail needs the <hostname.local> entry
  hosts="$HOSTNAME $HOSTNAME.local"
  resp=$(grep "127.0.1.1" /etc/hosts)
  echo "Removing from /etc/hosts:    $resp"
  sudo sed -i '/127.0.1.1/d' /etc/hosts
  echo "Adding to /etc/hosts:        127.0.1.1    $hosts"
  echo "127.0.1.1 $hosts" | sudo tee -a /etc/hosts > /dev/null

  # Modify the /etc/hostname file
  resp=$(cat /etc/hostname)
  echo "Removing from /etc/hostname: $resp"
  echo "Adding to /etc/hostname:     $HOSTNAME"
  echo $HOSTNAME | sudo tee /etc/hostname > /dev/null
}

function copySshConfig{
  # Create .ssh
  # Wget the config files to the directory
  DIR="/home/pi/.ssh"
  if [ ! -d "$DIR" ]; then
      echo "Creating .ssh directory..."
      mkdir "$DIR"
  fi
  cd "$DIR"
  wget -qr -t3 -nd --preserve-permissions --reject="index.html*" http://$WGET_IP/ssh-config/
}

function copyRpiCommission{
  # Create the folder if required
  DIR="/home/pi/repositories"
  DIR="/Users/Keith.Gough/OneDrive - Hive Single Sign-on/repositories/rpi-commission-scripts/junk/rpi-commission-scripts"
  if [ ! -d "$DIR" ]; then
    mkdir -p "$DIR"
  fi
  cd "$DIR"
  wget -q -r -l1 -t3 -nd --preserve-permissions --reject="index.html*,ssh-config" http://$WGET_IP/

  # Create a tunnel conf
  echo "port=$TUNNEL_PORT" > tunnel.conf
  echo "server_alias=audio_aws" >> tunnel.conf

  # Add the tunnel setup job to crontab
  cat $SCRIPT_PATH/stdCronBackup.txt | crontab -  

}

# **** Main code starts here

setHostName
copySshConfig

# Setup the tunnel
# Install the tunnel config

copyRpiCommission
# Run rpi-commission
# Create a tunnel.config
# Edit crontab to include the tunnel startup
# Run the rpi-commission script

exit 0

SCRIPT_PATH = "/home/pi/respositories/rpi-commission-scripts"

if [ -z $1 ] || [ -z $2 ] || [ -z $3 ]; then
    echo "usage initial-setup.sh wget_ipaddr:port hostname aws_port"
    exit 1
fi

# Copy the SSH config files
echo "Copying SSH configuration files (stuff we don't want to share in github)..."
ssh pi@$1 mkdir "/home/pi/.ssh"
scp ./ssh-config/config ./ssh-config/id_rsa ./ssh-config/authorized_keys pi@$1:/home/pi/.ssh/

# Run the rpi-commission-script to update the os,python and install any apps

# Setup tunnel.conf for reverse tunnel to aws server
echo "port=\"$PORT\"" > /tmp/tunnel.conf
echo "server_alias=\"audio_aws\" >> /tmp/tunnel.conf
ssh pi@$1

# Setup cron job (this is already in place in the backup image)
# Note: crontab - means take input from stdin
ssh pi@$1 cat $SCRIPT_PATH/stdCronBackup.txt | crontab -

echo
echo "*************************"
echo 
echo "All done.  ssh onto the device using...
echo "ssh pi@$1"
echo "ssh pi@$HN.local"
