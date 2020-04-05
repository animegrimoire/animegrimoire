#!/bin/bash
startl=$(date +%s)
# Load config file
source /home/$USER/.local/config/animegrimoire.conf
# case       : DmonHiro
# type       : BD Releases
# is HBR     : NO
# common note: Files has episode note, has no '[fansub]' tag, has episode name, subtitle is separated
#            : [00] - this:EpisodeName.mkv
#            : [00] - this:EpisodeName.ass
#            : Audio successfuly parsed as 'jp', Subtitle is successfully parsed as 'eng'
#    Scripted by Celestia, for file structure and styles see /animegrimoire.sh.
#
#    USAGE: ./dmonhiro.sh '[00] - this:EpisodeName.mkv' 'this:New Episode Name'

##Logging functions
readonly l="animegrimoire_dmonhiro_$(date +%d%m%H%M).log"
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>"$l" 2>&1

##Make sure HandBrakeCLI isn't running. this is a one core single thread machine
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

##init variable
subtitle=$(echo "$1" | cut -f 1 -d '.').ass

##Staging input Files
# 1: Embed Watermark
sed '/Format\: Name/a Style\: Watermark,Cambria,12,&H00FFFFFF,&H000000FF,&H00000000,&H00000000,0,1,0,0,100,100,0,0,1,2,1.2,9,10,10,10,1' "$subtitle" > "mod_sub.tmp"
sed '/Format\: Layer/a Dialogue\: 0,0:00:00.00,0:00:30.00,Watermark,,0000,0000,0000,,animegrimoire.moe' "mod_sub.tmp" > "$subtitle"
# 2: Register a new name
file_name="[animegrimoire] $2 - $(echo "$1" | cut -f 1 -d ' ') [BD720p].mkv"
/usr/bin/mv -v "$1" "$file_name"
# 3: Extract fonts, install and update cache
ffmpeg -dump_attachment:t "" -i "$file_name" -y
for fonts in *.*TF *.*tf; do rclone -vv copy "$fonts" /home/"$USER"/.fonts; done
fc-cache -f -v

##Staging HandBrakeCLI
# 1: Mux modified subtitle to new episode name
/usr/bin/ffmpeg -i "$file_name" -i "$subtitle" -c:v copy -c:a copy -c:s copy -map 0:0 -map 0:1 -map 1:0 -metadata:s:a:0 language=jpn -metadata:s:s:0 language=eng "$file_name_sub.mkv" -y
# 2: re-encode muxed files into animegrimoire format
output=$(echo "$file_name" | cut -f 1 -d '.').mp4
/usr/local/bin/HandBrakeCLI --preset-import-file "$preset" -Z "x264_Animegrimoire" -i "$file_name_sub.mkv" -o "$output"
# 3: Embed valid CRC32 tag on output file
/usr/bin/rhash --embed-crc --embed-crc-delimiter='' "$output"

##Clean up
rm -v ./*.*tf ./*.*TF
rm -v "mod_sub.tmp"
rm -v "$file_name_sub.mkv"
rm -v "$file_name"
rm -v "$subtitle"

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
mysql --user=$database_user --password=$database_passwd $database_identifier << EOF
INSERT INTO records (id, date, file_source, file_result, encode_time, long_url, short_url, notes) VALUES (NULL, "$date_now", "$record_filesource", "$record_fileresult", "$record_encodetime", '$store_url', '$store_url_short', "$database_user");
EOF

# Dump record to update download link list
mysql --user=$database_user --password=$database_passwd --database=$database_identifier -e "SELECT id, date, file_name, short_url, notes FROM records;" | sed 's/\t/","/g;s/^/"/;s/$/"/;s/\n//g' | sed 's/\"\"/\"/g' > /home/$USER/index.csv

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
_title="[Finished Encoding]"
_timestamp="$USER@$HOSTNAME $(date)"
_description="$USER@$HOSTNAME has successfully re-encode $1 in $((endl-startl)) seconds."
discord-msg --webhook-url="$webhook_avx" --title="$_title" --description "$_description" --color "0xff0004" --footer="$_timestamp"
