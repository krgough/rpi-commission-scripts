#!/bin/bash

# Setup to configure the rPI
# Create tars of ssh-config and rpi-commission-scripts (remove old tars first if they exist)
# 
# Start the web server to allow rPI to wget 
# Delete old tars
# Kill off the web server

RPI_IP=$1    # rPI IP address
HN=$2        # New hostname for rPI
AWS_PORT=$3  # Port number for AWS tunnel

WGET_IP="$(ifconfig en0 | grep 'inet ' | awk '{print $2}')"
WGET_PORT="3000"
RCS="/home/pi/repositories/rpi-commission-scripts"

if [ -z $1 ] || [ -z $2 ] || [ -z $3 ]; then
    echo "usage initial-setup.sh <rPi_ip_addr> <hostname> <aws_port>"
    exit 1
fi

function deleteTarballs {
  # Delete any old tarballs
  if [ -e "rpi-commission-scripts.tar" ]; then
    rm rpi-commission-scripts.tar
  fi
}

# Main script starts

# Create the new tarballs, delete old ones first if necessary
deleteTarballs
tar -zcf rpi-commission-scripts.tar *

# Start the webserver (for wget)
#echo python3 -m http.server $WGET_PORT --bind $WGET_IP
python3 -m http.server $WGET_PORT --bind $WGET_IP > /dev/null 2>&1 &

# SSH to the pi.
# Make the rpi-commission-scripts directory.
# Make the .ssh folder and copy ssh-config contenmts there. Public keys and aws login key.
# Run the rpiSetup script

ssh pi@$RPI_IP /bin/bash << myCommands
  mkdir -p $RCS;
  wget -q http://$WGET_IP:$WGET_PORT/rpi-commission-scripts.tar -O $RCS/rpi-commission-scripts.tar
  tar -xf $RCS/rpi-commission-scripts.tar -C $RCS
  rm $RCS/rpi-commission-scripts.tar
  
  # SSH config is in the tarball so we can create a .ssh and copy the files there.
  mkdir -p /home/pi/.ssh
  cp $RCS/ssh-config/* /home/pi/.ssh

  # Run the rpi-commission.sh script
  sudo $RCS/commissionScript.sh $HN $AWS_PORT 

myCommands

# Kill the web server and delete the old tarballs
pkill -f "Python -m http.server"
wait $! 2>/dev/null
deleteTarballs
echo "All done."
