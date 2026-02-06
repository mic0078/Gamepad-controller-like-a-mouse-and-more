Set WshShell = CreateObject("WScript.Shell")
WshShell.Run "powershell -NoProfile -ExecutionPolicy Bypass -File \"Kontroler_Konfigurator.ps1\"", 0, False
