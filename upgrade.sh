#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:

username="$(cat /home/pi/repositories/rpi-commission-scripts/userEmail.txt)"
ip="$(hostname -I | awk -F " " '{print$1}')"
hostname="$(hostname)"

echo "$hostname $ip : upgrade started" | mail -aFrom:$hostname -s "$ip" $username

sudo apt-get -y update
sudo apt-get -y dist-upgrade

echo "$hostname $ip : upgrade done" | mail -aFrom:$hostname -s "$ip" $username

