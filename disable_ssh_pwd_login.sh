#! /usr/bin/env bash

if [ "$(id -u)" -ne "0" ]; then
    echo "This script must be executed with root privileges"
    exit 1
fi

ssh_cfg_path="/etc/ssh/sshd_config"
echo "Setting 'Password Authentication no' in $ssh_cfg_path"
echo "PasswordAuthentication no" | sudo tee -a $ssh_cfg_path > /dev/null

systemctl restart ssh
