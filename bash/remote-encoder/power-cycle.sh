#!/bin/bash
while :
do
	if pgrep -x "HandBrakeCLI" > /dev/null
	then
		echo "$(date): HandBrakeCLI is running, retrying.." >> /home/$USER/powerlog.txt
		sleep 300
	else
		echo "$(date): HandBrakeCLI process not found, shutting down" >> /home/$USER/powerlog.txt
		break
	fi
done
sudo /sbin/poweroff
