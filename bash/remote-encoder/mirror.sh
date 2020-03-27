#!/bin/bash
##                                                                 ##
# Simple file mirror to temp host that allow curl (i.e pomf clones) #
# USAGE: $mirror.sh "SOURCE_FILE" "ARCHIVE_NAME"                    #
# Those site are NOT personal CDN. Use their generousity wisely     #
##                                                                 ##

# Online status check, abort if fails
ping -q -w 1 -c 1 10.8.0.1 > /dev/null && echo "$(date +%d%m%y): Gateway is online (OK)" || exit
ping -q -w 1 -c 1 anonfile.com > /dev/null && echo "$(date +%d%m%y): anonfile is online (OK)" || exit
ping -q -w 1 -c 1 siasky.net > /dev/null && echo "$(date +%d%m%y): siasky is online (OK)" || exit

# Archive source files
7z -mx=0 -mhe=on a -p"animegrimoire!" "$2.7z" "$1"

database_user=
database_passwd=
database_identifier=

# Upload to Anonfiles
curl -i -F "file=@$2.7z" https://api.anonfile.com/upload > ~/output.txt
store_filename="$1"
store_url=$(cat ~/output.txt | grep short | grep https | jq . | jq .data.file.url.short)
date_now="$(date)"
#Insert to database
echo storing URL "$store_url"
mysql --user=$database_user --password=$database_passwd $database_identifier << EOF
INSERT INTO records (id, date, site, filename, link, note) VALUES (NULL, "$date_now", "Anonfile.com", "$store_filename", '$store_url', "$database_user");
EOF

# Upload to Skynet
curl -X POST "https://siasky.net/skynet/skyfile" -F "file=@$2.7z" > ~/output.txt
store_filename="$1"
store_url=$(cat ~/output.txt | jq .skylink | sed  's,","https://siasky.net/,i')
date_now="$(date)"

echo storing URL "$store_url"
#Insert to database
mysql --user=$database_user --password=$database_passwd $database_identifier << EOF
INSERT INTO records (id, date, site, filename, link, note) VALUES (NULL, "$date_now", "Siasky.net", "$store_filename", '$store_url', "$database_user");
EOF

rm -v $2.7z
rm -v ~/output.txt