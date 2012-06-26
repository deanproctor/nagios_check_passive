nagios_check_passive
====================

This script is used to execute all Nagios NRPE active checks as NSCA passive checks.

Installation
------------

1. Upload nagios_check_passive.sh to the server to be monitored
2. Edit the script to set your Nagios server IP or hostname
3. chmod +x nagios_check_passive.sh
4. Place the script somewhere sane, such as /usr/local/bin/
5. Cron the script to execute at the desired check frequency