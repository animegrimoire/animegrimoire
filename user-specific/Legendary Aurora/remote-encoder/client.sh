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
## /home/$USER/Animegrimoire/sshfs/{horriblesubs|dmonhiro|erairaws|other}/	as source files location  
## /home/$USER/Animegrimoire/sshfs/finished	as encoded files location
## /home/$USER/Animegrimoire/local/encodes		as encoding place
##
##~/Animegrimoire/local
##			|   └── /encodes
##			sshfs/                        
##				├── horriblesubs             
##				├── dmonhiro
##				├── erairaws  
##				├── other  
##				└── finished                   
##
other=/home/$USER/Animegrimoire/sshfs/other/
erairaws=/home/$USER/Animegrimoire/sshfs/erairaws/
dmonhiro=/home/$USER/Animegrimoire/sshfs/dmonhiro/
horriblesubs=/home/$USER/Animegrimoire/sshfs/horriblesubs/
encode_folder=/home/$USER/Animegrimoire/local/encodes/
finished_folder=/home/$USER/Animegrimoire/sshfs/finished
_webhook_="$(printf ~/.webhook_client)"
#Color
yellw=0xfae701
gween=0x00ffbc
rwed=0xff0004
uwus=0xfd0093
#Send-msg block
function discord_report {
	_title_="[Encoding started]"
	_timestamp_="$USER@$HOSTNAME $(date)"
	_description_="Source file(s) folder found. listing files, starting.."
	discord-msg --webhook-url="$_webhook_" --title="$_title_" --description="$_description_" --color="$gween" --footer="$_timestamp_"
	discord-msg --webhook-url="$_webhook_" --text="$(ls -Ss1pq *.mkv --block-size=1000000 | jq -Rs . | cut -c 2- | rev | cut -c 2- | rev)"
}

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
if [ `ls -1 *.mkv 2>/dev/null | wc -l ` -gt 0 ]; then
	H=1
	echo "$(date): File(s) found in HorribleSubs folder. begin encoding"
	mvg -g *.mkv $encode_folder
	cd $encode_folder
	discord_report
	for hssrc in *.mkv; do animegrimoire "$hssrc"; done
else
	echo "$(date): File(s) not found in HorribleSubs folder. go to next sources"
	H=0
	cd ~
fi

# Stage 2: go to erairaws folder, check if file exist, report if exist 
cd $erairaws
if [ `ls -1 *.mkv 2>/dev/null | wc -l ` -gt 0 ]; then
	E=1
	echo "$(date): File(s) found in Erai-raws folder. begin encoding"

	# Since Erai-raws require "$2" input as delimiter, make sure it's exist
	if [ -s erai.txt ]; then
		E=2
		echo "$(date): erai.txt in "$erairaws" instruction is required to begin encoding"
		discord-msg --webhook-url="$_webhook_" --title="[Starting Failed]" --description="client.sh line 82. delimiter(int) from erai.txt required. exiting" --color="$rwed" --footer="$_timestamp_"
	else
		E=3
		echo "$(date): erai.txt instruction found. begin encoding"
		_erai_=$(cat erai.txt)
		echo erai delimiter is $_erai_
		mvg -g *.mkv $encode_folder
		cd $encode_folder
		discord_report
		for ersrc in \[Erai-raws\]\ *.mkv; do erai "$ersrc" $_erai_; done
	fi 
else
	echo "$(date): File(s) not found in erairaws folder. go to next sources"
	E=4
	cd ~
fi
# Stage 3: go to dmonhiro, check if file exist, report if exist 
cd $dmonhiro
if [ `ls -1 *.mkv 2>/dev/null | wc -l ` -gt 0 ]; then
	D=1
	echo "$(date): File(s) in dmonhiro folder found. begin encoding"

	# Since DmonHiro require "$2" input as file title, make sure it's exist
	if [ -s dmon.txt ]; then
		D=2
		echo "$(date): dmon.txt instruction in "$dmonhiro" is required to begin encoding"
		discord-msg --webhook-url="$_webhook_" --title="[Starting Failed]" --description="client.sh line 108. new file name from dmon.txt required. exiting" --color="$rwed" --footer="$_timestamp_"
	else
		D=3
		echo "$(date): dmon.txt instruction found. begin encoding"
		_dmon_=$(cat dmon.txt)
		echo dmon new file name is $_dmon_
		cd $dmonhiro
		mvg -g *.mkv $encode_folder
		mvg -g *.ass $encode_folder
		cd $encode_folder
		discord_report
		for dmnrc in *.mkv; do dmon "$dmnrc" $_dmon_; done
	fi 
else
	echo "$(date): File(s) not found in dmonhiro folder. go to next sources"
	D=4
	cd ~
fi
# Stage 4: go to other folder, check if file exist, report if exist 
cd $other
if [ `ls -1 *.mkv 2>/dev/null | wc -l ` -gt 0 ]; then
	O=1
	echo "$(date): File(s) found in other folder. Reporting it."
	_title="[Pending encodes]"
	_timestamp="$USER@$HOSTNAME $(date)"
	_description="Current pending for encoding."
	discord-msg --webhook-url="$_webhook_" --title="$_title" --description="$_description" --color="$yellw" --footer="$timestamp"
	discord-msg --webhook-url="$_webhook_" --text="$(ls -Ss1pq --block-size=1000000 | jq -Rs . | cut -c 2- | rev | cut -c 2- | rev)"
else
	echo "$(date): File(s) in other folder not found. subroutine finished."
	O=2
	cd ~
fi
# Stage 5: report a heartbeat then sleep before going back to loop
	_title_="[Heartbeat]"
	_timestamp_="AVX-chan@$HOSTNAME $(date)"
	_description_="Subroutine finished with code $H$E$D$O. Sleeping for next 1800s"
	discord-msg --webhook-url="$_webhook_" --title="$_title_" --description="$_description_" --color="$uwus" --footer="$_timestamp_"
	sleep 1800
	echo "$(date): Return to beginning"
done
