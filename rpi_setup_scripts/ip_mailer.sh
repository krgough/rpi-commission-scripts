#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:

username="$(cat /home/pi/repositories/rpi-commission-scripts/rpi_setup_scripts/userEmail.txt)"
ip="$(hostname -I | awk -F " " '{print$1}')"
hostname="$(hostname)"

echo "$hostname $ip : rpi ip address mailer - brought to you by Keith" | mail -s "$hostname $ip" $username
