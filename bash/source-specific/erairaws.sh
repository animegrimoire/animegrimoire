#!/bin/bash
startl=$(date +%s)
# This is a user-specific script configuration, your machine might unable to use this like default scripts

# Load config file
source /home/$USER/.local/config/animegrimoire.conf

#	Logging functions
readonly log="animegrimoire_log_erai$(date +%d%m%H%M).log"
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>"$log" 2>&1

# Pull remote fonts
mv -v $remote_fonts/*.* "/home/$USER/.fonts/"
fc-cache -f

# make sure there aren't any other HandBrakeCLI process running
	handbrake_test

# make sure sshfs is running
	sshfs_test

# Capture both input and hold it somewhere
echo "$1" > ./filename.tmp
sed -i 's/,//g' ./filename.tmp
sed -i 's/`//g' ./filename.tmp
sed -i 's/\r$//g' ./filename.tmp
input="$(<./filename.tmp)"
output="$(echo "$input" | cut -f 1 -d '.').mp4"
subtitle="$(echo "$input" | cut -f 1 -d '.').ass"
echo "Input is: $input"
echo "Output is: $output"
echo "Subtitle is: $subtitle"
# echo "fansub is: $fansub"
mv -v "$1" "$input"
rm -v ./filename.tmp

# Stage 5:	send subbed $input to HandBrakeCLI encoder with animegrimoire's preset.
echo "$(date): Begin encoding process"

# 5.1: Push Notification while encoding started
telegram-send --format markdown "Encoding Start(Airing): *$1*"
_webhook="$webhook_avx"
_title="Encoding Start"
_timestamp="$USER@$HOSTNAME $(date)"
_description="Encoding Start(BD): $1"
discord-msg --webhook-url="$_webhook" --title="$_title" --description "$_description" --color "0xff0004" --footer="$_timestamp"

# 5.2 Initiate encoding
/usr/local/bin/HandBrakeCLI --preset-import-file "$preset" -Z "x264_Animegrimoire" -i "$input" -o "$output"

# Stage 6: Insert [animegrimoire] and resolution tag
echo "$output" > ./hold.name
sed -i 's/^/\[animegrimoire\] /' ./hold.name
sed -i 's/\.[^.]*$/ \[720p\].mp4/' ./hold.name
mv "$output" "$(<./hold.name)"

echo "$(date): Embedding CRC32 Hash"
/usr/bin/rhash --embed-crc --embed-crc-delimiter='' "$(cat hold.name | cut -d "\`" -f3 | cut -d "'" -f 1)" && rm -v hold.name

# Clean up.
echo "$(date): Cleaning up"
rm -v ./*.*tf ./*.*TF
rm -v ./*.tmp* ; rm -v ./*.ass ; rm -v "$input"
rm -v "$input"

# make sure sshfs is running
	sshfs_test

# Move completed files
echo "$(date): Moving finished files"
for files in \[animegrimoire\]\ *.mp4; do rclone copy "$files" "$finished_folder_rclone"; done
for files in \[animegrimoire\]\ *.mp4; do scp -v "$files" "$finished_folder_remote" && rm -v "$files"; done
for files in *.log; do scp -v "$files" "$finished_folder_remote" && rm -v "$files"; done

## Exit encoding
endl=$(date +%s)
echo "This script was running for $((endl-startl)) seconds."

# Push notification to Discord using Webhook (https://github.com/ChaoticWeg/discord.sh)
_webhook="$webhook_avx"
_title="[Finished Encoding]"
_timestamp="$USER@$HOSTNAME $(date)"
_description="$1 in $((endl-startl)) seconds."
discord-msg --webhook-url="$_webhook" --title="$_title" --description "$_description" --color "0xff0004" --footer="$_timestamp"
telegram-send --format markdown "Finished Encoding: *$1*"
