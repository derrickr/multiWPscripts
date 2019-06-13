**_multiWP-BupRestoreScripts_**

PLEASE NOTE: These scripts are NOT intended for WP's multi mode! But rather for separate multiple WP instances.

Bash scripts to acquire configuration settings, create multiple instance WP backups and restore from a choice of those backups

getWPsites.sh - Gets the configuration variables from the respective wp-config.php files for all Apache or Nginx 'sites-enabled' WP instances

showWPconfig.sh - Shows the wp-config.php settings for all Apache or Nginx 'sites-enabled' WP instances

multiWPBup.sh - This is moved into /etc/cron.daily to automate the daily backUp, on a rolling 10 day basis

multiWPrecovery.sh - Enables recovery from the automated backUps (above)



Install:

wget -O multiWPscriptsInstall.sh https://github.com/derrickr/multiWPscripts/blob/master/multiWPscriptsInstall.sh?raw=true && source multiWPscriptsInstall.sh


Usage:

1. Display the current WP instance config variables required for backup/restore:
   source showWPconfigs.sh

2. Dialog box showing the available backups to restore from:
   source multiWPrecovery.sh
