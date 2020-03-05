#!/bin/bash
# Tested in Centos 8
# Install dependencies.
sudo dnf update -y
sudo dnf config-manager --set-enabled PowerTools
sudo dnf groupinstall "Development Tools" -y
sudo dnf install epel-release -y
sudo dnf localinstall --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-8.noarch.rpm -y
sudo dnf update -y
sudo dnf install jq sshfs bzip2-devel cmake fribidi-devel git jansson-devel numactl-devel python2 python3 opus-devel xz-devel lame-devel libogg-devel libsamplerate-devel libtheora-devel libvpx-devel libvorbis-devel meson nasm ninja-build opus-devel speex-devel libass-devel x264 x264-devel ffmpeg rhash mc nano htop screen libvpx-devel libxml2-devel numactl -y
# Build handbrake
mkdir Build && cd Build || exit
git clone https://github.com/HandBrake/HandBrake.git && cd HandBrake || exit
./configure --harden --disable-gtk --disable-nvenc --disable-qsv --disable-vce --disable-gst --enable-fdk-aac --verbose --launch-jobs="$(nproc)" --launch
sudo make --directory=build install
