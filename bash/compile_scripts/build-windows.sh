#!/bin/bash
# Tested in RHEL 8
# Install dependencies.
sudo dnf update -y
sudo subscription-manager repos --enable rhel-8-for-x86_64-baseos-rpms
sudo subscription-manager repos --enable rhel-8-for-x86_64-appstream-rpms
sudo subscription-manager repos --enable codeready-builder-for-rhel-8-x86_64-rpms
sudo subscription-manager repos --enable codeready-builder-for-rhel-8-x86_64-source-rpms
sudo dnf update -y
sudo dnf groupinstall "Development Tools" -y
sudo dnf localinstall --nogpgcheck https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo dnf localinstall --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-8.noarch.rpm
sudo dnf localinstall --nogpgcheck https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-8.noarch.rpm
sudo dnf install epel-release -y
sudo dnf update -y
sudo dnf install jq sshfs bzip2-devel cmake fontconfig-devel freetype-devel fribidi-devel gcc-c++ git harfbuzz-devel jansson-devel lame-devel libass-devel libogg-devel libsamplerate-devel libtheora-devel libtool libvorbis-devel libxml2-devel libvpx-devel m4 make meson nasm ninja-build numactl-devel opus-devel patch python2 speex-devel tar xz-devel zlib-devel x264-devel dbus-glib-devel gstreamer1-devel gstreamer1-libav gstreamer1-plugins-base-devel intltool libgudev1-devel libnotify-devel webkit2gtk3-devel -y
# Build handbrake
mkdir Build && cd Build || exit
git clone https://github.com/HandBrake/HandBrake.git && cd HandBrake || exit
scripts/mingw-w64-build x86_64 /home/"$USER"/toolchains/
export PATH="/home/$USER/toolchains//mingw-w64-x86_64/bin:${PATH}"
x86_64-w64-mingw32-gcc -v
./configure --cross=x86_64-w64-mingw32 --disable-gtk --disable-nvenc --disable-qsv --disable-vce --disable-gst --enable-fdk-aac --launch-jobs="$(nproc)" --launch
echo if build is completed, copy 'HandBrakeCLI.exe' and 'hb.dll' to target machine
