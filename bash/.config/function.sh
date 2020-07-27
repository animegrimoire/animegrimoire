#Keep functions here

# file-management.sh
function discord_send {
    _timestamp_="$USER@$HOSTNAME $(date)"
    discord-msg --webhook-url="$webhook_nivida" --title="$_title_" --description="$_description_" --color="$gween" --footer="$_timestamp_"
}
function telegram_send {
    telegram-send --format markdown "*$file_name* Is successfully indexed."
}
function mysql_write {
date_now="$(date +%d%m%Y%H%M%S)"
mysql --host=$database_host --user=$database_user --password=$database_passwd --database=$database_encoder << EOF
INSERT INTO Records (id, date, file_source, encode_time, long_url, file_result, short_url, notes) VALUES (NULL, "$date_now", 0, 0, 0, "$file_name", '0', "PASS");
EOF
}
function mysql_dump {
    mysql --host=$database_host --user=$database_user --password=$database_passwd --database=$database_encoder -e "SELECT id, date, file_result, short_url, notes FROM Records ORDER BY file_result ASC;" | sed 's/\t/","/g;s/^/"/;s/$/"/;s/\n//g' | sed 's/\"\"/\"/g' > ./index.csv
}
function update_tree {
    curl --user "FTP_USER" --upload-file ./tree.html ftp://"FTP_DEST"/tree.html
}
function tree_animegrimoire {
    curl --user "FTP_USER" --upload-file ./index.csv ftp://"FTP_DEST"/index.csv
}

# client.sh
function discord_report {
	_title_="[Encoding started]"
	_timestamp_="$USER@$HOSTNAME $(date)"
	_description_="Source file(s) or folder found. listing files, starting.."
	discord-msg --webhook-url="$webhook_avx" --title="$_title_" --description="$_description_" --color="$gween" --footer="$_timestamp_"
	discord-msg --webhook-url="$webhook_avx" --text="$(ls -Ss1pq ./*.mkv --block-size=1000000 | jq -Rs . | cut -c 2- | rev | cut -c 2- | rev)"
}

# remote-encoder 
function sshfs_mount {
    sshfs -p"$PORT" "$REMOTE_USERNAME"@"$GATEWAY":/home/"$REMOTE_USERNAME"/sshfsd /home/"$USER"/Animegrimoire/sshfs
}
function sshfs_test {
    while :
	do
	if pgrep -x "sshfs" > /dev/null
		then
		echo "$(date): SSHFS is running, continue."
		break
	else
		echo "$(date): SSHFS is not running, remounting."
		sshfs-mount
		fi
	done
}

# general-encoder
function handbrake_test {
    while :
        do
    if pgrep -x "HandBrakeCLI" > /dev/null
        then
        echo "$(date): HandBrakeCLI is running, retrying.."
        sleep 600
    else
        echo "$(date): HandBrakeCLI process not found, continuing subroutine."
        break
    fi
done
}

