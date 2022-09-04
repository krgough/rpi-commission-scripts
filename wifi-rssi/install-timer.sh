#!/bin/bash


cp kg-wifi-rssi.timer /etc/systemd/system
cp kg-wifi-rssi.service /etc/systemd/system

systemctl start kg-wifi-rssi.timer
systemctl enable kg-wifi-rssi.timer
