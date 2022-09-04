#!/bin/bash

# KG 31/05/18: Start tshark and log to ring buffer files
# In this case we specify max file size, nmber of ring buffer files and a root filename

MAX_FILESIZE=100000 # kBytes
NUM_OF_FILES=5
LOG_PATH="/home/pi/repositories/wireshark-logging/logs"
LOG_FILENAME="wireshark-log"
HUB_MAC="90:70:65:FB:9F:10"

# Check if tshark is running. If not then start it.
if ! [ $(pidof tshark) ] ; then
  echo "tshark pid not found.  Staring new wireshark packet trace.."
  # When we restart the new process 'forgets' about the old log files so we get left over log
  # files that are not being rotated anymore.  We'll do a delete of any files older than 7 days here
  # to get rid of those.
  find $LOG_PATH -name "$LOG_FILENAME*" -mtime +7 -exec rm {} \;

  # Now restart tshark

  # Log with no filtering.
  tshark -q -b filesize:$MAX_FILESIZE -b files:$NUM_OF_FILES -w $LOG_PATH/$LOG_FILENAME &

  # Log with filtering on MAC addresses
  # tshark -f "ether host $HUB_MAC" -q -b filesize:$MAX_FILESIZE -b files:$NUM_OF_FILES -w $LOG_PATH/$LOG_FILENAME &

else
  echo "tshark is already running"
fi
