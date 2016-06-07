#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:

# Script to determine online state and if online then turn on the LED (set GPIO high)

# First turn set the mode of the io pin to output
/usr/bin/gpio -g mode 18 out

# Now try to ping a server
/bin/ping -c1 google.com
if [ $? -eq 0 ]; then
  # Not connected so turn LED off
  echo rPi is online
  /usr/bin/gpio -g write 18 1
else
  echo rPi is offline
  /usr/bin/gpio -g write 18 0
fi
