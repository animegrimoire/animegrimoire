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
## /home/$USER/Animegrimoire/sshfs/{horriblesubs|dmonhiro|erairaws|other}/   as source files location  
## /home/$USER/Animegrimoire/sshfs/finished     as encoded files location
## /home/$USER/Animegrimoire/local/encodes      as encoding place
##
##/home/$USER/Animegrimoire/local
##                      |   └── /encodes
##                  sshfs/                        
##                      ├── horriblesubs             
##                      ├── dmonhiro
##                      ├── erairaws  
##                      ├── other  
##                      └── finished                   
##
startl=$(date +%s)
other=/home/$USER/Animegrimoire/sshfs/other/
erairaws=/home/$USER/Animegrimoire/sshfs/erairaws/
dmonhiro=/home/$USER/Animegrimoire/sshfs/dmonhiro/
horriblesubs=/home/$USER/Animegrimoire/sshfs/horriblesubs/
encode_folder=/home/$USER/Animegrimoire/local/encodes/
finished_folder=/home/$USER/Animegrimoire/sshfs/finished
_webhook_="_url_"


while :
do

# make sure there aren't any other HandBrakeCLI process running
	while :
	do
  		if pgrep -x "HandBrakeCLI" > /dev/null
    	then
      	echo "HandBrakeCLI is running, retrying.."
      	sleep 300
  	else
    	echo "HandBrakeCLI process not found, continuing subroutine."
    	break
  		fi
	done

# Stage 1: go to horriblesubs folder, check if file exist, report when start encoding
	cd $horriblesubs
	if [ -f *.mkv ]; then
		H=1
		echo "File(s) found. begin encoding"
		mvg -g "$horriblesubs/*.mkv" $encode_folder
		# Report it
		_title_="[Encoding started]"
		_timestamp_="$USER@$HOSTNAME $(date)"
		_description_="Source file(s) found. start encoding."
		_listfile_="$(ls -Ss1pq --block-size=1000000 $other/ | jq -Rs . | cut -c 2- | rev | cut -c 2- | rev)"
		discord-msg --webhook-url="$_webhook_" --title="$_title_" --description="$_description_" --color="0xff0004" --text="$_listfile_" --footer="$_timestamp_"
		for hssrc in $encode_folder/*.mkv; do animegrimoire "$hssrc"; done
		for hsmp4 in $encode_folder/\[animegrimoire\]\ *.mp4; do mvg -g "$hsmp4" $finished_folder; done
	else
		echo "File(s) not found. go to next sources"
		H=0
		cd ~
	fi
# Stage 2: go to erairaws folder, check if file exist, report if exist 
	cd $erairaws
	if [ -f *.mkv ]; then
		E=1
		echo "File(s) found. begin encoding"
		# Report it
		_title_="[Encoding started]"
		_timestamp_="$USER@$HOSTNAME $(date)"
		_description_="Source file(s) found. start encoding."
		# Since Erai-Raws require "$2" input as delimiter, make sure it's exist
		if [ -s erai.txt ]
		then
			E=2
        	echo erai.txt instruction is required to begin encoding
        	discord-msg --webhook-url="$_webhook_" --title="[Starting Failed]" --description="client.sh line 80. delimiter(int) from erai.txt required. exiting" --color="0xff0004" --footer="$_timestamp_"
			exit
		else
        	E=3
        	echo erai.txt instruction found. begin encoding
        	_erai_=$(cat erai.txt)
        	echo erai delimiter is $_erai_
			discord-msg --webhook-url="$_webhook_" --title="$_title_" --description="$_description_" --color="0xff0004" --text="$_listfile_" --footer="$_timestamp_"
			mvg -g "$erairaws/*.mkv" $encode_folder
			for ersrc in $encode_folder/*.mkv; do erai "$ersrc" $_erai_; done
			for ersp4 in $encode_folder/\[animegrimoire\]\ *.mp4; do mvg -g "$ersp4" $finished_folder; done
		fi 
	else
		echo "File(s) not found. go to next sources"
		E=4
		cd ~
	fi
# Stage 3: go to dmonhiro, check if file exist, report if exist 
	cd $dmonhiro
	if [ -f *.mkv ]; then
		D=1
		echo "File(s) found. begin encoding"
		# Report it
		_title_="[Encoding started]"
		_timestamp_="$USER@$HOSTNAME $(date)"
		_description_="Source file(s) found. start encoding."
		# Since Erai-Raws require "$2" input as file title, make sure it's exist
		if [ -s dmon.txt ]
		then
			D=2
        	echo dmon.txt instruction is required to begin encoding
        	discord-msg --webhook-url="$_webhook_" --title="[Starting Failed]" --description="client.sh line 112. new file name from dmon.txt required. exiting" --color="0xff0004" --footer="$_timestamp_"
			exit
		else
        	D=3
        	echo dmon.txt instruction found. begin encoding
        	_dmon_=$(cat dmon.txt)
        	echo dmon new file name is $_dmon_
			discord-msg --webhook-url="$_webhook_" --title="$_title_" --description="$_description_" --color="0xff0004" --text="$_listfile_" --footer="$_timestamp_"
			mvg -g "$dmonhiro/*.mkv" $encode_folder
			for dmnrc in $encode_folder/*.mkv; do dmon "$dmnrc" $_dmon_; done
			for dmnp4 in $encode_folder/\[animegrimoire\]\ *.mp4; do mvg -g "$dmnp4" $finished_folder; done
		fi 
	else
		echo "File(s) not found. go to next sources"
		D=4
		cd ~
	fi
# Stage 4: go to other folder, check if file exist, report if exist 
	cd $other
		if [ -f *.mkv ]; then
		O=1
		echo "File(s) found. Reporting it."
	_title="[Pending encodes]"
	_timestamp="$USER@$HOSTNAME $(date)"
	_description="Current pending for encoding."
	_listfile="$(ls -Ss1pq --block-size=1000000 $other/ | jq -Rs . | cut -c 2- | rev | cut -c 2- | rev)"
	discord-msg --webhook-url="$_webhook" --title="$_title" --description="$_description" --color="0xff0004" --text="$_listfile" --footer="$timestamp"
	else
		echo "File(s) not found. subroutine finished."
		O=4
		cd ~
	fi
# Stage 5: report a heartbeat then sleep before going back to loop
	_title_="[Heartbeat]"
	_timestamp="AVX-chan@$HOSTNAME $(date)"
	_description="Subroutine finished with code $H$E$D$O. Sleeping for next 1800s"
	discord-msg --webhook-url="$_webhook" --title="$_title" --description="$_description" --color="0xff0004" --text="$_listfile" --footer="$timestamp"
	sleep 1800
	echo Return to beginning
done
