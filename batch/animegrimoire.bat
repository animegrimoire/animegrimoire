@echo off

set filename=%~n1
set fullpath=%~f1

REM END FILE
set watermarkedFilename=[animegrimoire]%filename%

REM VARIABLE NAME
set underscoreFilename=%filename: =_%
set underscoreFilename=%underscoreFilename:[=%
set underscoreFilename=%underscoreFilename:]=%

set subtitle=%underscoreFilename%_subtitle
set subtitleTemp=%underscoreFilename%_temp_subtitle
set videoNoSubtitle=%underscoreFilename%_no_sub

REM WATERMARK
set watermarkStyle=Style: Watermark,Cambria,12,^^^&H00FFFFFF,^^^&H000000FF,^^^&H00000000,^^^&H00000000,0,1,0,0,100,100,0,0,1,2,1.2,9,10,10,10,1
set watermarkText=Dialogue: 0,0:00:00.00,0:00:02.00,Watermark,,0000,0000,0000,,animegrimoire.org

REM FOR SEARCHING LINE IN TEXT
set line1find=Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
set line2find=Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text

REM LIBRARY POSITIONS
set ffmpeg=.\lib\ffmpeg
set preset=.\lib\x264_animegrimoire.json
set handbrakeCLI=.\lib\HandBrakeCLI

REM ADD DIRECTORY FOR OUTPUT
if not exist .\temp mkdir .\temp
if not exist .\watermarked mkdir .\watermarked
if not exist .\encoded mkdir .\encoded

REM extract subtitle
%ffmpeg% -i "%fullpath%" -map 0:s .\temp\%subtitle%.ass -y

REM demux file, remove original subtitle
%ffmpeg% -i "%fullpath%" -map 0 -map 0:s -codec copy .\temp\%videoNoSubtitle%.mkv -y

REM add watermark, using powershell
@powershell -Command "get-content .\temp\%subtitle%.ass | %%{$_ -replace \"%line1find%\",\"%line1find%`r`n%watermarkStyle%\"}" >> .\temp\%subtitleTemp%01.ass
@powershell -Command "get-content .\temp\%subtitleTemp%01.ass | %%{$_ -replace \"%line2find%\",\"%line2find%`r`n%watermarkText%\"}" >> .\temp\%subtitleTemp%02.ass

REM send back watermark to mkv
%ffmpeg% -i .\temp\%videoNoSubtitle%.mkv  -i .\temp\%subtitleTemp%02.ass -c:v copy -c:a copy -c:s copy -map 0:0 -map 0:1 -map 1:0 -metadata:s:a:0 language=jpn -metadata:s:s:0 language=eng ".\watermarked\%watermarkedFilename%.mkv" -y

REM encode file
%handbrakeCLI% --preset-import-file %preset% -Z "x264_Animegrimoire" -i ".\watermarked\%watermarkedFilename%.mkv" -o ".\encoded\%watermarkedFilename%.mp4"

REM remove unnecessary file
del .\temp\%subtitle%.ass
del .\temp\%subtitleTemp%01.ass
del .\temp\%subtitleTemp%02.ass
del .\temp\%videoNoSubtitle%.mkv
del %fullpath%
