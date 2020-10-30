<div align="center">
<a href="https://animegrimoire.moe">
<img src="https://i.ibb.co/njzy67z/Animegrimoire-moe.png" alt="animegrimoire.org" height="200" width="200"</img>
</a>
</div>

Home: [https://animegrimoire.moe](https://animegrimoire.moe)<br> 

Old Home: [Web Archive](http://web.archive.org/web/20200203143744/https://animegrimoire.org/showthread.php?tid=1119)

Animegrimoire preset in HandbrakeCLI with FDK-AAC.

**This script and preset absolutely gives no warranty, no tech support, by using any stuff that included here means you already know your shit.**

## Tested in:
1. RHEL 8.1 Server x86_64
2. Windows 10 LTSC 1809 x86_64

### Worthwhile note:
1. Must have properly compiled handbrakecli and install `ffmpeg`, `rename`, `rhash`.
2. [Compile](https://handbrake.fr/docs/en/latest/developer/build-linux.html) HandBrake with fdk-aac.
```
$ ./configure --enable-fdk-aac --disable-gtk --launch-jobs=$(nproc) --launch
```
3. Put this script inside `for` loop
4. Logging function is generally nice to have but it's disabled by default
5. For windows encoder you may download it [here](https://animegrimoire.moe/download/link/windows-encoder) (outdated, not maintained)


