#!/bin/bash
clear
echo 'Select action'
echo '1) Backup'
echo '2) Restore'
echo 'q) Exit'
read -p '<1/2/q>: ' action
cd ~

case $action in
	[1] )
	tar -cvf backup.tar ~/.local/bin   
	tar -uvf backup.tar ~/.local/preset
	tar -uvf backup.tar ~/.config/deluge
	tar -uvf backup.tar ~/.config/rclone
	tar -uvf backup.tar ~/.ssh/id_rsa
	tar -uvf backup.tar ~/.ssh/id_rsa.pub
	sudo tar -uvf backup.tar /etc/openvpn/client
	;;

	[2] )
	if [ -f "~/backup.tar" ]; then
		echo 'backup found, restoring.. ' 
		sudo tar -xvf ~/backup.tar
	else 
		echo "backup does not exist. input your 'backup.tar' in absolute path:"
		read -p 'archive location: ' custom_archive
		sudo tar -xvf $custom_archive
	fi
	;;

	[q] )
	exit
	;;
esac
