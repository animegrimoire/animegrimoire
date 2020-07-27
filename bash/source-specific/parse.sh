#!/bin/bash
startl=$(date +%s)
## Load config file
source /home/$USER/.local/config/animegrimoire.conf

if ! [ -x "$(command -v ffmpeg)" ]; then
  echo 'Error: ffmpeg is not found.' >&2
  exit 1
fi

# Follow the format, "Kaguya-sama Love Is War - 01.ass"
subtitle="$(echo "$1" | cut -f 1 -d '.').ass"

# Subtitle is mostly in 0:2 from english fansub. if you extract the wrong channel,
# change it here
ffmpeg -i "$filename" -map 0:2 -c copy "$subtitle"

## Exit process
endl=$(date +%s)
echo "This script was running for $((endl-startl)) seconds."
