#!/bin/bash

# KG: 08/06/2018
# Script to log wifi rssi for debug

RSSI_LR_CONF="/home/root/rssi-logrotate.conf"
RSSI_LR_STATUS="/home/root/rssi-logrotate.status"
RSSI_LOG="/home/root/rssi.log"

# Rotate the logs to prevent disk filling up
logrotate -s $RSSI_LR_STATUS $RSSI_LR_CONF

# Get timestamp and wifi rssi and save to log
myDate=$(date +"%Y-%m-%d %H:%M:%S")
rssi=$(iw wlan0 link | awk -F ":" '/signal/{print $2}')

# Create serialised data from multi-line output from 'iw wlan0 link'
# 'tr' joins the lines by replacing '\n' with ','
# sed command searches for comma followed by spaces and replaces that with comma only
all_data=$(iw wlan0 link | tr '\n' ',' | sed 's/,\s*/,''/g')

# Print result to a logfile
echo "$myDate,$rssi,$all_data" >> $RSSI_LOG
