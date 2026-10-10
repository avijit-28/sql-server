Set WshShell = CreateObject("WScript.Shell")
' Runs the SQL PowerShell watcher silently with hidden window
WshShell.Run "powershell.exe -ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File ""D:\All\sql server\auto_push_on_exit.ps1""", 0, False
