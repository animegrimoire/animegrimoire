@echo off
for /f "delims=|" %%f in ('dir /b .\source\') do start cmd /k .\lib\animegrimoire.bat ".\source\%%~nxf"
exit
