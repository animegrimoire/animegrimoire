#!/bin/bash
#Simple Parser to extract Erai-raws releases
startl=$(date +%s)
## Load config file
source "/home/$USER/.local/config/animegrimoire.conf"

#Generate new file name
echo "$1" > ./name.tmp
sed -i 's/,//g' ./name.tmp
sed -i 's/`//g' ./name.tmp
sed -i 's/\r$//g' ./name.tmp
sed -i 's/\[*.*\] //' ./name.tmp
sed -i 's/ \[.*\]//g' ./name.tmp
sed -i 's/Multiple Subtitle//' ./name.tmp
sed -i 's/\[\]//g' ./name.tmp
sed -i 's/ (.*)//' ./name.tmp
file_name="$(<./name.tmp)"
subtitle_name="$(echo "$file_name" | cut -f 1 -d '.').ass"
echo -e "\n$1 -> $file_name"
mv -v "$1" "$file_name"

# Select Video, Audio, Subtitle Streams
echo -e "\nffprobe: '\033[36m$file_name\e[0m'"
ffprobe -v quiet -show_entries stream=index:stream=codec_long_name:stream=index:stream_tags=language -of csv -i "$file_name" | sed 's/,/ /g'
echo -e "\nExtracting '\033[36m$file_name\e[0m'"
echo -e "Enter a valid integer in 'VIDEO, AUDIO, SUBTITLE' format:"
read -r streams
video_stream=${streams:0:1}
audio_stream=${streams:1:1}
subtitle_stream=${streams:2:1}
echo -e "Starting ffmpeg with Video=$video_stream, Audio=$audio_stream, Subtitle=$subtitle_stream"

# Extract fonts
touch $fonts_write/000.tmp
echo "$(date): Extract fonts"
ffmpeg -dump_attachment:t "" -i "$file_name" -y
for fonts in *.*TF *.*tf; do mv "$fonts" "$fonts_write"; done

# Extract file based on selected metadata
ffmpeg -hide_banner -i "$file_name" -map 0:"$video_stream" -map 0:"$audio_stream" -map 0:"$subtitle_stream" -c:v copy -c:a copy -c:s:"$subtitle_stream" copy -metadata:s:a:0 language=jpn -metadata:s:v:0 language=jpn -metadata:s:s:0 language=eng "./output.mkv" -y

# Extract subtitle in separated file
ffmpeg -hide_banner -i "$file_name" -map 0:"$subtitle_stream" "$subtitle_name" -y

# Remove original subtitle
echo "$(date): Remove old subtitle from file source"
ffmpeg -hide_banner -i "./output.mkv" -map 0 -map -sn -codec copy "./output_demux.mkv" -y
rm ./output.mkv

# Embed watermark to comply Grimoire Archive global rule
echo "$(date): embedding watermark"
sed -i '/Format\: Name/a Style\: Watermark,Worstveld Sling,20,&H00FFFFFF,&H00FFFFFF,&H00FFFFFF,&H00FFFFFF,0,0,0,0,100,100,0,0,1,0,0,9,0,5,0,11' "$subtitle_name"
sed -i '/Format\: Layer/a Dialogue\: 0,0:00:00.00,0:00:04.00,Watermark,,0000,0000,0000,,animegrimoire.moe' "$subtitle_name"
echo "$(date): Testing watermark"
grep Worstveld < "$subtitle_name"
grep animegrimoire < "$subtitle_name"

# Send back the modified subtitle into container
echo "$(date): Embedding new subtitle with watermark"
ffmpeg -hide_banner -i ./output_demux.mkv -i "$subtitle_name" -c:v copy -c:a copy -c:s copy -map 0:0 -map 0:1 -map 1:0 -metadata:s:a:0 language=jpn -metadata:s:v:0 language=jpn -metadata:s:s:0 language=eng "./output.mkv" -y
rm ./output_demux.mkv

# Overwrite original with newly selected streams
mv "./output.mkv" "$file_name"

# Move newly made file into encoding folder for queue
mv -v "$file_name" "$airing_season"
mv -v "$subtitle_name" "$airing_season"

## Exit process
[ ! -e ./name.tmp ] || rm ./name.tmp
endl=$(date +%s)

# Report Result to Discord and Telegram
_webhook="$webhook_extractor"
_title="New Queued File"
_timestamp="$USER@$HOSTNAME $(date) $((endl-startl))s"
_description="$file_name"
discord-msg --webhook-url="$_webhook" --title="$_title" --description "$_description" --color "$yellw" --footer="$_timestamp"
telegram-send --format markdown "New Queued File: *$file_name*"
