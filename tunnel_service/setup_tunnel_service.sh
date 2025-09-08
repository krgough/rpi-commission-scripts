#! /usr/bin/env bash

# Ensure we are running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run with sudo"
    exit 1
fi

# Check we have 3 arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <BASTION_PORT> <BASTION_USER> <BASTION_URL> <BASTION_USER>"
    exit 1
fi

set -e

BASTION_PORT=$1
BASTION_USER=$2
BASTION_URL=$3
RPI_USER=$(logname)

SERVICE_FILE="/etc/systemd/system/tunnel.service"

cp files/tunnel.service.template $SERVICE_FILE

sed -i "s/BASTION_PORT/$BASTION_PORT/g" $SERVICE_FILE
sed -i "s/BASTION_USER/$BASTION_USER/g" $SERVICE_FILE
sed -i "s/BASTION_URL/$BASTION_URL/g" $SERVICE_FILE
sed -i "s/RPI_USER/$RPI_USER/g" $SERVICE_FILE

# Enable the service to start on boot and start it now
systemctl enable tunnel.service
systemctl start tunnel.service
