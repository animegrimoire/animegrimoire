#!/bin/bash
# Load config file
source /home/$USER/.local/config/animegrimoire.conf

for files in "$1"
    do
        archive_name=$(echo "$1"| cut -f 1 -d '.' | sed 's/\[animegrimoire\]\ //g').7z
        /usr/bin/7z -mx=0 -mhe=on -p$global_pwd -v35m a "./$archive_name" "./$1"
        telegram-send --pre "$1"
        rm -v "$1"
    done
for splitfiles in *.7z.0*
    do
        echo Sending "./$splitfiles"
        telegram-send --file "./$splitfiles"
        rm -v "./$splitfiles"
    done