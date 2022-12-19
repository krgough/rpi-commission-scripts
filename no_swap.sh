#! /usr/bin/env bash

sudo dphys-swapfile swapoff
sudo dphys-swapfile uninstall
# sudo update-rc.d dphys-swapfile remove
sudo systemctl disable dphys-swapfile.service
