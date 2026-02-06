@echo off
setlocal

rem User installer for Controller Configurator (no admin required)
rem Installs to %LOCALAPPDATA%\Controller_Configurator and creates a desktop shortcut

set "INSTALLDIR=%LOCALAPPDATA%\Controller_Configurator"

echo Creating installation directory: %INSTALLDIR%
if not exist "%INSTALLDIR%" (
    mkdir "%INSTALLDIR%"
    if errorlevel 1 (
        echo Failed to create %INSTALLDIR%.
        pause
        exit /b 1
    )
)

echo Copying script to %INSTALLDIR%...
if exist "%~dp0Kontroler_Konfigurator.ps1" (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "[System.IO.File]::WriteAllText('%INSTALLDIR%\Kontroler_Konfigurator.ps1', [System.IO.File]::ReadAllText('%~dp0Kontroler_Konfigurator.ps1', [System.Text.Encoding]::UTF8), [System.Text.Encoding]::UTF8)"
    if errorlevel 1 (
        echo Failed to copy the script with UTF-8 encoding. Ensure Kontroler_Konfigurator.ps1 is in the same folder as this installer.
        pause
        exit /b 1
    )
) else (
    echo Kontroler_Konfigurator.ps1 not found next to this installer.
    pause
    exit /b 1
)

echo Creating desktop shortcut via temporary VBS...
set "VBSFILE=%TEMP%\create_shortcut_user.vbs"
(
    echo Set WshShell = WScript.CreateObject("WScript.Shell"^)
    echo desktop = WshShell.SpecialFolders("Desktop"^)
    echo lnk = desktop ^& "\Controller Configurator.lnk"
    echo Set Shortcut = WshShell.CreateShortcut(lnk^)
    echo Shortcut.TargetPath = "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
    echo Shortcut.Arguments = "-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File ""%INSTALLDIR%\Kontroler_Konfigurator.ps1"""
    echo Shortcut.WorkingDirectory = "%INSTALLDIR%"
    echo Shortcut.IconLocation = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe,0"
    echo Shortcut.Save
) > "%VBSFILE%"

cscript //nologo "%VBSFILE%" 1>nul 2>nul
if errorlevel 1 (
    echo Warning: could not create shortcut. You can create a shortcut manually pointing to:
    echo %INSTALLDIR%\Kontroler_Konfigurator.ps1
    pause
    exit /b 0
)

del "%VBSFILE%" >nul 2>&1

echo Installation complete.
echo Script installed to %INSTALLDIR% and shortcut placed on desktop.
pause
endlocal
