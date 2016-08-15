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

localRepoDir='/home/pi/junk/repositories/audioRespository/'

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

# Tunnel config & enable
# ipMailer config & enable
# test email
# audio-notification config

# audio-event-monitor make
echo
echo "*** Make audio-event-monitor..."
make -C /home/pi/junk/repositories/audioRespository/audio-event-monitor/

# Create the log folder for audio-event-monitor
echo
echo "*** Creating log directory..."
logDir=$localRepoDir/audio-event-monitor/logs
if [ -d "$logDir" ]; then
    echo $logDir - Directory already exists, skipping...
else
    echo Creating log directory $logDir...
    mkdir $logDir
fi

# Install the cron jobs as listed in the crontab backup file.
echo
echo "*** Installing cron jobs..."
crontab audioCrontabBackup.txt
