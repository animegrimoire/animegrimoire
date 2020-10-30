#!/bin/bash
startl=$(date +%s)
# Load config file
source /home/$USER/.local/config/animegrimoire.conf

##Logging functions
readonly log="animegrimoire_bd_$(date +%d%m%H%M).log"
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>"$log" 2>&1

# make sure there aren't any other HandBrakeCLI process running
	handbrake_test

# make sure sshfs is running
	sshfs_test

##init variable
subtitle=$(echo "$1" | cut -f 1 -d '.').ass


# 2: Register a new name
echo "$(date): Registering a new name"
file_name="[animegrimoire] $2 - $(echo "$1" | cut -f "$3" -d " " | cut -f 1 -d ".") [BD720p].mkv"
/usr/bin/mv -v "$1" "$file_name"
echo "$(date): New name is $file_name"

mv -v $remote_fonts/*.* "/home/$USER/.fonts/"
fc-cache -f


# 2: re-encode muxed files into animegrimoire format
output=$(echo "$file_name" | cut -f 1 -d '.').mp4
echo "$(date): Begin encoding process"

# 2.1: Push Notification while encoding started
telegram-send --format markdown "Encoding Start(BD): *$1*"
_webhook="$webhook_avx"
_title="Encoding Start"
_timestamp="$USER@$HOSTNAME $(date)"
_description="Encoding Start(BD): $1"
discord-msg --webhook-url="$_webhook" --title="$_title" --description "$_description" --color "0xff0004" --footer="$_timestamp"

# 2.2 Initiate encoding
/usr/local/bin/HandBrakeCLI --preset-import-file "$preset" -Z "x264_Animegrimoire" -i "$file_name" -o "$output"

# 3: Embed valid CRC32 tag on output file
echo "$(date): Embedding CRC32 Hash"
/usr/bin/rhash --embed-crc --embed-crc-delimiter='' "$output"

##Clean up
echo "$(date): Cleaning up"
rm -v ./*.*tf ./*.*TF
rm -v "mod_sub.tmp"
rm -v "$file_name_sub.mkv"
rm -v "$file_name"
rm -v "$subtitle"

# Move finished files
echo "$(date): Moving finished files"
for files in \[animegrimoire\]\ *.mp4; do rclone copy "$files" "$finished_folder_rclone"; done
for files in \[animegrimoire\]\ *.mp4; do scp -v "$files" "$finished_folder_remote"; done
for files in \[animegrimoire\]\ *.mp4; do mvg -vg "$files" "$finished_folder_local"; done

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
