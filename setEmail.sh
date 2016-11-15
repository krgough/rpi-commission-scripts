#!/bin/bash

# setEmail.sh
# usage ./setEmail.sh <users email address>
# Script to insert the users email into the audio email config file
# expects this file to be present...
# /home/pi/repositories/audioRepository/audio-notifications/userEmail.txt

emailFile="/home/pi/repositories/audioRepository/audio-notifications/userEmail.txt"

# Check we have been given an email and that it has at '@' symbol
if [ "$1" == "" ]; then
    echo "usage ./setEmail.sh <users email address>"
    exit 1
fi

# This '<<<' redirects from a string to the grep command
grep -q "@" <<< $1
if [ $? -ne 0 ]; then
    # This is not a valid email address
    echo "This is not a valid email address.  No '@' found."
    exit 1
fi

# Check the userEmail.txt file exists
if [ ! -f "$emailFile" ]; then
    echo "The email file does not exist.  Check the audio libraries have been installed."
    echo "$emailFile"
    exit 1
fi

# All ok so insert the email address into the file (overwrites any previous entry)
echo
echo "userEmail.txt contains the following..."
cat $emailFile
echo
read -p "Do you want to overwrite with '$1'? (y/n) :" input
if [ $input == 'y' ]; then
    echo $1 > $emailFile
    echo "File updated."
else
    echo "No changes made."
fi
