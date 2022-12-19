#! /usr/bin/env bash

# Setup the cpu temperature check service and timer
echo "Setting up cpu temperature check service..."
sudo cp cpu_temp_check.service /etc/systemd/system/
sudo cp cpu_temp_check.timer /etc/systemd/system/
sudo systemctl enable cpu_temp_check.service
sudo systemctl start cpu_temp_check.service
sudo systemctl status cpu_temp_check.service
