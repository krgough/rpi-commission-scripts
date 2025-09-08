#! /usr/bin/env bash

set -e

# Setup the cpu temperature check service and timer
echo "Setting up cpu temperature check service..."
sudo cp ./files/cpu_temp_check.service /etc/systemd/system/
sudo cp ./files/cpu_temp_check.timer /etc/systemd/system/

sudo systemctl enable cpu_temp_check.timer
sudo systemctl start cpu_temp_check.timer
sudo systemctl status cpu_temp_check.timer

sudo systemctl enable cpu_temp_check.service
sudo systemctl start cpu_temp_check.service
sudo systemctl status cpu_temp_check.service
