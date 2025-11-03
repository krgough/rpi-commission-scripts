#! /usr/bin/env bash

# Put email username in the .env file

SCRIPT_DIR=$(dirname -- "${BASH_SOURCE[0]}")
source "$SCRIPT_DIR/../.env"

ip="$(hostname -I | awk -F " " '{print$1}')"
hostname="$(hostname)"

echo "$hostname $ip : rpi ip address mailer - brought to you by Keith" | mail -s "$hostname $ip" $USER_EMAIL
