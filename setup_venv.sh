#! /usr/bin/env bash

# Required to install rpi-lgpio later
echo "Installing dependencies..."
sudo apt-get -y -qq install swig python3-dev liblgpio-dev

echo "Setting up python venv..."
python3 -m venv venv
source venv/bin/activate

echo "Installing python requirements..."
pip3 install -r requirements.txt
deactivate

echo "All done"

