@echo off
setlocal

echo Installing Git...
winget install -e --id Git.Git

echo Installing Node.js...
winget install -e --id OpenJS.NodeJS

start "" "C:\Program Files\Git\git-bash.exe" -c "bash vencord-windows.sh"

endlocal
exit