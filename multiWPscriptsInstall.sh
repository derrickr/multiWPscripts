#!/bin/bash

#	Check if target directory exists
if [ ! -d ~/multiWPscripts/archive ] ; then

#	Create dir for scripts
	mkdir -p ~/multiWPscripts/archive
fi

#	Tar current multiWPscripts contents into archive
	tar --exclude='~/multiWPscripts/archive' -czf ~/multiWPscripts/archive/multiWPscripts-$(date +%Y%m%d%H%M%S).tgz ~/multiWPscripts/*.* 2>/dev/null

#	Clean up target
	rm -rf ~/multiWPscripts/*.*
	
#	change dir
	cd ~/multiWPscripts/

#	wget the multiWPscripts from github
#	wget https://github.com/derrickr/multiWPscripts/archive/master.zip
	wget -O getWPconfig.sh https://github.com/derrickr/multiWPscripts/blob/master/getWPconfig.sh?raw=true
	wget -O showWPconfig.sh https://github.com/derrickr/multiWPscripts/blob/master/showWPconfig.sh?raw=true
	wget -O drWPbup https://github.com/derrickr/multiWPscripts/blob/master/drWPbup?raw=true
	wget -O drWPrecovery.sh https://github.com/derrickr/multiWPscripts/blob/master/drWPrecovery.sh?raw=true

#	Make them all exectuable
	chmod 500 ~/multiWPscripts/*

#	Move backup script into daily cron
	mv ~/multiWPscripts/drWPbup /etc/cron.daily/drWPbup
