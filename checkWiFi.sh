#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:

#####################################################################
# Keith Gough
#
# Purpose:
#
# Network connection via wifi dongle is being lost occasionaly.
# If order to try and recover we will attempt to detect this
# by pinging the router.  If this fails we shall reset the interface
# by bringing it down then up.
#
# We shall also implement so minimal logging with rotation to prevent
# disk from being filled up.
#
# The script will be run be CRON every 5mins. Add this to the crontab
# */5 * * * * /home/repositories/rpi-commission-scripts/checkWiFi.sh
#

# Logfile path and max file size (in lines) defined here
LOGFILE=/tmp/checkWiFi.sh.log
RETAIN_NUM_LINES=10
WLAN="wlan0"
PING_IP=192.168.1.254

# Grab last few lines from the logfile and then redirect any output
# from this script to the logfile.
function logsetup {
  TMP=$(tail -n $RETAIN_NUM_LINES $LOGFILE 2>/dev/null) && echo "${TMP}" > LOGFILE
  exec > >(tee -a $LOGFILE)
  exec 2>&1
}

function log {
  echo "[$(date)]: $*"
}

# Ping the router
log "Performing network check for $WLAN"
/bin/ping -c2 -I $WLAN $PING_IP > /dev/null 2> /dev/null
if [ $? -ne 0 ] ; then
  log "Network connection is down.  Attempting reconnection."
  /sbin/ifdown $WLAN
  sleep 5
  /sbin/ifup $WLAN
else
  log "Network is OK."
fi
