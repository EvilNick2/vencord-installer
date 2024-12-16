@echo off
setlocal

echo Installing Git...
winget install -e --id Git.Git

echo Installing Node.js...
winget install -e --id OpenJS.NodeJS

echo Downloading vencord-windows.sh...
powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/EvilNick2/vencord-installer/main/vencord-windows.sh' -OutFile 'vencord-windows.sh'"

start "" "C:\Program Files\Git\git-bash.exe" -c "bash vencord-windows.sh"

echo Deleting setup script...
del "%~f0"

endlocal
exit