#! /usr/bin/env bash

# Setup systemd service to run the led indicator service
echo "Setting up led_wifi_indicator.service in systemd..."
sudo cp ./led_wifi_indicator.service /etc/systemd/system/
sudo systemctl enable led_wifi_indicator.service
sudo systemctl start led_wifi_indicator.service
sudo systemctl status led_wifi_indicator.service
