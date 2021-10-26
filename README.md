# Bash scripts to help commissioning of RaspberryPis

Use 'initial-setup.sh' to copy these files to a new rPi.  
These scripts are installed in the following directory on the rPi:  
/home/pi/repositories/rpi-commission-scripts

```

Usage: ./initial-setup.sh ipaddress_of_rpi

```

## commissionScript.py

Run commissionScript.py to set the following:

1) Setup the wanted hostname
2) Create tunneling configuration (if required), to setup and maintain a reverse ssh tunnel to an external server.  This allows remote access to the rPi via an AWS EC2 instance or any other server with a fixed IP address
3) Modify .vimrc to support backspace and arrows for up/down etc.
4) Run apt update and apt full-upgrade
5) Install various useful packages (screen, minicom , avahi-deamon, ssmtp, mailutils and others)
6) Setup ssmtp to email kgpython@gmail.com when the device reboots (with the device IP address)
7) Install python pip3
8) Show instructions for creating device ssh key

## commissionScript Usage:

```

Usage: sudo ./commissionScript.py new_hostname aws_port kgpython_password

new_hostname = The new hostname you want to give the rPi
aws_port = Port number to use for reverse tunnel.  Use 0000 if not required.
kgpython_password = application password for gmail for kgpython@gmail.com.  See below.

```

## Generating an application email password for Gmail
Generate an application email password for the gmail account as follows:
Manage Google Acccount > Security > Signing into Google - App Passwords.
Create a password for the particular app/device and make a note of the password.


## Reverse Tunnel

For creating reverse tunnels to a test server (server with a fixed IP address):

1. Create keys for the rPi to login to the server

   - Create an ssh key on the rPi as follows:
      mkdir /home/pi/.ssh
      cd .ssh
      ssh-keygen -t rsa  (just save with defaults)

   - Copy the contents of the pulic key to autorized_keys on the test server

2. Insert an entry in crontab to run createTunnel.sh every 1mins (commissionScript.py will do this).
   
   '#' Restart the ssh tunnel if it's down - every 1min
   * * * * * /home/pi/repositories/rpi-commision-scripts/createTunnel.sh > /dev/null

### Notes on the createTunnel.sh script.

ssh to server (defined in .ssh/config) and create a reverse tunnel to redirect traffic sent
to port XXXX  on remote machine to the local machine on port YY.

Incoming Traffic >> Port XXXX on server >> Port YY on rpi

We use the following SSH parameters:

-o ExitOnForwardFailure=yes    Exit if the tunnel command fails. ssh would typically return a
                               warning but would not exit.  So when checking running processes
                               we would think the tunnel was ok, when it has actually failed.
-o ServerAliveInterval=60      Send null packets every 60s to keep tunnel open (some routers or firewalls
                               will close stale tunnels if no traffic
-f = Requests ssh to go to background just before command execution.
     Also redirects stdin from /dev/null (requred for ssh to run in background)
-N = Do not execute a remote command.  This is useful for just forwarding ports
-R = Specifies that the given port on the remote (server) host is to be forwarded to the
     given host and port on the local side.

When grep'ing to check the process is running we use square brackets around a character in the search
string so that we don't return the grep process itself along with the wanted process.

The square bracket means to match the regex within the bracket.  In our case one character which is therefore
the exact search string we want.  Crucially however the grep process listing has the square bracket in it and
is therefore excluded from the response returned from grep

e.g. ps ax | grep [w]antedProcesString

We use "eval $cmd" as this makes the command execute correctly with the included pipe.

## Notes on setting up mail on rPi

Generate an application email password for the gmail account as follows:
Manage Google Acccount > Security > Signing into Google - App Passwords.
Create a password for the particular app/device and make a note of the password.

edit /etc/smtp/smtp.config to be as follows.

```
#
# Config file for sSMTP sendmail
#
# The person who gets all mail for userids < 1000
# Make this empty to disable rewriting.
root=<Insert the gmail email address here>

# The place where the mail goes. The actual machine name is required no 
# MX records are consulted. Commonly mailhosts are named mail.domain.com
mailhub=smtp.gmail.com:587

# Where will the mail seem to come from?
#rewriteDomain=

# The full hostname
hostname=<Insert the device hostname here>

# Are users allowed to set their own From: address?
# YES - Allow the user to specify their own From: address
# NO - Use the system generated From: address
FromLineOverride=YES

AuthUser=<Insert the gmail email address here>
AuthPass=<Insert the google application password here>
UseSTARTTLS=YES
UseTLS=YES

```

# Setup MSMTP

Using email on newer rpi builds. smtp no longer supported so use msmtp instead.

```
sudo apt install msmtp msmtp-mta mailutils
```


### Put the following into /etc/msmtprc 
```
Put the following into /etc/msmtprc 
# Generics
defaults
auth           on
tls            on
# following is different from ssmtp:
tls_trust_file /etc/ssl/certs/ca-certificates.crt
# user specific log location, otherwise use /var/log/msmtp.log, however, 
# this will create an access violation if you are user pi, and have not changes the access rights
#logfile        ~/.msmtp.log

# Gmail specifics
account        gmail
host           smtp.gmail.com
port           587

from          root@raspi-buster
user          kgpython@gmail.com
password      <INSERT PASSWORD HERE>

# Default
account default : gmail
```

