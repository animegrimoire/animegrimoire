#!/bin/bash
while :
do
	if pgrep -x "HandBrakeCLI" > /dev/null
	then
		echo "$(date): HandBrakeCLI is running, retrying.." >> ~/powerlog.txt
		sleep 300
	else
		echo "$(date): HandBrakeCLI process not found, shutting down" >> ~/powerlog.txt
		break
	fi
done
sudo /sbin/poweroff
