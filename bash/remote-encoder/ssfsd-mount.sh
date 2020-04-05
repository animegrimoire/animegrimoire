#!/bin/bash
# Load config file
source /home/$USER/.local/config/animegrimoire.conf

sshfs -p"$PORT" "$REMOTE_USERNAME"@"$GATEWAY":/home/"$REMOTE_USERNAME"/sshfsd /home/"$USER"/Animegrimoire/sshfs
