#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:

# Wait for Network to be available.
c=0
while true
do
  ping -c 1 XXX.XXX.XXX.XXX
  if [[ $? == 0 ]]; then
    echo ‘Network available.’
    break;
  else
    ((c++))
    if [ "$c" -gt 2 ]; then
      exit 1
    fi
    echo ‘Network is not available, waiting..’
    sleep 5
  fi
done

username="$(cat /home/pi/repositories/audioRepository/audio-notifications/userEmail.txt)"
ip="$(hostname -I | awk -F " " '{print$01}')"
hostname="$(hostname)"

python3 /home/pi/repositories/audioRepository/audio-notifications/audioSendmail.py -r $username -s "$hostname, $ip" -m "rpi ip address mailer - brought to you by Keith"
