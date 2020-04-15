#!/bin/bash

# Load config file
source /home/$USER/.local/config/animegrimoire.conf

# Define Functions
function discord_send {
    _timestamp_="$USER@$HOSTNAME $(date)"
    discord-msg --webhook-url="$webhook_nivida" --title="$_title_" --description="$_description_" --color="$gween" --footer="$_timestamp_"
}
function telegram_send {
    telegram-send --format markdown "*$file_name* : $short_url"
}
function mysql_write {
date_now="$(date +%d%m%Y%H%M%S)"
mysql --host=$database_host --user=$database_user --password=$database_passwd --database=$database_encoder << EOF
INSERT INTO Records (id, date, file_source, encode_time, long_url, file_result, short_url, notes) VALUES (NULL, "$date_now", 0, 0, 0, "$file_name", '$short_url', "$database_user");
EOF
}
function mysql_dump {
    mysql --host=$database_host --user=$database_user --password=$database_passwd --database=$database_encoder -e "SELECT id, date, file_result, short_url, notes FROM Records;" | sed 's/\t/","/g;s/^/"/;s/$/"/;s/\n//g' | sed 's/\"\"/\"/g' > ./index.csv
}
function update_tree {
    curl --user "FTP_USER" --upload-file ./tree.html ftp://"FTP_DEST"/tree.html
}
function tree_animegrimoire {
    curl --user "FTP_USER" --upload-file ./index.csv ftp://"FTP_DEST"/index.csv
}

# Begin a for Loop, open one loop to catch file with '\[animegrimoire\]\ *.mp4' pattern
while :
    do
    startl=$(date +%s)
    for files in \[animegrimoire\]\ *.mp4
        do
        file_name=$(echo "$files")
        file_size=$(du -sch "$files" | grep total | cut -d't' -f1)
        echo Processing file "$file_name" with size "$file_size"
        
        # Now create a folder based on it's file names
        folder_name=$(echo "$file_name" | cut -d ' ' -f2,3 | sed 's/-//g' | sed -E 's/ *$//')
        echo Folder name should be in \"$folder_name\"

        # Now check if that folder is exist or not
        if [ ! -d "$Archive/$folder_name" ]; then
            echo "$Archive$folder_name"\: Not exist\!
            echo Creating "$Archive$folder_name"
            mkdir -p "$Archive$folder_name"
        else
            echo "$Archive$folder_name"\: Is exist\!
        fi

    # Each folder is exist, now begin uploading those files and catch the error code
    sleep 300
    if http --timeout=60 --check-status --ignore-stdin -f POST https://api.anonfile.com/upload "file@$file_name" 2>&1 | tee ./output.json; then
        echo 'Upload OK!, Parsing ./output.json'
        short_url=$(cat ./output.json | jq . | jq .data.file.url.short | sed 's/"//g')
        echo "Short URL is $short_url"

    # Now send a report to discord for DDL
        _title_="File Uploaded"
        _description_="$file_name $short_url"
        discord_send
        telegram_send

    # After done sending report, Write it to database
        mysql_write

    # Database Written, now move files to their respective folder
        mv -v "$file_name" "$Archive$folder_name"
    else
        echo "Upload error with code\: $?"
        break
    fi
    done
    
    # Print File Tree in end of script
    tree --nolinks -shH "$Archive" > ./tree.html 

    # Then update remote Tree
    update_tree

    # Once Tree is updated, dump sql value
    mysql_dump

    # Then upload tree.animegrimoire index
    tree_animegrimoire

    # Cleaning up
    rm -v ./index.csv
    rm -v ./tree.html
    rm -v ./output.json

    # Cycle end, wait before restarting routine
    endl=$(date +%s)
    echo "Uploading file (s) finished in $((endl-startl)) seconds."
    sleep 14400

    # After period of time is done, restart to beginning
    echo "$(date): go to beginning"
done