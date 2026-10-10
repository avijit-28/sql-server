@echo off
echo Stopping SQL Git Auto-Push Watcher...
powershell -Command "Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like '*sql server\auto_push_on_exit.ps1*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force; Write-Host 'Stopped SQL watcher process ID:' $_.ProcessId }"
echo Done.
pause
