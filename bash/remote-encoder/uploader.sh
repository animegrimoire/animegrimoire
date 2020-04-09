#!/bin/bash
startl=$(date +%s)
# Load config file
source /home/$USER/.local/config/animegrimoire.conf

# Try catch folder name and automatically generate new name 
_folder=$(echo "$1" | sed 's,/,,i')
_name=$(echo "$1" | sed 's,/,,i' | sed 's/\s\+//g' | sed 's/$/.7z/')
echo Folder name is: "$_folder"
echo New generated name is: "$_name"

# Begin packing to 7z archive
7z -mx=0 -mhe=on a -p"animegrimoire!" "$_name" "$1" 2> /dev/null
if [ $? -eq 0 ]
then
  echo -e "$_name is successfully created\n"
  echo -e "$_name size is $(du -sch "$_name" | head -n1 | head -c5)\n\n"
  _size=$(du -sch "$_name" | head -n1 | head -c5)
else
  echo -e "Failed to create $_name\n" >&2
  exit
fi
echo -e "now staging "$_name" to "$database_manual_dest"\n"
read -p "Continue (y/n)?" answer
case "$answer" in
  y|Y ) ;;
  n|N ) exit;;
  * ) exit;;
esac

# Upload
rclone -P --fast-list copy "$_name" "$database_manual_dest" 2> /dev/null
if [ $? -eq 0 ]
then
  echo -e "Uploading $_name done\n"
  rm -v "$_name"
else
  echo -e "Failed to upload $_name\n" >&2
  exit
fi

endl=$(date +%s)
echo "This script was running for $((endl-startl)) seconds."

# Store Records
date_now="$(date +%d%m%Y%H%M%S)"
mysql --host=$database_host --user=$database_user --password=$database_passwd --database=$database_manual << EOF
INSERT INTO records (id, date, title, size, archive, note) VALUES (NULL, "$date_now", "$_folder", "$_size", '$_file', "$database3_user");
EOF