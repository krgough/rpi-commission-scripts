rpi-commision-scripts/home/pi/repositories/rpi-commision-scripts

Bash scripts to help commissioning of rPIs for devices test ate 

Login to the new rpi and then clone this repo

./commissionScript - Updates the apt packages then installs various dependencies
                     edits vim config so that backspace and arrow keys works correctly

For creating reverse tunnels to a test server:

1. Create keys for the rPi to login to the server

   - Create an ssh key on the rPi as follows:
      mkdir /home/pi/.ssh
      cd .ssh
      ssh-keygen -t rsa  (just save with defaults)

   - Copy the contents of the pulic key to autorized_keys on the test server

2. Insert an entry in crontab to run createTunnel.sh every 1mins.
   
   '#' Restart the ssh tunnel if it's down - every 1min
   * * * * * /home/pi/repositories/rpi-commision-scripts/createTunnel.sh > /dev/null

*** Notes on the createTunnel.sh script.

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

*** Note on setting up mail on rPi

Generate an application email password for the gmail account as follows:
Manage Google Acccount > Security > Signing into Google - App Passwords.
Create a password for the particular app/device and make a note of the password.

edit /etc/smtp/smtp.config to be as follows.

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
hostname=<devices-sniffer09 or other device hostname>

# Are users allowed to set their own From: address?
# YES - Allow the user to specify their own From: address
# NO - Use the system generated From: address
FromLineOverride=YES

AuthUser=<Insert the gmail email address here>
AuthPass=<Insert the google password here>
UseSTARTTLS=YES
UseTLS=YES
