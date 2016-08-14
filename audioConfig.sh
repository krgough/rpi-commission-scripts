#!/bin/bash

# Clone the audio repos
# Array of repo base names
repoBase="https://github.com/ConnectedHomes/"
repoEnd=".git"
repoNames=(
  "audio-notifications"
  "audio-event-monitor"
)

localRepoDir='/home/pi/repositories/audioRespository/'

# Create github repos
echo "*** Cloning audio repos from Github..."
echo
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

# Do other audio config here
# Create audio-user account
# Tunnel config & enable
# ipMailer config & enable
# test email
# audio-notification config
# audio-event-monitor make

logDir='$localRepoDir/audio-event-monitor/logs'
if [ -d "$logDir" ]; then
    echo $logDir - Directory already exists, skipping...
else
    mkdir $logDir

# mkdir $localRepoDir/audio-event-monitor/logs

# Install the cron jobs as listed in the crontab backup file.
Echo "Installing cron jobs..."
crontab audioCrontabBackup.txt
