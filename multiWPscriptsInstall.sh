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
	wget -O getWPsites.sh https://github.com/derrickr/multiWPscripts/blob/master/getWPsites.sh?raw=true
	wget -O showWPconfigs.sh https://github.com/derrickr/multiWPscripts/blob/master/showWPconfigs.sh?raw=true
	wget -O multiWPbup https://github.com/derrickr/multiWPscripts/blob/master/multiWPbup?raw=true
	wget -O multiWPrecovery.sh https://github.com/derrickr/multiWPscripts/blob/master/multiWPrecovery.sh?raw=true

#	Make them all exectuable
	chmod 500 ~/multiWPscripts/*

#	Move backup script into daily cron
	mv ~/multiWPscripts/multiWPbup /etc/cron.daily/multiWPbup
