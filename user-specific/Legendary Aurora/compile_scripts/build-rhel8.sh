#!/bin/bash
# Tested in RHEL 8
# Install dependencies.
sudo dnf update -y
sudo subscription-manager repos --enable rhel-8-for-x86_64-baseos-rpms
sudo subscription-manager repos --enable rhel-8-for-x86_64-appstream-rpms
sudo subscription-manager repos --enable codeready-builder-for-rhel-8-x86_64-rpms
sudo dnf update -y
sudo dnf groupinstall "Development Tools" -y
sudo dnf localinstall --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-8.noarch.rpm -y
sudo dnf install epel-release -y
sudo dnf update -y
sudo dnf install cmake fribidi-devel git jansson-devel numactl-devel python2 python3 opus-devel xz-devel lame-devel libogg-devel libsamplerate-devel libtheora-devel libvpx-devel libvorbis-devel meson nasm ninja-build opus-devel speex-devel libass-devel x264 x264-devel ffmpeg rhash mc nano htop screen libvpx-devel libxml2-devel numactl -y
sudo dnf install dbus-glib-devel gstreamer1-devel gstreamer1-libav gstreamer1-plugins-base-devel intltool libgudev1-devel libnotify-devel webkit2gtk3-devel -y
# Build handbrake
mkdir Build && cd Build
git clone https://github.com/HandBrake/HandBrake.git && cd HandBrake
./configure --harden --disable-nvenc --disable-qsv --disable-vce --disable-gst --enable-fdk-aac --verbose --launch-jobs=$(nproc) --launch
sudo make --directory=build install
