#!/bin/bash
##                                                                 ##
# Simple file mirror to temp host that allow curl (i.e pomf clones) #
# USAGE: $mirror.sh "SOURCE_FILE" "ARCHIVE_NAME"                    #
# Those site are NOT personal CDN. Use their generousity wisely     #
##                                                                 ##

# Online status check, abort if fails
ping -q -w 1 -c 1 10.8.0.1 > /dev/null && echo "$(date +%d%m%y): Gateway is online (OK)" || exit
ping -q -w 1 -c 1 anonfile.com > /dev/null && echo "$(date +%d%m%y): anonfile is online (OK)" || exit
ping -q -w 1 -c 1 catbox.moe > /dev/null && echo "$(date +%d%m%y): catbox is online (OK)" || exit
ping -q -w 1 -c 1 uguu.se > /dev/null && echo "$(date +%d%m%y): uguu is online (OK)" || exit

# Archive source files
7z -mx=0 -mhe=on a -p"animegrimoire!" "$2.7z" "$1"

# Upload it
USER_KEY="$(cat ~/.user_key)"
curl -i -F "file=@$2.7z" https://api.anonfile.com/upload
curl -i -F name="$2.7z" -F file=@"$2.7z" https://uguu.se/api.php?d=upload-tool
curl -i -F "reqtype=fileupload" -F "userhash=$USER_KEY" -F "fileToUpload=@$2.7z" https://catbox.moe/user/api.php
