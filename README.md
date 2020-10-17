<div align="center">
<a href="https://animegrimoire.moe">
<img src="https://i.ibb.co/njzy67z/Animegrimoire-moe.png" alt="animegrimoire.org" height="200" width="200"</img>
</a>
</div>

Home: [https://animegrimoire.moe](https://animegrimoire.moe)<br> 
Wiki: [animegrimoire/docs](https://gitlab.com/initramfs-0/animegrimoire/-/wikis/Animegrimoire-Wiki)<br> 

Old Home: [Web Archive](http://web.archive.org/web/20200203143744/https://animegrimoire.org/showthread.php?tid=1119)

Animegrimoire preset in HandbrakeCLI with FDK-AAC.

**This script and preset absolutely gives no warranty, no tech support, by using any stuff that included here means you already know your shit.**

## Tested in:
1. RHEL 8.1 Server 64bit
2. Windows 10 LTSC 1809 64bit

### Worthwhile note:
1. Must have properly compiled handbrakecli and install `ffmpeg`, `rename`, `rhash`.
2. [Compile](https://handbrake.fr/docs/en/latest/developer/build-linux.html) HandBrake with fdk-aac.
```
$ ./configure --enable-fdk-aac --disable-gtk --launch-jobs=$(nproc) --launch
```
3. Put this script inside `for` loop, or inside torrent's client `do something after files finished downloading`
4. Logging function is generally nice to have but it's disabled by default
5. Visit home if you want to download our encoder [releases](https://animegrimoire.moe/encoder/)

### How-to-use (BASH):

For normal Ongoing-type occasion, use:

`animegrimoire.sh` `[Ayylmaosubs] This anime title - 01 [720p].mkv`

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

### How-to-use (BATCH):

Double click `launch_encoder.bat`

### This is the structure of the file and folder in Batch version:
```
Encoding/
├── encoded_mp4
├── extract_font.bat
├── finished
├── fonts
├── launch_encoder.bat
├── launch_renamer.bat
├── lib
│   ├── animegrimoire.bat
│   ├── etc
│   │   ├── preset
│   │   │   ├── x264_animegrimoire_HBR.json
│   │   │   └── x264_animegrimoire.json
│   │   ├── renamer
│   │   ├── sample
│   │   │   └── [HorribleSubs] Fumikiri Jikan - 01 [720p].mkv
│   │   ├── tools
│   │   │   ├── help.txt
│   │   │   ├── Take Ownership install.reg
│   │   │   └── Take Ownership uninstall.reg
│   │   ├── tutorial
│   │   │   ├── animegrimoire-handbrakecli-emelie-tutorial.mp4
│   │   │   ├── Animegrimoire-Handbrake GUI.png
│   │   │   └── what files are these.png
│   │   └── watermark-fonts
│   │       └── Worstveld.otf
│   ├── ffmpeg.exe
│   ├── fonts.bat
│   ├── HandBrakeCLI.exe
│   ├── hb.dll
│   └── x264_animegrimoire.json
├── source
├── temp
└── watermarked

```

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
