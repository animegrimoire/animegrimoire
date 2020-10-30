#!/bin/bash

find Archive/Animegrimoire/ > ./archive.txt
find Archive/Animegrimoire-ng/ >> ./archive.txt
sort ./archive.txt

while IFS= read -r line; do ia upload animegrimoire.moe_archive "$line" --metadata="mediatype:movies" && sleep 60; done < ./archive.txt > ./log.txt
