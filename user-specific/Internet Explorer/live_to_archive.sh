#!/bin/bash
readonly l="livetoarchive_$(date +%d%m%H%M).log"
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>$l 2>&1

rclone_drive_src=
remote_src_folder=
rclone_drive_dest=
remote_dest_folder=

# basic queue check
while :
do
  if pgrep -x "rclone" > /dev/null
    then
      echo "Rclone is running, retrying.."
      sleep 600
  else
    echo "Rclone doesn't seems running, sync live drive to archive drive"
    watch -n 3600 rclone -vv sync --delete-after --delete-excluded --no-update-modtime --transfers=1 --checkers=5 --drive-chunk-size=1M $rclone_drive_src:$remote_src_folder $rclone_drive_dest:$remote_dest_folder
    sleep 12000
  fi
done
