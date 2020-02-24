#!/usr/bin/bash
mkdir -p /home/"$USER"/temp
mkdir -p /home/"$USER"/.fonts
mkdir -p /home/"$USER"/.local/bin
mkdir -p /home/"$USER"/.local/preset
mkdir -p /home/"$USER"/Animegrimoire/sshfs
touch /home/"$USER"/.webhook_avx
touch /home/"$USER"/.animegrimoire_branch

cd ~/.local/bin || exit
curl -o global-update.sh https://gitlab.com/initramfs-0/animegrimoire/raw/master/bash/backup-restore/global-update.sh
cd ~ || exit
bash ~/.local/bin/global-update.sh
