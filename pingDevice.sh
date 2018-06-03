#!/bin/bash

# KG: 25/04/2018
# Script to try to ascertain if hub is online/offline.
# This is expected to be run on a device on the same network e.g. an rPi

# Ping a given device
# if online:
#   if lastState is offline send online email and set state online
# else (offline):
#   if lastState is online send offline email and set state=offline
#

if [ -x $1 ]; then
  echo
  echo "Usage: $0 ip_address"
  echo "Returns 0 if ping to address is ok else 0"
  echo
  exit 1
fi

ipAddr=$1
flagFile=/tmp/$ipAddr-ONLINE
hostname="$(hostname)"
username="$(cat /home/pi/repositories/rpi-commission-scripts/userEmail.txt)"

if [ -e $flagFile ]; then
  lastState="ONLINE"
else
  lastState="OFFLINE"
fi
 
echo "laststate = $lastState"

ping -c1 $ipAddr > /dev/null 2>&1

if [ $? -eq 0 ] ; then
  # Online
  echo "hub online"
  if [ $lastState == "OFFLINE" ]; then
    echo "OFFLINE to ONLINE"
    touch $flagFile
    echo "Hi Keith: $ipAddr is online" | mail -aFrom:$hostname -s "Hub is online" $username
  fi
else
  echo "hub offline"
  # Offline
  if [ $lastState == "ONLINE" ]; then
    echo "ONLINE to OFFLINE"
    rm $flagFile
    echo "Hi Keith: $ipAddr is offline" | mail -aFrom:$hostname -s "Hub is offline" $username
  fi
fi
