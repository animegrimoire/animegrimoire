#!/bin/bash
startl=$(date +%s)
# This is a user-specific script configuration, your machine might unable to use this like default scripts
# Prototype of ripping script. make sure youtube-dl run using python3

# Load config file
source /home/$USER/.local/config/animegrimoire.conf

# Download File with it's Subtitle
youtube-dl --config-location ~/.local/config/youtube-dl.config -i "$1" 

# Store both File name value and subtitle value
youtube-dl --config-location ~/.local/config/youtube-dl.config -i "$1" --get-filename -o "[animegrimoire] %(series)s - %(episode_number)s [%(height)sp].mkv" > filename.tmp
youtube-dl --config-location ~/.local/config/youtube-dl.config -i "$1" --get-filename -o "[animegrimoire] %(series)s - %(episode_number)s [%(height)sp].mkv.enUS.ass" > subname.tmp

# Register new file name value
file="$(<./filename.tmp)"
sub="$(<./subname.tmp)"
muxed="$(<./silename.tmp)_muxed.mkv"

# mux it to one file, rewrite the metadata.
ffmpeg -i "$file" -i "$sub" -c:v copy -c:a copy -c:s copy -map 0:0 -map 0:1 -map 1:0 -metadata:s:a:0 language=jpn -metadata:s:s:0 language=eng "$muxed"

# Done
rm ./Filename.tmp
rm ./Subname.tmp

## Exit ripping
endl=$(date +%s)
echo "This script was running for $((endl-startl)) seconds."
