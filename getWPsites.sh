#!/bin/bash

#	Set dateTime
	dateTime=$(date +%Y%m%d%H%M%S)

#	Get config values for all WordPress sites-enabled

#	Test if nginx or apache is being used
	if [ `which nginx` ] ; then
		webServer='nginx'
		srvNameDirective='server_name'
		webRoot='root'
else
		webServer='apache2'
		srvNameDirective='ServerName'
		webRoot='DocumentRoot'
fi

#	Determine server name from sites-enabled/
	serverName=(`grep $srvNameDirective /etc/$webServer/sites-enabled/* | sed 's/.*root \(.*\);/\1/' | uniq | cut -d " " -f 2 | sed 's/.$//'`)

#	Determine path from sites-enabled/
	sitePaths=(`grep $webRoot /etc/$webServer/sites-enabled/* | sed 's/.*root \(.*\);/\1/' | uniq`)
