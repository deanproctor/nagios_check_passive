#!/bin/bash

# Set your Nagios host IP or hostname
NAGIOS_HOST=

# Path to your nrpe.cfg and any included cfg files
NRPE_CONFIG_DIR=/etc/nagios

# The hostname that will be sent to Nagios
HOSTNAME=`hostname`

# The path to the send_nsca binary
SEND_NSCA=/usr/sbin/send_nsca

# Explicitly set a path in case the user executing this script lacks one
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Finds all .cfg files in the $NRPE_CONFIG_DIR and returns all lines containing a command definition
RAW_COMMANDS=$(/usr/bin/find $NRPE_CONFIG_DIR -name *.cfg -exec cat {} \; | /bin/egrep '^command\[(.*?)\]')

# Reset IFS when necessary to preserve command arguments
OIFS="${IFS}"
NIFS=$'\n'

IFS="${NIFS}"

# Iterates over each matched line in $RAW_COMMANDS, extracts the name and command for each
# check, executes the check and submits the results to Nagios
for LINE in ${RAW_COMMANDS} 
do
  IFS="${OIFS}"
  
  # The check name to be submitted to Nagios
  NAME=$(/bin/echo ${LINE} | /usr/bin/awk 'NR>1{print $1}' RS='[' FS=']')

  # The command to be executed for the check
  COMMAND=$(/bin/echo ${LINE} | /usr/bin/cut -f2 -d '=')

  # Execute the check and save the check output and exit value
  IFS="${NIFS}"
  OUTPUT=$(/bin/bash -c "$COMMAND"; exit $?)
  RET=$?
  IFS="${OIFS}"

  # Send the passive check result to Nagios
  printf "${HOSTNAME}\t${NAME}\t${RET}\t$(printf '%q' ${OUTPUT})\n" | $SEND_NSCA -H $NAGIOS_HOST

  IFS="${NIFS}"
done
