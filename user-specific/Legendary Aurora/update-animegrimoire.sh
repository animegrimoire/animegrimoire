#!/bin/bash
clear
cd /home/aurora/.local/bin
rm -v animegrimoire
curl -o animegrimoire https://gitlab.com/initramfs-0/animegrimoire/raw/master/user-specific/Legendary%20Aurora/animegrimoire.sh
chmod u+x animegrimoire
ls -l
date