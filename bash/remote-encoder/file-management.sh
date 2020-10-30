#!/bin/bash

# Load config file
source /home/$USER/.local/config/animegrimoire.conf

# Begin a for Loop, open one loop to catch file with '\[animegrimoire\]\ *.mp4' pattern
while :
    # Trap process to make sure there's a valid '\[animegrimoire\]\ *.mp4' file before running but spawn 
    # a different while loop, the first loop should be used for process exit if return code from httpie != zero
    while :
        do
            if [ "$(ls -1 ./*.mp4 2>/dev/null | wc -l )" -gt 0 ]; then
                echo "$(date): \[animegrimoire\]\ *.mp4 Found. Continue"
                break
            else
                echo "$(date): \[animegrimoire\]\ *.mp4 Not Found. retrying.."
                sleep 600
            fi
    done
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
     sleep 60

#   # Before moving files, catch the files and parse it's total length
file_duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$file_name" | cut -f 1 -d .)
#Typical 24minute files will have 1440s in total
if [ $file_duration -gt 900 ]
    then
        echo "$(date): $file_duration is greater than 900s, begin file splitting"
        echo "$(date): Registering New File name"
        echo "$file_name" > hold.name
        sed -i 's/animegrimoire/split/' hold.name
        split=$(<hold.name) && echo "$(date): New split filename is $split" && rm -v hold.name
        ffmpeg -ss 00:14:30 -i "$file_name" -to 00:00:20 -c copy "$split"
    # Now $split has 20s duration of video with copy codec without doing any encoding process
    # then send it using telegram-send to preconfigured groups
        telegram-upload --config $telegram_upload "$split" --forward https://t.me/animegrimoire
        rm -v "$split"
    else
        echo "$(date): $file_duration is less than 900s, do nothing."
fi

# Make one more copy of file using telegram-upload
    telegram-upload --config $telegram_upload "$file_name"
    telegram-upload --config $telegram_upload "$file_name" --forward https://t.me/Animegrimoirechannel

# move files to their respective folder 
        mv -v "$file_name" "$Archive$folder_name"

#   # Now send a report to discord for DDL
        _title_="File Indexed"
        _description_="$file_name Is successfully indexed."
        discord_send
        telegram_send

    # After done sending report, Write it to database
        mysql_write

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
    echo "Indexing (s) finished in $((endl-startl)) seconds."

    # Restart to beginning
    echo "$(date): go to beginning"
done
