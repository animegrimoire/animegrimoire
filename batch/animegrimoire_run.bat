@echo off

for /f "delims=|" %%f in ('dir /b .\source\') do start cmd /k .\animegrimoire.bat ".\source\%%~nxf"

exit