#! /usr/bin/env bash

set -e

echo "Upgrading system packages..."
echo
echo "apt update..."
sudo apt update

echo
echo "apt full-upgrade..."
sudo apt -y full-upgrade

echo
echo "apt auto-remove..."
sudo apt -y auto-remove

