#!/bin/bash
clear
startl=$(date +%s)
ping -q -w 1 -c 1 10.8.0.1 > /dev/null && echo "$(date +%d%m%y): Gateway online, starting update." || exit

# Stage 0: Backup everything just in case
cd ~
tar -cvf backup.tar ~/.local/bin   
tar -uvf backup.tar ~/.local/preset

# Stage 1: pull global preset
    cd ~/.local/preset
    rm -rfv *.json
    curl -o x264_Animegrimoire.json https://gitlab.com/initramfs-0/animegrimoire/raw/master/preset/x264_animegrimoire.json
    curl -o x264_Animegrimoire_HBR.json https://gitlab.com/initramfs-0/animegrimoire/raw/master/preset/x264_animegrimoire_HBR.json

# Stage 2: pull precompiled binary (if any).
    cd ~/.local/bin
    rm -rfv mvg
    curl -o mvg https://gitlab.com/initramfs-0/animegrimoire/raw/master/user-specific/Legendary%20Aurora/precompiled-binary/mvg
    rm -rfv discord-msg
    curl -o discord-msg https://raw.githubusercontent.com/ChaoticWeg/discord.sh/master/discord.sh
    chmod u+x discord-msg

# Stage 3: pull housekeeping script
    rm -rfv *.sh
    curl -o global-update.sh https://gitlab.com/initramfs-0/animegrimoire/raw/master/user-specific/Legendary%20Aurora/backup-restore/global-update.sh
    curl -o debian-backup.sh https://gitlab.com/initramfs-0/animegrimoire/raw/master/user-specific/Legendary%20Aurora/backup-restore/debian_backup.sh
    curl -o fedora-backup.sh https://gitlab.com/initramfs-0/animegrimoire/raw/master/user-specific/Legendary%20Aurora/backup-restore/fedora_backup.sh

# Stage 4: pull encoding scripts
    curl -o animegrimoire.sh https://gitlab.com/initramfs-0/animegrimoire/raw/master/user-specific/Legendary%20Aurora/animegrimoire.sh
    curl -o erairaws.sh https://gitlab.com/initramfs-0/animegrimoire/raw/master/user-specific/Legendary%20Aurora/source-specific/erairaws.sh
    curl -o dmonhiro.sh https://gitlab.com/initramfs-0/animegrimoire/raw/master/user-specific/Legendary%20Aurora/source-specific/dmonhiro.sh

# Stage 5: pull server/client scripts
    curl -o server.sh https://gitlab.com/initramfs-0/animegrimoire/raw/master/user-specific/Legendary%20Aurora/remote-encoder/server.sh
    curl -o client.sh https://gitlab.com/initramfs-0/animegrimoire/raw/master/user-specific/Legendary%20Aurora/remote-encoder/client.sh

# Stage 6: enable u+x
    cd ~/.local/bin
    chmod -R u+x *.sh
    ls -lS
    cd ~

echo "Scripts update completed in $((endl-startl)) seconds."
echo "Make sure to double check your credentials (webhook, keys) before running any scripts"
