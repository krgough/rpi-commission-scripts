#!/bin/bash

systemctl stop kg-wifi-rssi.timer
systemctl disable kg-wifi-rssi.timer

rm /etc/systemd/system/kg-wifi-rssi.timer
rm /etc/systemd/system/kg-wifi-rssi.service
