#!/bin/bash
readonly l="mp4togdrive_$(date +%d%m%H%M).log"
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>$l 2>&1

mp4_dir=
dest_dir=
rclone_drive=

# basic queue check
while :
do
  if pgrep -x "rclone" > /dev/null
    then
      echo "Rclone is running, retrying.."
      sleep 400
  else
    echo "Rclone doesn't seems running, sync encoded mp4(s) to google drive"
    watch -n 3600 rclone -vv sync --delete-after --delete-excluded --no-update-modtime --transfers=1 --checkers=1 --drive-chunk-size=1M $mp4_dir $rclone_drive:$dest_dir
    sleep 3600
  fi
done
