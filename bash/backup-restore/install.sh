#!/bin/bash

# Prepare the source files
mkdir -p tmp
cd tmp
wget https://gitlab.com/initramfs-0/animegrimoire/-/raw/master/build/animegrimoire.tar
wget https://raw.githubusercontent.com/ChaoticWeg/discord.sh/master/discord.sh
tar -xvf animegrimoire.tar

# Init folders
mkdir -p ~/.local/bin
mkdir -p ~/.local/preset
mkdir -p ~/.local/config
mkdir -p ~/.fonts
mkdir -p ~/Animegrimoire/local/encodes
mkdir -p ~/Animegrimoire/local/sshfs

# Copy scripts and setup permission
mv -v bash/.config/animegrimoire.conf ~/.local/config/
mv -v bash/.config/config.yml ~/.local/config/
mv -v bash/.config/function.sh ~/.local/config/
mv -v discord.sh ~/.local/bin/discord-msg
mv -v bash/backup-restore/backup.sh ~/.local/bin/
mv -v bash/backup-restore/install.sh ~/.local/bin/
mv -v bash/compile-scripts/build-rhel.sh ~/.local/bin/
mv -v bash/compile-scripts/build-windows.sh ~/.local/bin/
mv -v bash/precompiled-binary/00 ~/Animegrimoire/local/encodes/"[HorribleSubs] Animegrimoire, Sanity Check! - 00 [720p].mkv"
mv -v bash/precompiled-binary/Worstveld.otf ~/.fonts/
mv -v bash/precompiled-binary/perl-rename.pl ~/.local/bin/rename
mv -v bash/remote-encoder/client.sh ~/.local/bin/
mv -v bash/remote-encoder/file-management.sh ~/.local/bin/
mv -v bash/source-specific/bluray.sh ~/.local/bin/
mv -v bash/source-specific/parse.sh ~/.local/bin/
mv -v bash/animegrimoire.sh ~/.local/bin/
mv -v preset/x264_animegrimoire.json ~/.local/preset
chmod -R u+x ~/.local/bin/*

#cleanup

cd .. && rm -rfv tmp/
tree ~/.local