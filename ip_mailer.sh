#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:

username="$(cat /home/pi/repositories/audioRepository/audio-notifications/userEmail.txt)"
ip="$(hostname -I | awk -F " " '{print$1}')"
hostname="$(hostname)"

python3 /home/pi/repositories/audioRepository/audio-notifications/audioSendmail.py -r $username -s "$hostname, $ip" -m "rpi ip address mailer - brought to you by Keith"
