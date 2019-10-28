# Animegrimoire HandBrakeCLI
Forum home thread: [>>/animegrimoire/tavern/1119](https://animegrimoire.org/showthread.php?tid=1119)

Animegrimoire.org preset in Handbrake, purposely for HandBrakeCLI with FDK-AAC.

This script and preset absolutely gives no warranty, no tech support, by using any stuff that included here means you already know your shit. 

## Tested in:
1. Fedora 30 Server Minimal 64bit Installation inside ESXi environment.

### Worthwhile note:
1. Must have properly compiled handbrakecli and installs `ffmpeg`, `rename`, `rhash`.
2. [Compile](https://handbrake.fr/docs/en/latest/developer/build-linux.html) HandBrake with fdk-aac.
```
$ ./configure --enable-fdk-aac --disable-gtk --launch-jobs=$(nproc) --launch
```
3. Put this script inside `for` loop, or inside torrent's client `do something after files finished downloading`
4. Logging function is generally nice to have but it's disabled by default

### How-to-use (BATCH):
1. to run single file

`animegrimoire.bat ".\source\file that you wanted to encode [01].mkv"`

2. For all file in folder
Use `for_all_file_in_folder_source_do_animegrimoire_script.bat` script.

### This is the structure of the file and folder in Batch version:
```
your_encoding_folder/
├── lib/
│   ├── ffmpeg.exe
│   ├── HandBrakeCLI.exe
│   └── x264_animegrimoire.json
├── source/
│   ├── file that you wanted to encode [01].mkv
│   └── [fansub] file that you wanted to encode - 02.mkv
├── animegrimoire.bat
└── for_all_file_in_folder_source_do_animegrimoire_script.bat
```

### How-to-use (SHELL):

For normal Ongoing-type occasion, use:

`animegrimoire.sh` `[Ayylmaosubs] This anime title - 01 [720p].mkv`

On BDs or if source file also have [CRC32] tag on it use:

`animegrimoire.sh` `[Ayylmaosubs] This anime title - 01 [720p][12345678].mkv` `NUM`

=> `animegrimoire.sh` `[Ayylmaosubs] This anime title - 01 [720p][12345678].mkv` `42`

so the script only read character number 1-42 while ignoring CRC32 tag.

### This is the structure of the file and folder in Shell version:
```
home/$USER/
       ├── .local/bin/
       │      │    └── animegrimoire.sh
       │      │
       │      └──/preset/
       │             └──x264_animegrimoire.json
       └── Encodes/
              ├── [Ayylmaosub] file that you wanted to encode - 01 [720p].mkv
              └── [fansub] file that you wanted to encode - 02 [720p][12345678].mkv
/usr/bin/
      ├── ffmpeg
      ├── rename
      ├── rhash
      └── rclone
```


### Automatic uploading via rclone

See the script and uncomment it yourself, or point your rclone config on right location.

#### Overall Encoding steps:

1. Read file source (.mkv)
2. If number is defined, cut file name to remove CRC32 tag.
3. Extract subtitle from file source
4. Remove subtitle from file source
5. Embed watermark to extracted subtitle
6. Put subtitle with watermark back to file source
7. Encodes the file with defined json preset
8. Embed CRC32 tag in finished *.mp4 file
9. Clean up files
10. Upload encoded files via rclone (optional)
11. Count how long the script has been running and exit.