#!/bin/bash
## This script is purposed to reduce user-interaction during automated encoding.
## extended from animegrimoire.sh with folder watcher and
## automatically report encoded files using discord webhook.
## Tested in CentOS8. not recommended to run in debian-flavor as this script
## is not POSIX compliant.
##
## We will exclusively using SSHFS as file transport.
## Important: these are main folder that used in whole encoding process
## /home/$USER/Animegrimoire/sshfs/{horriblesubs|bluray{0..3}|other}/ as source files location
## /home/$USER/Animegrimoire/sshfs/finished	as encoded files location
## /home/$USER/Animegrimoire/local/encodes as encoding place
##
##~/Animegrimoire/local
##			|   └── /encodes
##			sshfs/
##				├── horriblesubs
##				├── bluray0
##				├── bluray1
##				├── bluray2
##				├── bluray3
##				├── other
##				└── finished
##

# Load config file
source /home/$USER/.local/config/animegrimoire.conf

while :
do
# make sure there aren't any other HandBrakeCLI process running
	handbrake_test

# make sure sshfs is running
	sshfs_test

# Stage 1: go to Erairaws folder, check if file exist, report when start encoding
cd "$erairaws" || exit
if [ "$(ls -1 ./*.mkv 2>/dev/null | wc -l )" -gt 0 ]; then
	A=1
	echo "$(date): File(s) found in EraiRaws folder. begin encoding"
	rsync --remove-source-files --progress rsync://"$REMOTE_HOST"/"$remote_erai"/*.mkv "$encode_folder"
	cd "$encode_folder" || exit
	discord_report
	for files in *.mkv; do erairaws.sh "$files"; done
else
	echo "$(date): File(s) not found in EraiRaws folder. go to next sources"
	A=0
	cd ~ || exit
fi

# Stage 2: go to bluray, check if file exist, report if exist
cd "$bluray0" || exit
if [ "$(ls -1 ./*.mkv 2>/dev/null | wc -l )" -gt 0 ]; then
	B=1
	echo "$(date): File(s) in bluray(s) folder found. begin encoding"

	# Since bluray require "$2" input as file title and delimiter, make sure it's exist
	if [ ! -s note.txt ]; then
		B=2
		echo "$(date): note.txt instruction in $bluray0 is required to begin encoding"
		discord-msg --webhook-url="$webhook_avx" --title="[Starting Failed]" --description="client.sh line 59. new file name from note.txt(str 0,1) required. exiting" --color="$rwed" --footer="$_timestamp_"
	else
		B=3
        echo "$(date): note.txt instruction found. begin encoding"
        _mon_="$(cat note.txt | head -n 1)"
        _lim_="$(cat note.txt | tail -n 1)"
        echo new file name is "$_mon_" and delimiter value is "$_lim_"
        cd "$bluray0" || exit
        rsync --remove-source-files --progress rsync://"$REMOTE_HOST"/"$remote_bluray0"/*.mkv "$encode_folder"
        cd "$encode_folder" || exit
        discord_report
        for files in *.mkv; do bluray.sh "$files" "$_mon_" "$_lim_"; done
        rm -rfv note.txt
	fi
else
	echo "$(date): File(s) not found in bluray folder. go to next sources"
	B=4
	cd ~ || exit
fi

# Stage 2.1: Vorriblesubs folder, check if file exist, report when start encoding. we can't use goto..
cd "$horriblesubs" || exit
if [ "$(ls -1 ./*.mkv 2>/dev/null | wc -l )" -gt 0 ]; then
	C=1
	echo "$(date): File(s) found in HorribleSubs folder. begin encoding"
	rsync --remove-source-files --progress rsync://"$REMOTE_HOST"/"$remote_hs"/*.mkv "$encode_folder"
	cd "$encode_folder" || exit
	discord_report
	for files in *.mkv; do horriblesubs.sh "$files"; done
else
	echo "$(date): File(s) not found in HorribleSubs folder. go to next sources"
	C=0
	cd ~ || exit
fi

# Stage 6: report a heartbeat then sleep before going back to loop
	_title_="[Heartbeat]"
	_timestamp_="AVX-chan@$HOSTNAME $(date)"
	_description_="Subroutine finished with code $A$B$C. Sleeping for next 10800s"
	discord-msg --webhook-url="$webhook_avx" --title="$_title_" --description="$_description_" --color="$uwus" --footer="$_timestamp_"
	sleep 10800
	echo "$(date): Remounting sshfs folder"
	sudo /usr/bin/umount /home/"$USER"/Animegrimoire/sshfs
	sshfs-mount
	echo "$(date): Return to beginning"
done
