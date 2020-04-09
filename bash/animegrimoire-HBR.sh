#!/bin/bash
startl=$(date +%s)
# This is a user-specific script configuration, your machine might unable to use this like default scripts
# usage should be "./animegrimoire.sh 'SOURCE' 'ARGS' ".

# Load config file
source /home/$USER/.local/config/animegrimoire.conf

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
readonly log="animegrimoire_logrc$(date +%d%m%H%M).log"
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>"$log" 2>&1

# Make sure HandBrakeCLI isn't running. this is a one core single thread machine
while :
do
  if pgrep -x "HandBrakeCLI" > /dev/null
    then
      echo "HandBrakeCLI is running, retrying.."
      sleep 600
  else
    echo "HandBrakeCLI process not found, continuing subroutine."
    break
  fi
done

# Capture both input and hold it somewhere
input=$1
output="$(echo "$1" | cut -f 1 -d '.').mp4"
subtitle="$(echo "$1" | cut -f 1 -d '.').ass"
fansub="$(echo "$1" | cut -d "[" -f2 | cut -d "]" -f1)"

# Extract fonts, install and update cache
ffmpeg -dump_attachment:t "" -i "$1" -y
for fonts in *.*TF *.*tf; do rclone -vv copy "$fonts" /home/"$USER"/.fonts; done
fc-cache -f -v

# Remove CRC32 value from input files
if [[ -z "$2" ]]; then
    :
else
  echo "$input" | cut -b 1-"$2" > namehold
  mv "$input" "$(cat namehold)".mkv
  input="$(cat namehold).mkv)"
  rm -rfv namehold
fi

# Stage 0:  Overwrite metadata from file sources
/usr/bin/ffmpeg -i "$input" -map 0:0 -map 0:1 -map 0:2 -c:v copy -c:a copy -c:s:2 copy -metadata:s:a:0 language=jpn -metadata:s:s:0 language=eng "$1_meta.mkv" -y

# Stage 1:	Extract Subtitle from $1_meta(mkv)
/usr/bin/ffmpeg -i "$1_meta.mkv" -map 0:s "$subtitle" -y

# Stage 2:	demux $1(mkv), remove original subtitle
/usr/bin/ffmpeg -i "$1_meta.mkv" -map 0 -map 0:s -codec copy "$1_tmp.mkv" -y

# Stage 3:	embed watermark to comply Grimoire Archive global rule
sed '/Format\: Name/a Style\: Watermark,Worstveld Sling,20,&H00FFFFFF,&H00FFFFFF,&H00FFFFFF,&H00FFFFFF,0,0,0,0,100,100,0,0,1,0,0,9,0,5,0,11' "$subtitle" > "modified_sub.tmp1"
sed '/Format\: Layer/a Dialogue\: 0,0:00:00.00,0:00:30.00,Watermark,,0000,0000,0000,,animegrimoire.moe' "modified_sub.tmp1" > "$subtitle"

# Stage 4:	send back the modified subtitle into $1(mkv) container
/usr/bin/ffmpeg -i "$1_tmp.mkv" -i "$subtitle" -c:v copy -c:a copy -c:s copy -map 0:0 -map 0:1 -map 1:0 -metadata:s:s:0 language=eng "$1_sub.mkv" -y

# Stage 5:	send subbed $1 to HandBrakeCLI encoder with animegrimoire's preset.
#			Make sure you have compiled fdk_aac version as stated in guide thread.
/usr/local/bin/HandBrakeCLI --preset-import-file "$preset" -Z "x264_Animegrimoire_HBR" -i "$1_sub.mkv" -o "$output"

# Stage 6:	Rename file names and embed CRC32 in end of encoded file (case sensitive).
/usr/bin/rename -v "$fansub" animegrimoire "$output" > hold.name
# For future reference in case using wrong version of rename (perl)
#   echo "$output" > hold.old.name
#   sed 's/$fansub/animegrimoire/' hold.old.name > hold.name
#   mv "$output" "$(cat hold.name)"
#   rm -v hold.old.name ; rm -v hold.name
/usr/bin/rhash --embed-crc --embed-crc-delimiter='' "$(cat hold.name | cut -d "\`" -f3 | cut -d "'" -f 1)" && rm -v hold.name

# Clean up.
rm -v ./*.*tf ./*.*TF
rm -v ./*.tmp* ; rm -v ./*.ass ; rm -v "$1_sub.mkv" ; rm -v "$1_tmp.mkv"; rm -v "$1_meta.mkv"
rm -v "$1"

# Move completed files
for files in \[animegrimoire\]\ *.mp4; do echo "$files" > file_result; done
for files in \[animegrimoire\]\ *.mp4; do rclone -v copy "$files" "$finished_folder_rclone"; done
for files in \[animegrimoire\]\ *.mp4; do scp -v "$files" "$finished_folder_remote"; done
for files in \[animegrimoire\]\ *.mp4; do mvg -vg "$files" "$finished_folder_local"; done

## Exit encoding
endl=$(date +%s)
echo "This script was running for $((endl-startl)) seconds."

## Catch all records to write in database
record_filesource="$1"
record_encodetime="$((endl-startl))"
record_fileresult="$(cat file_result)"
# Upload to Siasky
curl -X POST "https://siasky.net/skynet/skyfile" -F "file=@$record_fileresult" > /home/$USER/output.txt
store_url=$(cat /home/$USER/output.txt | jq .skylink | sed  's,","https://siasky.net/,i')
date_now="$(date +%d%m%Y%H%M%S)"

# now make a short url
curl "http://tinyurl.com/api-create.php?url=$(echo $store_url | sed 's,",,i')" > /home/$USER/output.txt
store_url_short=$(cat /home/$USER/output.txt)
rm -v /home/$USER/output.txt

## Standard MySQL setup
# using MariaDB; run '#systemctl start mariadb && mysql_secure_installation' after first install
# then create a database to store records;
# mysql> CREATE DATABASE database_name;
# mysql> CREATE USER 'database_user'@'localhost' IDENTIFIED BY 'user_password';
# mysql> GRANT ALL PRIVILEGES ON database_name.* TO 'database_user'@'localhost';
# now we need to create a table to hold these encoding data
# mysql> use database_name;
# mysql> CREATE TABLE records(
#  -> id INT NOT NULL AUTO_INCREMENT,
#  -> date VARCHAR(20) NOT NULL,
#  -> file_source VARCHAR(255) NOT NULL,
#  -> file_result VARCHAR(255) NOT NULL,
#  -> encode_time VARCHAR(10) NOT NULL,
#  -> long_url VARCHAR(100) NOT NULL,
#  -> short_url VARCHAR(40) NOT NULL,
#  -> notes VARCHAR(100),
#  -> PRIMARY KEY ( id )
#  -> );

# Write a record
mysql --host=$database_host --user=$database_user --password=$database_passwd --database=$database_encoder << EOF
INSERT INTO records (id, date, file_source, file_result, encode_time, long_url, short_url, notes) VALUES (NULL, "$date_now", "$record_filesource", "$record_fileresult", "$record_encodetime", '$store_url', '$store_url_short', "$database_user");
EOF

# Dump record to update download link list
mysql --host=$database_host --user=$database_user --password=$database_passwd --database=$database_encoder -e "SELECT id, date, file_name, short_url, notes FROM records;" | sed 's/\t/","/g;s/^/"/;s/$/"/;s/\n//g' | sed 's/\"\"/\"/g' > /home/$USER/index.csv

# Update the list
curl --user "$FTP_CREDS" --upload-file /home/$USER/index.csv ftp://"$FTP_DEST":"$FTP_REMOTE_FOLDER"/index.csv
rm -v /home/index.csv

# Push notification to telegram (https://t.me/Animegrimoire)
#telegram_chatid=-1001081862705
#telegram_key="$TELEGRAM_KEY"
#telegram_api="https://api.telegram.org/bot$telegram_key/sendMessage?chat_id=$telegram_chatid"
#telegram_message="[Notice] $USER@$HOSTNAME has successfully re-encode "$1" in $((endl-startl)) seconds."
#curl -X POST "$telegram_api&text='$message'"

# Push notification to Discord using Webhook (https://github.com/ChaoticWeg/discord.sh)
_webhook="$webhook_avx"
_title="[Finished Encoding]"
_timestamp="$USER@$HOSTNAME $(date)"
_description="$USER@$HOSTNAME has successfully re-encode $1 in $((endl-startl)) seconds."
discord-msg --webhook-url="$_webhook" --title="$_title" --description "$_description" --color "0xff0004" --footer="$_timestamp"
