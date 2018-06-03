#!/bin/bash

# KG: 27/04/2018
#
# Ping hub IP addresses listed in a given file.
# If state changes from online>offline or offline>online then email user
#

if [ -x $1 ]; then
  echo
  echo "Usage: $0 hub_file"
  echo
  echo "Emails user if hub online state changes."
  echo "Hub IP address should be listed in the file. Multiple hubs can be listed in the file."
  echo "If no ping response the we assume offline else online"
  echo 
  exit 1
fi

hubFile=$1

while read -r line; do 
  echo $line; 
  /home/pi/repositories/rpi-commission-scripts/pingDevice.sh $line
done < $hubFile
