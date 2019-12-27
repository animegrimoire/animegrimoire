#!/bin/bash
unset HISTFILE
## This script is purposed to reduce user-interaction during automated encoding.
## extended from animegrimoire.sh with folder watcher and
##  automatically report encoded files using discord webhook.
## ((WAITING FOR TEST IN CENTOS8)). not recommended to run in debian-flavor as this script
## is not POSIX compliant.
##
## We will exclusively using SSHFS as file transport.
## Important: these are main folder that used in whole encoding process
## /home/$USER/Animegrimoire/sshfs/{horriblesubs|erairaws|other}/   as source files location  
## /home/$USER/Animegrimoire/sshfs/finished     as encoded files location
## /home/$USER/Animegrimoire/local/encodes      as encoding place
##
##/home/$USER/Animegrimoire/local
##                      |   └── /encodes
##                  sshfs/                        
##                      ├── horriblesubs             
##                      ├── erairaws  
##                      ├── other  
##                      └── finished                   
##

other=/home/$USER/Animegrimoire/sshfs/other
erairaws=/home/$USER/Animegrimoire/sshfs/erairaws
horriblesubs=/home/$USER/Animegrimoire/sshfs/horriblesubs
encode_folder=/home/$USER/Animegrimoire/local/encodes
finished_folder=/home/$USER/Animegrimoire/sshfs/finished

startl=$(date +%s)
while :
do
if [ -f "$erairaws/*.mkv" ]; then
	mvg -g "$erairaws/*.mkv" $encode_folder
	for eraisrc in $encode_folder/*.mkv; do erai.sh "$eraisrc"; done
	for eraimp4 in $encode_folder/\[animegrimoire\]\ *.mp4; do mvg -g "$eraimp4" $finished_folder; done
elif [ -f "$horriblesubs" ]; then
	mvg -g "$horriblesubs/*.mkv" $encode_folder
	for hssrc in $encode_folder/*.mkv; do animegrimoire "$hssrc"; done
	for hsmp4 in $encode_folder/\[animegrimoire\]\ *.mp4; do mvg -g "$hsmp4" $finished_folder; done
elif [ -f "$other/*.mkv" ]; then
	echo "Another source is available, but not included in automatic encoding"
	_webhook="_url_"
	_title="[Pending encodes]"
	_timestamp="$USER@$HOSTNAME $(date)"
	_description="Current pending for encoding."
	_listfile="$(ls -Ss1pq --block-size=1000000 $other/ | jq -Rs . | cut -c 2- | rev | cut -c 2- | rev)"
	discord-msg --webhook-url="$_webhook" --title="$_title" --description="$_description" --color="0xff0004" --text="$_listfile" --footer="$timestamp"
	sleep 3600
else
	echo "Nothing to do."
	discord-msg --webhook-url="$_webhook" --title="[Heartbeat]" --description="(!) Nothing to do, idling for next hour. I've been up for $((endl-startl)) seconds." --color="0x0080ff" --footer="$timestamp"
	sleep 3600
fi
done
