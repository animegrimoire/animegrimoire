#!/bin/bash
PORT=""
GATEWAY=""
REMOTE_USERNAME=""

sshfs -p"$PORT" "$REMOTE_USERNAME"@"$GATEWAY":/home/"$REMOTE_USERNAME"/sshfsd /home/"$USER"/Animegrimoire/sshfs
