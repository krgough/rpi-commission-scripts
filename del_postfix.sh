#!/bin/bash

# Remove postfix
# Install ssmtp and mailutils
# Edit the ssmtp config
# Delete the old ip_mailer scripts
# Delete the postfix lines from rc.local

EMAIL="kgpython@gmail.com"

set -e

# Remove postfix
sudo apt-get -y remove --purge postfix

# Install ssmtp
sudo apt-get -y install ssmtp mailutils
sudo apt-get -y autoremove

# Modify the ssmtp config file
SSMTP_CFG="/etc/ssmtp/ssmtp.conf"
EMAIL="kgpython@gmail.com"
sudo sed -i "s/root=postmaster/root=$EMAIL/" $SSMTP_CFG
sudo sed -i "s/mailhub=mail/mailhub=smtp.gmail.com:587/" $SSMTP_CFG
sudo sed -i "s/#FromLineOverride=YES/FromLineOverride=YES/" $SSMTP_CFG
echo -e "\nAuthUser=$EMAIL\nAuthPass=bluerhonda\nUseSTARTTLS=YES\nUseTLS=YES" | sudo tee -a $SSMTP_CFG

# Delete the old ip_mailer scripts.
rm /home/pi/repositories/rpi-commission-scripts/ip_mailer2.sh
mv /home/pi/repositories/rpi-commission-scripts/ip_mailer_postfix.sh /home/pi/repositories/rpi-commission-scripts/ip_mailer.sh

# Delete the postfix lines out of rc.local
sudo sed -i "/# KG: restart postfix to copy the resolv.conf file after DNS has been setup/,+2d" /etc/rc.local
sudo sed -i "s/ip_mailer_postfix.sh/ip_mailer.sh/" /etc/rc.local

