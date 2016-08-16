#!/bin/bash

# Clone the audio repos
# Array of repo base names
repoBase="https://github.com/ConnectedHomes/"
repoEnd=".git"
repoNames=(
  "audio-notifications"
  "audio-event-monitor"
  "corelogger_sdk"
)

localRepoDir='/home/pi/repositories/audioRepository/'

# Create github repos
echo "*** Cloning audio repos from Github..."
for rName in ${repoNames[@]}; do
    repoName=$repoBase$rName$repoEnd
    localName=$localRepoDir$rName  

    if [ -d "$localName" ]; then
        echo $localName - Directory already exists, skipping...
    else
        cmd="git clone $repoName $localName"
        echo $cmd
        resp=$($cmd)
    fi 
done # end of for loop

# Create audio-user account
echo
echo "*** Creating audio-user account..."
if [ -d "/home/audio-user" ]; then
    echo audio-user already exists, skipping ...
else
    sudo adduser audio-user
fi

# Give all users access to /etc/wpa_supplicant/wpa_supplicant.conf
echo
echo "*** Giving all users access to wpa_supplicant.conf"
sudo chmod o+w /etc/wpa_supplicant/wpa_supplicant.conf

# Tunnel config
echo
echo "*** Creating the tunnel config file..."
tcf='/home/pi/repositories/rpi-commission-scripts/tunnel.conf'
if [ -f "$tcf" ]; then
    echo Tunnel config already exists, skipping...
else
    port=22$(hostname | grep -o '[0-9][0-9]')
    echo port=\"$port\" > $tcf
    echo server_alias=\"audio_aws\" >> $tcf
fi

# ipMailer - edit rc.local to run the script at startup
echo
echo "*** Configuring ipMailer..."
sudo cp rc.local.backup /etc/rc.local

# audio-notification config
echo
echo "*** Setting keith.gough@bgch.co.uk as default email address for notifications, edit this for each user."
emailFile="$localRepoDir"audio-notifications/userEmail.txt
if [ -f "$emailFile" ]; then
    echo "userEmail.txt already exists (in audio-notifications), skipping..."
else
    echo keith.gough@bgch.co.uk > "$emailFile"
fi

# audio-event-monitor make
echo
echo "*** Make audio-event-monitor..."
make -C /home/pi/junk/repositories/audioRespository/audio-event-monitor/

# Create the log folder for audio-event-monitor
echo
echo "*** Creating log directory..."
logDir="$localRepoDir"audio-event-monitor/logs
if [ -d "$logDir" ]; then
    echo $logDir - Directory already exists, skipping...
else
    echo Creating log directory $logDir...
    mkdir "$logDir"
fi

# Install the cron jobs as listed in the crontab backup file.
echo
echo "*** Installing cron jobs..."
crontab audioCrontabBackup.txt

# audio-notification-config
echo
echo "*** REMEMBER: insert the users email address into the userEmail.txt file"
echo vi $localRepoDir/audio-notifications/userEmail.txt
