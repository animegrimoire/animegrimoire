#!/bin/bash
## This script is purposed to reduce user-interaction during automated encoding.
## extended from animegrimoire.sh with folder watcher and
## automatically report encoded files using discord webhook.
## Tested in CentOS8. not recommended to run in debian-flavor as this script
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

# Load config file
source /home/$USER/.local/config/animegrimoire.conf

#Send-msg block
function discord_report {
	_title_="[Encoding started]"
	_timestamp_="$USER@$HOSTNAME $(date)"
	_description_="Source file(s) or folder found. listing files, starting.."
	discord-msg --webhook-url="$webhook_avx" --title="$_title_" --description="$_description_" --color="$gween" --footer="$_timestamp_"
	discord-msg --webhook-url="$webhook_avx" --text="$(ls -Ss1pq ./*.mkv --block-size=1000000 | jq -Rs . | cut -c 2- | rev | cut -c 2- | rev)"
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
cd "$horriblesubs" || exit
if [ "$(ls -1 ./*.mkv 2>/dev/null | wc -l )" -gt 0 ]; then
	H=1
	echo "$(date): File(s) found in HorribleSubs folder. begin encoding"
	rsync --remove-source-files --progress rsync://"$REMOTE_HOST"/"$remote_hs"/*.mkv "$encode_folder"
	cd "$encode_folder" || exit
	discord_report
	for hssrc in *.mkv; do animegrimoire.sh "$hssrc"; done
else
	echo "$(date): File(s) not found in HorribleSubs folder. go to next sources"
	H=0
	cd ~ || exit
fi

# Stage 2: go to erairaws folder, check if file exist, report if exist
cd "$erairaws" || exit
if [ "$(ls -1 ./*.mkv 2>/dev/null | wc -l )" -gt 0 ]; then
	E=1
	echo "$(date): File(s) found in Erai-raws folder. begin encoding"

	# Since Erai-raws require "$2" input as delimiter, make sure it's exist
	if [ ! -s erai.txt ]; then
		E=2
		echo "$(date): erai.txt in $erairaws instruction is required to begin encoding"
		discord-msg --webhook-url="$webhook_avx" --title="[Starting Failed]" --description="client.sh line 81. delimiter(int) from erai.txt required. exiting" --color="$rwed" --footer="$_timestamp_"
	else
		E=3
		echo "$(date): erai.txt instruction found. begin encoding"
		_erai_=$(cat erai.txt)
		echo erai delimiter is "$_erai_"
		rsync --remove-source-files --progress rsync://"$REMOTE_HOST"/"$remote_erai"/*.mkv "$encode_folder"
		cd "$encode_folder" || exit
		discord_report
		for ersrc in \[Erai-raws\]\ *.mkv; do erairaws.sh "$ersrc" "$_erai_"; done
		rm -rfv erai.txt
	fi
else
	echo "$(date): File(s) not found in erairaws folder. go to next sources"
	E=4
	cd ~ || exit
fi
# Stage 3: go to dmonhiro, check if file exist, report if exist
cd "$dmonhiro" || exit
if [ "$(ls -1 ./*.mkv 2>/dev/null | wc -l )" -gt 0 ]; then
	D=1
	echo "$(date): File(s) in dmonhiro folder found. begin encoding"

	# Since DmonHiro require "$2" input as file title, make sure it's exist
	if [ ! -s dmon.txt ]; then
		D=2
		echo "$(date): dmon.txt instruction in $dmonhiro is required to begin encoding"
		discord-msg --webhook-url="$webhook_avx" --title="[Starting Failed]" --description="client.sh line 108. new file name from dmon.txt(str) required. exiting" --color="$rwed" --footer="$_timestamp_"
	else
		D=3
		echo "$(date): dmon.txt instruction found. begin encoding"
		_dmon_=$(cat dmon.txt)
		echo dmon new file name is "$_dmon_"
		cd "$dmonhiro" || exit
		rsync --remove-source-files --progress rsync://"$REMOTE_HOST"/"$remote_dmon"/*.mkv "$encode_folder"
		rsync --remove-source-files --progress rsync://"$REMOTE_HOST"/"$remote_dmon"/*.ass "$encode_folder"
		cd "$encode_folder" || exit
		discord_report
		for dmnrc in *.mkv; do dmonhiro.sh "$dmnrc" "$_dmon_"; done
		rm -rfv dmon.txt
	fi
else
	echo "$(date): File(s) not found in dmonhiro folder. go to next sources"
	D=4
	cd ~ || exit
fi
# Stage 4: go to other folder, check if file exist, report if exist
cd "$other" || exit
if [ "$(ls -1 ./*.mkv 2>/dev/null | wc -l )" -gt 0 ]; then
	O=1
	echo "$(date): File(s) found in other folder. Reporting it."
	_title="[Pending encodes]"
	_timestamp="$USER@$HOSTNAME $(date)"
	_description="Current pending for encoding."
	discord-msg --webhook-url="$webhook_avx" --title="$_title" --description="$_description" --color="$yellw" --footer="$_timestamp"
	discord-msg --webhook-url="$webhook_avx" --text="$(ls -Ss1pq --block-size=1000000 | jq -Rs . | cut -c 2- | rev | cut -c 2- | rev)"
else
	echo "$(date): File(s) in other folder not found. subroutine finished."
	O=2
	cd ~ || exit
fi
# Stage 5: report a heartbeat then sleep before going back to loop
	_title_="[Heartbeat]"
	_timestamp_="AVX-chan@$HOSTNAME $(date)"
	_description_="Subroutine finished with code $H$E$D$O. Sleeping for next 3600s"
	discord-msg --webhook-url="$webhook_avx" --title="$_title_" --description="$_description_" --color="$uwus" --footer="$_timestamp_"
	sleep 3600
	echo "$(date): Remounting sshfs folder"
	sudo /usr/bin/umount /home/"$USER"/Animegrimoire/sshfs
	~/.local/bin/ssfsd-mount
	echo "$(date): Return to beginning"
done
