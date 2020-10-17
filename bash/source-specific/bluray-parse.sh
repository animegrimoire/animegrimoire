#!/bin/bash
#Simple Parser to extract Erai-raws releases
startl=$(date +%s)
## Load config file
source "/home/$USER/.local/config/animegrimoire.conf"

#Generate new file name
echo "$1" > ./filename.tmp
echo "$2" > ./newfile.tmp
echo "$3" > ./newlimit.tmp
sed -i 's/,//g' ./filename.tmp
sed -i 's/`//g' ./filename.tmp
sed -i 's/\r$//g' ./filename.tmp
sed -i 's/ \[.*\]//g' ./filename.tmp
sed -i 's/\[*.*\] //' ./filename.tmp
sed -i 's/v2//' ./filename.tmp
sed -i 's/v1//' ./filename.tmp
sed -i 's/v1//' ./name.tmp
sed -i 's/Multiple Subtitle//' ./filename.tmp
sed -i 's/\[\]//' ./filename.tmp
sed -i 's/ (.*)//' ./filename.tmp
sed -i 's/[^0-9]//g' ./filename.tmp

# Use switch to separate BDs that has separated subtitles, or no subtitles yet
echo -e "Is subtitle embedded? (y/n):\n"
read -r input0
case "$input0" in
  y)
  echo -e "\nEmbedded subtitle route selected"
# Begin parsing files with embedded subtitle
episode=$(<./filename.tmp)
new_name=$(<./newfile.tmp)
new_delimiter=$(<./newlimit.tmp)
ext=$(echo $1 | sed 's/.*\.//')
construct_name="$(echo $new_name - $episode.$ext)"
subtitle_name="$(echo "$construct_name" | cut -f 1 -d '.').ass"
echo -e "File input: $1"
echo -e "Defined name: $2"
echo -e "Step delimiter: $3"
echo -e "File extension is: $ext"
echo -e "From $1, Episode number is: $episode"
echo -e "Moving: $1 to $construct_name"
echo -e "Episode number should in column: $new_delimiter"
sleep 10
echo -e "\n$1 -> $construct_name"
mv -v "$1" "$construct_name"

# Select Video, Audio, Subtitle Streams
echo -e "\nffprobe: '\033[36m$construct_name\e[0m'"
ffprobe -v quiet -show_entries stream=index:stream=codec_long_name:stream=index:stream_tags=language -of csv -i "$construct_name" | sed 's/,/ /g'
echo -e "\nExtracting '\033[36m$construct_name\e[0m'"
echo -e "Enter a valid integer in 'VIDEO, AUDIO, SUBTITLE' format:"
read -r streams
video_stream=${streams:0:1}
audio_stream=${streams:1:1}
subtitle_stream=${streams:2:1}
echo -e "Starting ffmpeg with Video=$video_stream, Audio=$audio_stream, Subtitle=$subtitle_stream"

# Extract fonts
touch $fonts_write/000.tmp
echo "$(date): Extract fonts"
ffmpeg -dump_attachment:t "" -i "$construct_name" -y
for fonts in *.*TF *.*tf; do mv "$fonts" "$fonts_write"; done

# Extract file based on selected metadata
ffmpeg -hide_banner -i "$construct_name" -map 0:"$video_stream" -map 0:"$audio_stream" -map 0:"$subtitle_stream" -c:v copy -c:a copy -c:s:"$subtitle_stream" copy -metadata:s:a:0 language=jpn -metadata:s:v:0 language=jpn -metadata:s:s:0 language=eng "./output.mkv" -y

# Extract subtitle in separated file
ffmpeg -hide_banner -i "$construct_name" -map 0:"$subtitle_stream" "$subtitle_name" -y

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
rm -v ./output_demux.mkv
rm -v "$subtitle_name"

# Overwrite original with newly selected streams
mv "./output.mkv" "$construct_name"

# Create an instruction file
echo "$2" > ./note.txt
echo "$3" >> ./note.txt

# Move newly made file into encoding folder for queue
mv -v "$construct_name" "$blurayd"
mv -v ./note.txt "$blurayd"

## Exit process
[ ! -e ./newfile.tmp ] || rm ./newfile.tmp
[ ! -e ./filename.tmp ] || rm ./filename.tmp
[ ! -e ./newlimit.tmp ] || rm ./newlimit.tmp

endl=$(date +%s)

# Report Result to Discord
_webhook="$webhook_avx"
_title="New Queued File"
_timestamp="$USER@$HOSTNAME $(date)"
_description="$construct_name"
discord-msg --webhook-url="$_webhook" --title="$_title" --description "$_description" --color "$yellw" --footer="$_timestamp"

  ;;
  n)
  echo "Non-embedded subtitle route selected"
# Begin parsing files with separated subtitle
episode=$(<./filename.tmp)
new_name=$(<./newfile.tmp)
new_delimiter=$(<./newlimit.tmp)
ext=$(echo $1 | sed 's/.*\.//')
construct_name="$(echo $new_name - $episode.$ext)"
# Guess Subtitle name, usually it's composed using "$1" with subtitle-type extension
guess_subtitle="$(echo "$1" | cut -f 1 -d '.').ass"
[ ! -e "$guess_subtitle" ] || echo Subtitle found!: "$guess_subtitle"

subtitle_name="$(echo "$construct_name" | cut -f 1 -d '.').ass"
echo -e "File input: $1"
echo -e "Defined name: $2"
echo -e "Step delimiter: $3"
echo -e "File extension is: $ext"
echo -e "From $1, Episode number is: $episode"
echo -e "Moving: $1 to $construct_name"
echo -e "Episode number should in column: $new_delimiter"
echo -e "\n$1 -> $construct_name"
echo -e "\n$guess_subtitle -> $subtitle_name"
#Once old subtitle is defined, move it using subtitle_name format
mv -v "$1" "$construct_name"
mv -v "$guess_subtitle" "$subtitle_name"

# Embed watermark to comply Grimoire Archive global rule
echo "$(date): embedding watermark"
sed -i '/Format\: Name/a Style\: Watermark,Worstveld Sling,20,&H00FFFFFF,&H00FFFFFF,&H00FFFFFF,&H00FFFFFF,0,0,0,0,100,100,0,0,1,0,0,9,0,5,0,11' "$subtitle_name"
sed -i '/Format\: Layer/a Dialogue\: 0,0:00:00.00,0:00:04.00,Watermark,,0000,0000,0000,,animegrimoire.moe' "$subtitle_name"
echo "$(date): Testing watermark"
grep Worstveld < "$subtitle_name"
grep animegrimoire < "$subtitle_name"

# Select Video and Audio Stream
echo -e "\nffprobe: '\033[36m$construct_name\e[0m'"
ffprobe -v quiet -show_entries stream=index:stream=codec_long_name:stream=index:stream_tags=language -of csv -i "$construct_name" | sed 's/,/ /g'
echo -e "\nExtracting '\033[36m$construct_name\e[0m'"
echo -e "Enter a valid integer in 'VIDEO, AUDIO' format:"
read -r streams
video_stream=${streams:0:1}
audio_stream=${streams:1:1}
echo -e "Starting ffmpeg with Video=$video_stream, Audio=$audio_stream"

# Extract fonts
touch $fonts_write/000.tmp
echo "$(date): Extract fonts"
ffmpeg -dump_attachment:t "" -i "$construct_name" -y
for fonts in *.*TF *.*tf; do mv "$fonts" "$fonts_write"; done

# Extract file based on selected metadata
ffmpeg -hide_banner -i "$construct_name" -map 0:"$video_stream" -map 0:"$audio_stream" -c:v copy -c:a copy -metadata:s:a:0 language=jpn -metadata:s:v:0 language=jpn -metadata:s:s:0 language=eng "./output.mkv" -y

# Send back the modified subtitle into container
echo "$(date): Embedding new subtitle with watermark"
ffmpeg -hide_banner -i ./output_demux.mkv -i "$subtitle_name" -c:v copy -c:a copy -c:s copy -map 0:0 -map 0:1 -map 1:0 -metadata:s:a:0 language=jpn -metadata:s:v:0 language=jpn -metadata:s:s:0 language=eng "./output.mkv" -y
rm -v ./output_demux.mkv
rm -v "$subtitle_name"

# Overwrite original with newly selected streams
mv "./output.mkv" "$construct_name"


# Create an instruction file
echo "$2" > ./note.txt
echo "$3" >> ./note.txt

# Move newly made file into encoding folder for queue
mv -v "$construct_name" "$blurayd"
mv -v ./note.txt "$blurayd"

## Exit process
[ ! -e ./newfile.tmp ] || rm ./newfile.tmp
[ ! -e ./filename.tmp ] || rm ./filename.tmp
[ ! -e ./newlimit.tmp ] || rm ./newlimit.tmp

endl=$(date +%s)

# Report Result to Discord
_webhook="$webhook_avx"
_title="New Queued File"
_timestamp="$USER@$HOSTNAME $(date)"
_description="$construct_name"
discord-msg --webhook-url="$_webhook" --title="$_title" --description "$_description" --color "$yellw" --footer="$_timestamp"

  ;;
  *)
  echo "Invalid options"
[ ! -e ./newfile.tmp ] || rm ./newfile.tmp
[ ! -e ./filename.tmp ] || rm ./filename.tmp
[ ! -e ./newlimit.tmp ] || rm ./newlimit.tmp
  exit
  ;;
esac
