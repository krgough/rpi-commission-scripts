#! /usr/bin/env bash

usage () {
  echo "Usage: $0 [TEMP]"
  echo "Show CPU temperature and send alert email if temp is greater than TEMP"
  echo ""
  echo "Arguments:"
  echo "  TEMP     Alert temperature (optional). Default is 50'C"
  echo ""
  exit 1
}

if [ -x $1 ]; then
  TEMP_HIGH=50
else
  if [ $1 = "-h" ]; then
    usage
  fi
  TEMP_HIGH=$1
fi

HOSTNAME=$(hostname)
EMAIL="/tmp/email_sent"

if [ ! -f "$EMAIL" ]; then
  echo "No email_sent so creating it"
  touch -d "2 hours ago" $EMAIL
fi

username="$(cat /home/pi/repositories/rpi-commission-scripts/userEmail.txt)"
cpu=$(vcgencmd measure_temp | awk -F "=" '{print $2}' | awk -F "'" '{print $1}')
echo "CPU temperature: $cpu'C"

# If CPU temperature is high and we have not sent an email in the last hour
# then send an ALERT email to the users.

if awk "BEGIN {exit !($cpu > $TEMP_HIGH)}"; then
  echo "WARNING: $HOSTNAME CPU temperature Greater than $TEMP_HIGH'C"

  recent_email=$(( (`date +%s` - `stat -L --format %Y $EMAIL`) > 60 ))
  if [ $recent_email -eq 0 ]
  then
    echo "Email sent recently. Not sending email this time."
  else
    echo "Sendng ALERT email"
    msg="ALERT: $HOSTNAME CPU TEMPERATURE IS $cpu'C"
    echo "$msg" | mail -s "$msg" $username
    touch $EMAIL
  fi

fi

