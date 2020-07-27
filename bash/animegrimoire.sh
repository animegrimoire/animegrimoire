#!/bin/bash
startl=$(date +%s)
# This is a user-specific script configuration, your machine might unable to use this like default scripts

# Load config file
source /home/$USER/.local/config/animegrimoire.conf

#	Logging functions
readonly log="animegrimoire_logrc$(date +%d%m%H%M).log"
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>"$log" 2>&1

# make sure there aren't any other HandBrakeCLI process running
	handbrake_test

# make sure sshfs is running
	sshfs_test

# Capture both input and hold it somewhere
echo "$1" > filename.txt
sed -i 's/,//g' filename.txt
sed -i 's/`//g' filename.txt
sed -i 's/\r$//g' filename.txt
input="$(tail filename.txt)"
output="$(echo "$input" | cut -f 1 -d '.').mp4"
subtitle="$(echo "$input" | cut -f 1 -d '.').ass"
fansub="$(echo "$input" | cut -d "[" -f2 | cut -d "]" -f1)"
echo "Input is: $input"
echo "Output is: $output"
echo "Subtitle is: $subtitle"
echo "fansub is: $fansub"
mv -v "$1" "$input"
rm -v filename.txt

# Extract fonts, install and update cache
echo "$(date): Extract fonts, install and update cache"
ffmpeg -dump_attachment:t "" -i "$input" -y
for fonts in *.*TF *.*tf; do rclone copy "$fonts" /home/"$USER"/.fonts; done
fc-cache -f

# Stage 0:  Overwrite metadata from file sources
echo "$(date): Overwriting metadata from file source"
/usr/bin/ffmpeg -i "$input" -map 0:0 -map 0:1 -map 0:2 -c:v copy -c:a copy -c:s:2 copy -metadata:s:a:0 language=jpn -metadata:s:s:0 language=eng "$input_meta.mkv" -y

# Stage 1:	Extract Subtitle from $input_meta(mkv)
echo "$(date): Extracting subtitle"
/usr/bin/ffmpeg -i "$input_meta.mkv" -map 0:s "$subtitle" -y

# Stage 2:	demux $input(mkv), remove original subtitle
echo "$(date): Remove old subtitle from file source"
/usr/bin/ffmpeg -i "$input_meta.mkv" -map 0 -map 0:s -codec copy "$input_tmp.mkv" -y

# Stage 3:	embed watermark to comply Grimoire Archive global rule
echo "$(date): embedding watermark"
sed '/Format\: Name/a Style\: Watermark,Worstveld Sling,20,&H00FFFFFF,&H00FFFFFF,&H00FFFFFF,&H00FFFFFF,0,0,0,0,100,100,0,0,1,0,0,9,0,5,0,11' "$subtitle" > "modified_sub.tmp1"
sed '/Format\: Layer/a Dialogue\: 0,0:00:00.00,0:00:30.00,Watermark,,0000,0000,0000,,animegrimoire.moe' "modified_sub.tmp1" > "$subtitle"
echo "$(date): Testing watermark"
grep Worstveld < "$subtitle"
grep animegrimoire < "$subtitle"

# Stage 4:	send back the modified subtitle into $input(mkv) container
echo "$(date): Embedding new subtitle with watermark"
/usr/bin/ffmpeg -i "$input_tmp.mkv" -i "$subtitle" -c:v copy -c:a copy -c:s copy -map 0:0 -map 0:1 -map 1:0 -metadata:s:s:0 language=eng "$input_sub.mkv" -y

# Stage 5:	send subbed $input to HandBrakeCLI encoder with animegrimoire's preset.
echo "$(date): Begin encoding process"
/usr/local/bin/HandBrakeCLI --preset-import-file "$preset" -Z "x264_Animegrimoire" -i "$input_sub.mkv" -o "$output"

# Stage 6:	Rename file names and embed CRC32 in end of encoded file (case sensitive). Requires perl-rename
/usr/bin/rename -v "$fansub" animegrimoire "$output" > hold.name
# For future reference in case non-perl rename
#   echo "$output" > hold.old.name
#   sed 's/$fansub/animegrimoire/' hold.old.name > hold.name
#   mv "$output" "$(cat hold.name)"
#   rm -v hold.old.name
echo "$(date): Embedding CRC32 Hash"
/usr/bin/rhash --embed-crc --embed-crc-delimiter='' "$(cat hold.name | cut -d "\`" -f3 | cut -d "'" -f 1)" && rm -v hold.name

# Clean up.
echo "$(date): Cleaning up"
rm -v ./*.*tf ./*.*TF
rm -v ./*.tmp* ; rm -v ./*.ass ; rm -v "$input_sub.mkv" ; rm -v "$input_tmp.mkv"; rm -v "$input_meta.mkv"
rm -v "$input"

# make sure sshfs is running
	sshfs_test

# Move completed files
echo "$(date): Moving finished files"
for files in \[animegrimoire\]\ *.mp4; do rclone -v copy "$files" "$finished_folder_rclone"; done
for files in \[animegrimoire\]\ *.mp4; do scp -v "$files" "$finished_folder_remote"; done
for files in \[animegrimoire\]\ *.mp4; do mvg -vg "$files" "$finished_folder_local"; done

## Exit encoding
endl=$(date +%s)
echo "This script was running for $((endl-startl)) seconds."

# Push notification to Discord using Webhook (https://github.com/ChaoticWeg/discord.sh)
_webhook="$webhook_avx"
_title="[Finished Encoding]"
_timestamp="$USER@$HOSTNAME $(date)"
_description="$USER@$HOSTNAME has successfully re-encode $1 in $((endl-startl)) seconds."
discord-msg --webhook-url="$_webhook" --title="$_title" --description "$_description" --color "0xff0004" --footer="$_timestamp"
