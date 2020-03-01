#!/bin/bash
clear
branch=$(cat ~/.animegrimoire_branch)

startl=$(date +%s)
ping -q -w 1 -c 1 10.8.0.1 > /dev/null && echo "$(date +%d%m%y): Gateway online, starting update." || exit

# Stage 0: Backup everything just in case
cd ~ || exit
mkdir -p /home/"$USER"/.fonts
mkdir -p /home/"$USER"/.local/bin
mkdir -p /home/"$USER"/.local/preset

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
    rm -rfv cpg
    curl -o mvg https://gitlab.com/initramfs-0/animegrimoire/raw/"$branch"/bash/precompiled-binary/mvg
    curl -o mvg https://gitlab.com/initramfs-0/animegrimoire/raw/"$branch"/bash/precompiled-binary/cpg
    chmod u+x mvg
    chmod u+x cvg
    rm -rfv discord-msg
    curl -o discord-msg https://raw.githubusercontent.com/ChaoticWeg/discord.sh/master/discord.sh
    chmod u+x discord-msg
    cd ~/.fonts || exit
    rm -rfv Worstveld.otf
    curl -o Worstveld.otf https://gitlab.com/initramfs-0/animegrimoire/raw/"$branch"/bash/precompiled-binary/Worstveld.otf

# Stage 3: pull housekeeping script
    cd ~/.local/bin || exit
    rm -rfv ./*.sh
    curl -o fedora-backup.sh https://gitlab.com/initramfs-0/animegrimoire/raw/"$branch"/bash/backup-restore/backup.sh
    curl -o global-update.sh https://gitlab.com/initramfs-0/animegrimoire/raw/"$branch"/bash/backup-restore/global-update.sh
    curl -o debian-backup.sh https://gitlab.com/initramfs-0/animegrimoire/raw/"$branch"/bash/backup-restore/debian_backup.sh

# Stage 4: pull encoding scripts
    curl -o animegrimoire.sh https://gitlab.com/initramfs-0/animegrimoire/raw/"$branch"/bash/animegrimoire.sh
    curl -o erairaws.sh https://gitlab.com/initramfs-0/animegrimoire/raw/"$branch"/bash/source-specific/erairaws.sh
    curl -o dmonhiro.sh https://gitlab.com/initramfs-0/animegrimoire/raw/"$branch"/bash/source-specific/dmonhiro.sh
    curl -o animegrimoire-HBR.sh https://gitlab.com/initramfs-0/animegrimoire/raw/"$branch"/bash/animegrimoire-HBR.sh

# Stage 5: pull server/client scripts
    curl -o server.sh https://gitlab.com/initramfs-0/animegrimoire/raw/"$branch"/bash/remote-encoder/server.sh
    curl -o client.sh https://gitlab.com/initramfs-0/animegrimoire/raw/"$branch"/bash/remote-encoder/client.sh
    curl -o mirror.sh https://gitlab.com/initramfs-0/animegrimoire/raw/"$branch"/bash/remote-encoder/mirror.sh
    curl -o install.sh https://gitlab.com/initramfs-0/animegrimoire/raw/"$branch"/bash/remote-encoder/install.sh
    curl -o power-cycle.sh https://gitlab.com/initramfs-0/animegrimoire/raw/"$branch"/bash/remote-encoder/power-cycle.sh

# Stage 6: enable u+x
    cd ~ || exit
    chmod -R u+x ~/.local/bin/*.sh
    ls -lS ~/.local/bin && ls -lS ~/.local/preset

endl=$(date +%s)
echo "Scripts update completed in $((endl-startl)) seconds."
echo "Make sure to double check your credentials (webhook, keys, sshfs config) before running any scripts"
