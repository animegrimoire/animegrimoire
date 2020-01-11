#!/bin/bash
set -e
clear

if [[ "${EUID}" -ne 0 ]]; then
	echo 'Run this backup script as root'
	exit
fi
cd ~

echo 'Select action'
echo '1) Backup'
echo '2) Restore'
echo 'q) Exit'
read -p '<1/2/q>: ' action

case $action in

	[1] )
	tar -cvf backup.tar /home/?USER/.scripts
	tar -uvf backup.tar /home/?USER/.ssh
	tar -uvf backup.tar /home/?USER/.fonts
	tar -uvf backup.tar /home/?USER/.config/deluge
	tar -uvf backup.tar /home/?USER/.config/rclone
	tar -uvf backup.tar /home/?USER/<?path_to_rss_relay> --exclude=/<?exclude_dir>
	tar -uvf backup.tar /var/www/<path_to_public_serve:1>
	tar -uvf backup.tar /var/www/<path_to_public_serve:2>
	tar -uvf backup.tar /var/www/<path_to_public_serve:3>
	tar -uvf backup.tar /var/www/<path_to_public_serve:4>
	tar -uvf backup.tar /etc/apache2/apache2.conf
	tar -uvf backup.tar /etc/apache2/sites-available
	tar -uvf backup.tar /etc/openvpn
	tar -uvf backup.tar /etc/ufw
	tar -uvf backup.tar /etc/pihole/adlists.list
	tar -uvf backup.tar /etc/pihole/auditlog.list
	tar -uvf backup.tar /etc/pihole/blacklist.txt
	tar -uvf backup.tar /etc/pihole/regex.list
	tar -uvf backup.tar /etc/pihole/setupVars.conf
	tar -uvf backup.tar /etc/pihole/whitelist.txt
	tar -uvf backup.tar /etc/dnsmasq.d/01-pihole.conf
	tar -uvf backup.tar /etc/sudoers.d/user-shutdown
	tar -uvf backup.tar /etc/sudoers.d/user-mount
	tar -uvf backup.tar /etc/sudoers.d/user-umount
	;;

	[2] )
	if [ -f "backup.tar" ]; then
		echo 'backup found, restoring.. '
		sudo tar -xvf backup.tar
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
