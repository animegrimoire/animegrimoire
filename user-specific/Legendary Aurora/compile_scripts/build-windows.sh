#!/bin/bash
sudo dnf update
#Install dependencies 
sudo dnf localinstall --nogpgcheck https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(cat /etc/system-release | awk '{ print $3}').noarch.rpm
sudo dnf groupinstall "Development Tools" "C Development Tools and Libraries"
sudo dnf groupinstall "X Software Development" "GNOME Software Development"
sudo dnf install bzip2-devel cmake fontconfig-devel freetype-devel fribidi-devel gcc-c++ git harfbuzz-devel jansson-devel lame-devel lbzip2 libass-devel libogg-devel libsamplerate-devel libtheora-devel libtool libvorbis-devel libxml2-devel libvpx-devel m4 make meson nasm ninja-build numactl-devel opus-devel patch python speex-devel tar xz-devel zlib-devel
sudo dnf install x264-devel
sudo dnf install dbus-glib-devel gstreamer1-devel gstreamer1-libav gstreamer1-plugins-base-devel intltool libgudev1-devel libnotify-devel webkit2gtk3-devel
# Build handbrake
mkdir Build && cd Build
git clone https://github.com/HandBrake/HandBrake.git && cd HandBrake
scripts/mingw-w64-build x86_64 /home/$USER/toolchains/
export PATH="/home/$USER/toolchains//mingw-w64-x86_64/bin:${PATH}"
x86_64-w64-mingw32-gcc -v
./configure --cross=x86_64-w64-mingw32 --disable-gtk --disable-nvenc --disable-qsv --disable-vce --disable-gst --enable-fdk-aac --launch-jobs=$(nproc) --launch
echo if build is completed, copy 'HandBrakeCLI.exe' and 'hb.dll' to target machine
