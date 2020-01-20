#!/bin/bash
clear
branch=$(cat ~/.animegrimoire_branch)

startl=$(date +%s)
ping -q -w 1 -c 1 10.8.0.1 > /dev/null && echo "$(date +%d%m%y): Gateway online, starting update." || exit

# Stage 0: Backup everything just in case
cd ~ || exit
tar -cvf backup.tar ~/.local/bin
tar -uvf backup.tar ~/.local/preset

# Stage 1: pull global preset
    cd ~/.local/preset || exit
    rm -rfv ./*.json
    curl -o x264_Animegrimoire.json https://gitlab.com/initramfs-0/animegrimoire/raw/"$branch"/preset/x264_animegrimoire.json
    curl -o x264_Animegrimoire_HBR.json https://gitlab.com/initramfs-0/animegrimoire/raw/"$branch"/preset/x264_animegrimoire_HBR.json

# Stage 2: pull precompiled binary (if any).
    cd ~/.local/bin || exit
    rm -rfv mvg
    curl -o mvg https://gitlab.com/initramfs-0/animegrimoire/raw/"$branch"/user-specific/Legendary%20Aurora/precompiled-binary/mvg
    chmod u+x mvg
    rm -rfv discord-msg
    curl -o discord-msg https://raw.githubusercontent.com/ChaoticWeg/discord.sh/master/discord.sh
    chmod u+x discord-msg
    cd ~/.fonts || exit
    rm -rfv cambriai.ttf
    rm -rfv OpenSans-Semibold.ttf
    curl -o cambriai.ttf https://gitlab.com/initramfs-0/animegrimoire/raw/"$branch"/user-specific/Legendary%20Aurora/precompiled-binary/cambriai.ttf
    curl -o OpenSans-Semibold.ttf https://gitlab.com/initramfs-0/animegrimoire/raw/"$branch"/user-specific/Legendary%20Aurora/precompiled-binary/OpenSans-Semibold.ttf

# Stage 3: pull housekeeping script
    rm -rfv ./*.sh
    curl -o global-update.sh https://gitlab.com/initramfs-0/animegrimoire/raw/"$branch"/user-specific/Legendary%20Aurora/backup-restore/global-update.sh
    curl -o debian-backup.sh https://gitlab.com/initramfs-0/animegrimoire/raw/"$branch"/user-specific/Legendary%20Aurora/backup-restore/debian_backup.sh
    curl -o fedora-backup.sh https://gitlab.com/initramfs-0/animegrimoire/raw/"$branch"/user-specific/Legendary%20Aurora/backup-restore/fedora_backup.sh

# Stage 4: pull encoding scripts
    curl -o animegrimoire.sh https://gitlab.com/initramfs-0/animegrimoire/raw/"$branch"/user-specific/Legendary%20Aurora/animegrimoire.sh
    curl -o erairaws.sh https://gitlab.com/initramfs-0/animegrimoire/raw/"$branch"/user-specific/Legendary%20Aurora/source-specific/erairaws.sh
    curl -o dmonhiro.sh https://gitlab.com/initramfs-0/animegrimoire/raw/"$branch"/user-specific/Legendary%20Aurora/source-specific/dmonhiro.sh

# Stage 5: pull server/client scripts
    curl -o server.sh https://gitlab.com/initramfs-0/animegrimoire/raw/"$branch"/user-specific/Legendary%20Aurora/remote-encoder/server.sh
    curl -o client.sh https://gitlab.com/initramfs-0/animegrimoire/raw/"$branch"/user-specific/Legendary%20Aurora/remote-encoder/client.sh
    curl -o power-cycle.sh https://gitlab.com/initramfs-0/animegrimoire/raw/"$branch"/user-specific/Legendary%20Aurora/remote-encoder/power-cycle.sh
    curl -o mirror.sh https://gitlab.com/initramfs-0/animegrimoire/raw/"$branch"/user-specific/Legendary%20Aurora/remote-encoder/mirror.sh

# Stage 6: enable u+x
    cd ~ || exit
    chmod -R u+x ~/.local/bin/*.sh
    ls -lS ~/.local/bin && ls -lS ~/.local/preset

endl=$(date +%s)
echo "Scripts update completed in $((endl-startl)) seconds."
echo "Make sure to double check your credentials (webhook, keys, sshfs config) before running any scripts"
