@echo off
color 0a
set ffmpeg=.\lib\ffmpeg
TITLE Extract Fonts
if not exist .\fonts mkdir .\fonts
%ffmpeg% -dump_attachment:t "" -i "%~f1" -y
move *.*tf .\fonts
move *.*TF .\fonts
exit
