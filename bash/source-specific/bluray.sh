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

##Staging input Files
# 1: Embed Watermark
#echo "$(date): embedding watermark"
#sed '/Format\: Name/a Style\: Watermark,Worstveld Sling,20,&H00FFFFFF,&H00FFFFFF,&H00FFFFFF,&H00FFFFFF,0,0,0,0,100,100,0,0,1,0,0,9,0,5,0,11' "$subtitle" > "mod_sub.tmp"
#sed '/Format\: Layer/a Dialogue\: 0,0:00:00.00,0:00:30.00,Watermark,,0000,0000,0000,,animegrimoire.moe' "mod_sub.tmp" > "$subtitle"
echo "$(date): Testing watermark"
grep Worstveld < "$subtitle"
grep animegrimoire < "$subtitle"

# 2: Register a new name
echo "$(date): Registering a new name"
file_name="[animegrimoire] $2 - $(echo "$1" | cut -f "$3" -d " " | cut -f 1 -d ".") [BD720p].mkv"
/usr/bin/mv -v "$1" "$file_name"
echo "$(date): New name is $file_name"

# 3: Extract fonts, install and update cache
#ffmpeg -dump_attachment:t "" -i "$file_name" -y
#for fonts in *.*TF *.*tf; do rclone copy "$fonts" /home/"$USER"/.fonts; done
mv -v $remote_fonts/*.* "/home/$USER/.fonts/"
fc-cache -f

##Staging HandBrakeCLI
# 1: Mux modified subtitle to new episode name
#echo "$(date): Muxing new subtitle"
#/usr/bin/ffmpeg -i "$file_name" -i "$subtitle" -c:v copy -c:a copy -c:s copy -map 0:0 -map 0:1 -map 1:0 -metadata:s:a:0 language=jpn -metadata:s:s:0 language=eng "$file_name_sub.mkv" -y
# 2: re-encode muxed files into animegrimoire format
output=$(echo "$file_name" | cut -f 1 -d '.').mp4
echo "$(date): Begin encoding process"
/usr/local/bin/HandBrakeCLI --preset-import-file "$preset" -Z "x264_Animegrimoire" -i "$file_name.mkv" -o "$output"
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
for files in \[animegrimoire\]\ *.mp4; do rclone -v copy "$files" "$finished_folder_rclone"; done
for files in \[animegrimoire\]\ *.mp4; do scp -v "$files" "$finished_folder_remote"; done
for files in \[animegrimoire\]\ *.mp4; do mvg -vg "$files" "$finished_folder_local"; done

## Exit encoding
endl=$(date +%s)
echo "This script was running for $((endl-startl)) seconds."

# Push notification to Discord using Webhook (https://github.com/ChaoticWeg/discord.sh)
_title="[Finished Encoding]"
_timestamp="$USER@$HOSTNAME $(date)"
_description="$USER@$HOSTNAME has successfully re-encode $1 in $((endl-startl)) seconds."
discord-msg --webhook-url="$webhook_avx" --title="$_title" --description "$_description" --color "0xff0004" --footer="$_timestamp"
