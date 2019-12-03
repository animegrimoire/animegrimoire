#!/bin/bash
startl=$(date +%s)
# This is a user-specific script configuration, your machine might unable to use this like default scripts
# usage should be "./animegrimoire.sh 'SOURCE' 'ARGS' ".

# File structure
#|─────────────────────────────────────────────────────────────────────────────────────────|#
#| home/$USER/                                                                             |#
#|       ├── .local/bin/                                                                   |#
#|       │      │    └── animegrimoire.sh                                                  |#
#|       │      │                                                                          |#
#|       │      └──/preset/                                                                |#
#|       │             └──x264_animegrimoire.json                                          |#
#|       |                                                                                 |#
#|       ├── Encodes/                                                                      |#
#|       │      ├── [Ayylmaosub] file that you wanted to encode - 01 [720p].mkv            |#
#|       │      └── [fansub] file that you wanted to encode - 02 [720p][12345678].mkv      |#
#|       │                                                                                 |#
#|       ├── finish_encoded/                                                               |#
#|       └── finish_uploaded/                                                              |#
#|                                                                                         |#
#|/usr/bin/                                                                                |#
#|      ├── ffmpeg                                                                         |#
#|      ├── rename                                                                         |#
#|      ├── rhash                                                                          |#
#|      └── rclone                                                                         |#
#|─────────────────────────────────────────────────────────────────────────────────────────|#

#	Logging functions
readonly l="animegrimoire_enc$(date +%d%m%H%M).log"
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>$l 2>&1

# Make sure HandBrakeCLI isn't running. this is a one core single thread machine
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

# Capture both input and hold it somewhere
input=$1
output="$(echo "$1" | cut -f 1 -d '.').mp4"
subtitle="$(echo "$1" | cut -f 1 -d '.').ass"
fansub="$(echo $1 | cut -d "[" -f2 | cut -d "]" -f1)"
preset="/home/$USER/.local/preset/x264_Animegrimoire.json"

# Extract fonts, install and update cache
ffmpeg -dump_attachment:t "" -i "$1" -y
for fonts in *.*TF *.*tf; do rclone -vv copy $fonts /home/$USER/.fonts; done
fc-cache -f -v

# Remove CRC32 value from input files
if [[ -z "$2" ]]; then
    :
else
  echo "$input" | cut -b 1-$2 > namehold
  mv "$input" "$(cat namehold)".mkv
  input=$(printf "$(cat namehold)".mkv)
  rm -rfv namehold
fi

# Stage 1:	Extract Subtitle from $1(mkv)
/usr/bin/ffmpeg -i "$input" -map 0:s "$subtitle" -y

# Stage 2:	demux $1(mkv), remove original subtitle
/usr/bin/ffmpeg -i "$input" -map 0 -map 0:s -codec copy "$1_tmp.mkv" -y

# Stage 3:	embed watermark to comply animegrimoire's global rule
sed '/Format\: Name/a Style\: Watermark,Cambria,12,&H00FFFFFF,&H000000FF,&H00000000,&H00000000,0,1,0,0,100,100,0,0,1,2,1.2,9,10,10,10,1' "$subtitle" > "modified_sub.tmp1"
sed '/Format\: Layer/a Dialogue\: 0,0:00:00.00,0:00:02.00,Watermark,,0000,0000,0000,,animegrimoire.org' "modified_sub.tmp1" > "$subtitle"

# Stage 4:	send back the modified subtitle into $1(mkv) container
/usr/bin/ffmpeg -i "$1_tmp.mkv" -i "$subtitle" -c:v copy -c:a copy -c:s copy -map 0:0 -map 0:1 -map 1:0 -metadata:s:s:0 language=eng "$1_sub.mkv" -y

# Stage 5:	send subbed $1 to HandBrakeCLI encoder with animegrimoire's preset.
#			Make sure you have compiled fdk_aac version as stated in guide thread.
/usr/local/bin/HandBrakeCLI --preset-import-file $preset -Z "x264_Animegrimoire" -i "$1_sub.mkv" -o "$output"

# Stage 6:	Rename file names and embed CRC32 in end of encoded file (case sensitive).
/usr/bin/rename -v $fansub animegrimoire "$output" > hold.name
/usr/bin/rhash --embed-crc --embed-crc-delimiter='' "$(cat hold.name | cut -d "\`" -f3 | cut -d "'" -f 1)" && rm -v hold.name

# Clean up. 
rm -v *.*tf *.*TF
rm -v *.tmp* ; rm -v *.ass ; rm -v "$1_sub.mkv" ; rm -v "$1_tmp.mkv"
mv -v "$1" ../finish_encoded

# Move output files to syncthing folder
for files in \[animegrimoire\]\ *.mp4; do mv -v "$files" ../finish_uploaded/; done

endl=$(date +%s)
echo "This script was running for $((endl-startl)) seconds."
