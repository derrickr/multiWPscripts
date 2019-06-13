#!/bin/bash

#export NCURSES_NO_UTF8_ACS=1

#	Get server name and path for all WordPress sites-enabled
	source ~/multiWPbup/getWPsites.sh

#	Set variables for whiptail dialog box
	HEIGHT=17
	WIDTH=60
	CHOICE_HEIGHT=10
	BACKTITLE="Multi WordPress Files & Database Restore"
	TITLE="Available Domains"
	MENU="Choose one of the following options:"

#	Display Menu to select server_name / domain to be restored
	CHOICE=$(/bin/whiptail --clear --backtitle "$BACKTITLE" --title "$TITLE" --menu "$MENU" $HEIGHT $WIDTH $CHOICE_HEIGHT `for value in ${!serverName[@]}; do echo "$value ${serverName[$value]}"; done` 2>&1 >/dev/tty)

#	Check exit staus of above
	if [[ "$?" != 0 ]] ; then
		echo -e "\nProblem detected! Please correct any discrepancies before running this script again."
		return 1
	fi

#	Used for dev to ensure correct values are being returned
#	echo $CHOICE
#	echo ${serverName[$CHOICE]}

#	Assign all files in /archive/ with selected server_name to array
	myFiles=`find /archive/ -name "*${serverName[$CHOICE]}*" | sort -u`

#	Archived files use Naming convention:	YYYYmmddHHMMSS-HOSTNAME-SERVER_NAME.tgz/sql
#	If the hostname is the same as the server_name, all server_name's would be returned in results (because of the naming convention, using HOSTNAME)
#	Therefore have to trim the length of the '/archive/' directory (9 chars), plus the length of the date/time (14 chars) and the two hyphens either side of the HOSTNAME = 14 + 9 + 2 = 25
#	Since $HOSTNAME can have a variable number of chars, we have to calculate how many chars need to be trimmed from the left for later operations
	trimNumLeft=$((25 + ${#HOSTNAME} ))

#	Declare array for dates
	declare -a serverNameDates=()

#	Add each of the files in /archive/ with the target serverName to array, which can then be used to display the dates for the target serverName for the user to select
#
#	Loop through myFiles array (i.e. files in /archive/ with selected server_name), assigned above
	for choiceFiles in ${myFiles[*]}; do

	#	If the selected server_name is the same a N of the values in the myFiles array, add those N values to a new array that can be used to present the correct set of dates back to the user
		if [ ${serverName[$CHOICE]} = ${choiceFiles:$trimNumLeft:${#serverName[$CHOICE]}} ] ; then

		#	echo ${choiceFiles:9:8} ; #	Used for dev to ensure correct values are being returned
			serverNameDates+=("${choiceFiles:9:8}")
		fi
	done

#	Create array of dates from serverNameDates array above; sort, unique
	bupDates=( $(printf '%s\n' "${serverNameDates[@]}" | sort -u) )

#	Display Menu to select date for server_name / domain to be restored
	SELECTION=$(/bin/whiptail --clear --backtitle "$BACKTITLE" --title "Available Dates" --menu "$MENU" $HEIGHT $WIDTH $CHOICE_HEIGHT `for value in ${!bupDates[@]}; do echo "$value ${bupDates[$value]}"; done` 2>&1 >/dev/tty)

#	Check exit staus of above
	if [[ "$?" != 0 ]] ; then
		echo -e "\nProblem detected! Please correct any discrepancies before running this script again."
		return 1
	fi

#	Used for dev to ensure correct values are being returned
#	echo $SELECTION
#	echo ${bupDates[$SELECTION]}

#	now we move on to the restore....

#	Show values back to user
	/bin/whiptail --title "Selected values" --yesno "Are these the correct values?\n\nServer_name: ${serverName[$CHOICE]}\n\nDate: ${bupDates[$SELECTION]}" 11 70

#	Check exit staus of above
	if [[ "$?" != 0 ]] ; then
		echo -e "\nProblem detected! Please correct any discrepancies before running this script again."
		return 1
	fi

#	Loop to match selected server_name to get specific config values
#	set integer for loop ; 
	i=0

	for domain in "${serverName[@]}"; do

		if [ $domain = ${serverName[$CHOICE]} ] ; then

			echo -e "\nServer name: ${domain}" 

			WP_path=${sitePaths[$i]} ;
			echo "WP_path:    " $WP_path

			WP_conf="$WP_path/wp-config.php" ;
			echo "WP_conf:    " $WP_conf

			WP_db=`cat $WP_conf | grep DB_NAME | cut -d \' -f 4` ;
			echo "WP_db:      " $WP_db

			WP_user=`cat $WP_conf | grep DB_USER | cut -d \' -f 4` ;
			echo "WP_user:    " $WP_user

			WP_pass=`cat $WP_conf | grep DB_PASSWORD | cut -d \' -f 4` ;
			echo "WP_db:      " $WP_pass

			redisPW=`cat $WP_conf | grep WP_REDIS_PASSWORD | cut -d \' -f 4` ;
			echo "redisPW:    " $redisPW
			
			continue

		fi

		((i++))

	done

###########################	return

#	set backupFiles and database values
	backupFiles="/archive/${bupDates[$SELECTION]}*${serverName[$CHOICE]}*.tgz"
	backupDatabase="/archive/${bupDates[$SELECTION]}*${serverName[$CHOICE]}*.sql"

#	Move current wp dir to timestamped
	mv $WP_path $WP_path-$dateTime

#	Extract backupFile
	tar xf $backupFiles -C /

#	Copy over wp-config from previous version
	cp $WP_path-$dateTime/wp-config.php $WP_conf

#	Ensure ownership is correct
	chown -R www-data:www-data $WP_path



########################################################


#	Import source db into target
	mysql -u $WP_user -p$WP_pass $WP_db < $backupDatabase 2>/dev/null

#	Remove nginx cache contents
	rm -rf /var/www/cache/*

#	Check if Redis being used
	if [ $redisPW ] ; then

	#	Flush redis cache
		redis-cli -a $redisPw FLUSHALL

	fi

#	Restart services
	systemctl restart mysql

	if [ `which nginx` ] ; then
		systemctl restart nginx
	else
		systemctl restart apache2
	fi
	systemctl restart redis-server
