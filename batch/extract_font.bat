@echo off
for /f "delims=|" %%f in ('dir /b .\source\') do start cmd /k .\lib\fonts.bat ".\source\%%~f"
exit
