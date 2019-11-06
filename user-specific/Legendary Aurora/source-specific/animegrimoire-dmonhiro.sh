#!/bin/bash
startl=$(date +%s)

# case       : DmonHiro
# type       : BD Releases
# is HBR     : NO
# common note: Files has episode note, has no '[fansub]' tag, has episode name, subtitle is separated
#            : [00] - this:EpisodeName.mkv
#            : [00] - this:EpisodeName.ass
#            : Audio successfuly parsed as 'jp', Subtitle is successfully parsed as 'eng'
#    Scripted by Celestia, for file structure and styles see /animegrimoire.sh.
#
#    USAGE: ./animegrimoire-dmonhiro.sh '[00] - this:EpisodeName.mkv' 'this:New Episode Name'

##Logging functions
readonly l="animegrimoire_dmonhiro_$(date +%d%m%H%M).log"
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>$l 2>&1

##Make sure HandBrakeCLI isn't running. this is a one core single thread machine
while :
do
  if pgrep -x "HandBrakeCLI" > /dev/null
    then
      echo "HandBrakeCLI is running, retrying.."
      sleep 60
  else
    echo "HandBrakeCLI process not found, continuing subroutine."
    break
  fi
done

##init variable
in_files=$1
new_title=$2
subtitle=$(echo "$1" | cut -f 1 -d '.').ass
preset="/home/aurora/.local/preset/x264_Animegrimoire.json"

##Staging input Files
# 1: Embed Watermark
sed '/Format\: Name/a Style\: Watermark,Cambria,12,&H00FFFFFF,&H000000FF,&H00000000,&H00000000,0,1,0,0,100,100,0,0,1,2,1.2,9,10,10,10,1' "$subtitle" > "mod_sub.tmp"
sed '/Format\: Layer/a Dialogue\: 0,0:00:00.00,0:00:02.00,Watermark,,0000,0000,0000,,animegrimoire.org' "mod_sub.tmp" > "$subtitle"
# 2: Register a new name
file_name="[animegrimoire] "$2" - $(echo "$1" | cut -f 1 -d ' ') [BD720p].mkv"
/usr/bin/mv -v "$1" "$file_name"
# 3: Extract fonts, install and update cache
ffmpeg -dump_attachment:t "" -i "$file_name" -y
for fonts in *.*TF *.*tf; do rclone -vv copy $fonts /home/aurora/.fonts; done
fc-cache -f -v

##Staging HandBrakeCLI
# 1: Mux modified subtitle to new episode name
/usr/bin/ffmpeg -i "$file_name" -i "$subtitle" -c:v copy -c:a copy -c:s copy -map 0:0 -map 0:1 -map 1:0 -metadata:s:s:0 language=eng "$file_name_sub.mkv" -y
# 2: re-encode muxed files into animegrimoire format
output=$(echo "$file_name" | cut -f 1 -d '.').mp4
/usr/local/bin/HandBrakeCLI --preset-import-file $preset -Z "x264_Animegrimoire" -i "$file_name_sub.mkv" -o "$output"
# 3: Embed valid CRC32 tag on output file
/usr/bin/rhash --embed-crc --embed-crc-delimiter='' "$output"

##Clean up 
rm -v *.*tf *.*TF
rm -v "mod_sub.tmp"
rm -v "$file_name_sub.mkv"
mv -v "$file_name" ../finish_encoded
mv -v "$subtitle" ../finish_encoded

##Upload output files to onedrive using rclone
rclone_config="/home/aurora/.config/rclone/rclone.conf"
for file in [animegrimoire*.mp4; do rclone -vv --config "$rclone_config" copy "$file" transport:Transport && mv -v "$file" ../finish_uploaded/; done 

##Exit
endl=$(date +%s)
echo "This script was running for $((endl-startl)) seconds."