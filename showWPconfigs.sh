#!/bin/bash

#	Get server name and path for all WordPress sites-enabled
	source ~/multiWPbup/getWPsites.sh

#	set integer for loop
	i=0

for domain in "${serverName[@]}"; do

	echo -e "\nServer name: ${domain}" 

#	Set dateTimeHostDomain value
	dateTimeHostDomain="$dateTime-$HOSTNAME-${domain}"
	echo "dateHostDom: "$dateTimeHostDomain

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

	((i++))

done
