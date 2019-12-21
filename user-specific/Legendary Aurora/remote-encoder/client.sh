#!/bin/bash
unset HISTFILE
#	Logging functions
readonly l="clientd_ecdr$(date +%d%m%H%M).log"
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>$l 2>&1

## This script is purposed to reduce user-interaction during automated encoding
## forked from animegrimoire.sh and modified with folder watcher and automatically
## report encoded files using discord webhook.
## Tested in Fedora 31 and CentOS 8. not recommended to run in debian-flavor as this script
## is not POSIX compliant.
##
## We will exclusively using Syncthing as file transport. if there's a donator that mind using it, 
## remove 'pull-filter ignore redirect-gateway' inside openvpn configuration so every traffic is 
## tunneled inside OpenVPN.
##
## Important: there are main folder that used in whole encoding process
## 1. /home/$USER/syncthing        : The main syncthing folder where the *.mkv source files arrive
## 2. /home/$USER/encodes          : The main parent folder where re-encoding process occur
## 3. /home/$USER/encodes/encoded  : Folder that hold encoded (*.mkv) files
## 4. /home/$USER/encodes/finished : Folder that hold ([animegrimoire] Title - 00 [720p][00000000].mp4)
##
## For now we only agreed that source files from [HorribleSubs] are automated. any other sub must be
## validated manually to make sure encoded files are perfect to avoid wasting resources

## Let's get started
# Stage 0: set any variable that will be used
source=/home/$USER/syncthing/
encode_folder=/home/$USER/encodes

# Stage 1: if there are any [HorribleSubs] *.mkv file exist, copy it to encodes folder
if [ -f $source\[HorribleSubs\]\ *.mkv ]; then
    cp -v $source\[HorribleSubs\]\ *.mkv $encode_folder
else 
    echo "$(date) $source\[HorribleSubs\]\ *.mkv does not exist"
fi
# Stage 2: if there are mkv files copied, do whole animegrimoire.sh encoding 
if [ -f "$encode_folder/\[HorribleSubs\]\ *.mkv" ]; then
    echo "$encode_folder/\[HorribleSubs\]\ *.mkv exist!"
    for source_file in $encode_folder/\[HorribleSubs\]\ *.mkv; do animegrimoire.sh "$source_file"; done
else 
    echo "$(date) $encode_folder/\[HorribleSubs\]\ *.mkv does not exist"
fi
