#! /usr/bin/env bash

ssh_cfg_path="/etc/ssh/sshd_config"
echo "Setting 'Password Authentication no' in $ssh_cfg_path"
echo "PasswordAuthentication no" | sudo tee -a $ssh_cfg_path > /dev/null
