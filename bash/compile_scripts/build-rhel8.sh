#!/bin/bash
# Tested in RHEL 8
# Install dependencies.
sudo dnf update -y
sudo subscription-manager repos --enable rhel-8-for-x86_64-baseos-rpms
sudo subscription-manager repos --enable rhel-8-for-x86_64-appstream-rpms
sudo subscription-manager repos --enable codeready-builder-for-rhel-8-x86_64-rpms
sudo dnf update -y
sudo dnf groupinstall "Development Tools" -y
sudo dnf localinstall --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-8.noarch.rpm
sudo dnf localinstall --nogpgcheck https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo dnf install epel-release -y
sudo dnf update -y
sudo dnf install jq sshfs bzip2-devel cmake fontconfig-devel freetype-devel fribidi-devel gcc-c++ git harfbuzz-devel jansson-devel lame-devel libass-devel libogg-devel libsamplerate-devel libtheora-devel libtool libvorbis-devel libxml2-devel libvpx-devel m4 make meson nasm ninja-build numactl-devel opus-devel patch python2 speex-devel tar xz-devel zlib-devel x264-devel dbus-glib-devel gstreamer1-devel gstreamer1-libav gstreamer1-plugins-base-devel intltool libgudev1-devel libnotify-devel webkit2gtk3-devel -y
# Build handbrake
mkdir Build && cd Build
git clone https://github.com/HandBrake/HandBrake.git && cd HandBrake
./configure --harden --disable-nvenc --disable-qsv --disable-vce --disable-gst --enable-fdk-aac --verbose --launch-jobs=$(nproc) --launch
sudo make --directory=build install
