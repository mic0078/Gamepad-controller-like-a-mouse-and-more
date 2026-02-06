@echo off
setlocal

rem Installer for Controller Configurator
rem Creates C:\Controller_Configurator, copies the PS1 and VBS script there and creates a desktop shortcut

set "INSTALLDIR=C:\Controller_Configurator"

echo Creating installation directory: %INSTALLDIR%
if not exist "%INSTALLDIR%" (
    mkdir "%INSTALLDIR%"
    if errorlevel 1 (
        echo Failed to create %INSTALLDIR%. Try running this installer as Administrator.
        pause
        exit /b 1
    )
)

echo Checking installer folder for required files...
if not exist "%~dp0Kontroler_Konfigurator.ps1" (
    echo Kontroler_Konfigurator.ps1 not found next to this installer.
    pause
    exit /b 1
)
if not exist "%~dp0run_controller_gui.vbs" (
    echo run_controller_gui.vbs not found next to this installer.
    pause
    exit /b 1
)

echo Copying script to %INSTALLDIR% (UTF-8)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "[System.IO.File]::WriteAllText('%INSTALLDIR%\Kontroler_Konfigurator.ps1', [System.IO.File]::ReadAllText('%~dp0Kontroler_Konfigurator.ps1', [System.Text.Encoding]::UTF8), [System.Text.Encoding]::UTF8)"
if errorlevel 1 (
    echo Failed to copy the script with UTF-8 encoding.
    pause
    exit /b 1
)

echo Creating launcher VBS in %INSTALLDIR%...
(
    echo Set oShell = CreateObject("Shell.Application"^)
    echo oShell.ShellExecute "powershell.exe", "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""%INSTALLDIR%\Kontroler_Konfigurator.ps1""", "", "open", 0
) > "%INSTALLDIR%\run_controller_gui.vbs"
if exist "%INSTALLDIR%\run_controller_gui.vbs" (
    echo Launcher VBS created successfully.
) else (
    echo Failed to create launcher VBS!
    pause
    exit /b 1
)

echo Creating desktop shortcut via temporary VBS...
set "VBSFILE=%TEMP%\create_shortcut.vbs"
(
    echo Set WshShell = WScript.CreateObject("WScript.Shell"^)
    echo desktop = WshShell.SpecialFolders("Desktop"^)
    echo lnk = desktop ^& "\Controller Configurator.lnk"
    echo Set Shortcut = WshShell.CreateShortcut(lnk^)
    echo Shortcut.TargetPath = "%INSTALLDIR%\run_controller_gui.vbs"
    echo Shortcut.Arguments = ""
    echo Shortcut.WorkingDirectory = "%INSTALLDIR%"
    echo Shortcut.IconLocation = "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe,0"
    echo Shortcut.Save
) > "%VBSFILE%"

cscript //nologo "%VBSFILE%" 1>nul 2>nul
if errorlevel 1 (
    echo Warning: could not create shortcut. You can create a shortcut manually pointing to:
    echo %INSTALLDIR%\run_controller_gui.vbs
    pause
    exit /b 0
)

del "%VBSFILE%" >nul 2>&1

echo Installation complete.
echo Script installed to %INSTALLDIR% and shortcut placed on desktop.
pause
endlocal
