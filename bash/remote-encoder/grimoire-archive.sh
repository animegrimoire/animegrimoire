#!/bin/bash

# Load config file
source /home/$USER/.local/config/animegrimoire.conf

locate .mp4 > list.txt

while read file; do
    echo "$(seq -f '%04g' $n)" "$(du -h "$file" | cut -f 1)" "${file##*/}"
    n=$((n+1))
done < list.txt

