#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:

# Configuration Parameters
port="2225"
server_alias="kg_aws"

createTunnel() {
  # Build the command with the port number
  cmd="/usr/bin/ssh -o \"ExitOnForwardFailure yes\" -f -N -R $port:localhost:22 $server_alias"
  eval "$cmd"

  if [ $? == 0 ];then
    echo Tunnel created successfully
  else
    echo Tunnel failed. Code was $?
  fi
}

# Check if tunnel is running. If not then create one.
cmd="/bin/ps ax | /usr/bin/grep \"$port:[l]ocalhost:22\""
eval "$cmd"
if [ $? -ne 0 ] ; then
  echo Creating new tunnel connection
  createTunnel
else
  echo Tunnel already connected
fi
