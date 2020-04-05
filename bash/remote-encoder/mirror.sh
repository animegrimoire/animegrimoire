#!/bin/bash
##                                                                 ##
# Simple file mirror to temp host that allow curl (i.e pomf clones) #
# USAGE: $mirror.sh "SOURCE_FILE" "ARCHIVE_NAME"                    #
# Those site are NOT personal CDN. Use their generousity wisely     #
##                                                                 ##

# Load config file
source /home/$USER/.local/config/animegrimoire.conf

# Online status check, abort if fails
ping -q -w 1 -c 1 10.8.0.1 > /dev/null && echo "$(date +%d%m%y): Gateway is online (OK)" || exit
ping -q -w 1 -c 1 anonfile.com > /dev/null && echo "$(date +%d%m%y): anonfile is online (OK)" || exit
ping -q -w 1 -c 1 siasky.net > /dev/null && echo "$(date +%d%m%y): siasky is online (OK)" || exit

# Archive source files
7z -mx=0 -mhe=on a -p"animegrimoire!" "$2.7z" "$1"

# Upload to Anonfiles
curl -i -F "file=@$2.7z" https://api.anonfile.com/upload > /home/$USER/output.txt
store_filename="$1"
store_url=$(cat ~/output.txt | grep short | grep https | jq . | jq .data.file.url.short)
date_now="$(date +%d%m%Y%H%M%S)"
#Insert to database
echo storing URL "$store_url"
mysql --user=$database2_user --password=$database2_passwd $database2_identifier << EOF
INSERT INTO records (id, date, site, filename, link, note) VALUES (NULL, "$date_now", "Anonfile.com", "$store_filename", '$store_url', "$database_user");
EOF

# Upload to Skynet
curl -X POST "https://siasky.net/skynet/skyfile" -F "file=@$2.7z" > /home/$USER/output.txt
store_filename="$1"
store_url=$(cat ~/output.txt | jq .skylink | sed  's,","https://siasky.net/,i')
date_now="$(date +%d%m%Y%H%M%S)"

echo storing URL "$store_url"
#Insert to database
mysql --user=$database2_user --password=$database2_passwd $database2_identifier << EOF
INSERT INTO records (id, date, site, filename, link, note) VALUES (NULL, "$date_now", "Siasky.net", "$store_filename", '$store_url', "$database_user");
EOF

rm -v $2.7z
rm -v /home/$USER/output.txt