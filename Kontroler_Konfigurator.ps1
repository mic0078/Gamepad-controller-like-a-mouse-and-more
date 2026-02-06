Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# === UKRYCIE KONSOLI POWERSHELL ===
Add-Type -Name Win32 -Namespace ControllerGUI -MemberDefinition @'
[DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
'@ -ErrorAction SilentlyContinue

# Ukryj okno konsoli
try { [ControllerGUI.Win32]::ShowWindow([ControllerGUI.Win32]::GetConsoleWindow(), 0) | Out-Null } catch {}

# === KONFIGURACJA DOMYŚLNA ===
$global:Config = @{
    # Czułość
    CursorSpeed = 8
    ScrollSpeed = 300
    Deadzone = 10000
    SwapSticks = $false  # False = Lewy:Kursor/Prawy:Scroll, True = Lewy:Scroll/Prawy:Kursor
    
    # Przypisania przycisków
    ButtonA = "LeftClick"
    ButtonB = "RightClick"
    ButtonX = "ShowDesktop"
    ButtonY = "Exit"
    ButtonLB = "Copy"
    ButtonRB = "Paste"
    ButtonStart = "StartMenu"
    ButtonBack = "AltTab"
    ButtonLStick = "MiddleClick"
    ButtonRStick = "Refresh"
    DPadUp = "VolumeUp"
    DPadDown = "VolumeDown"
    DPadLeft = "SeekBack5s"
    DPadRight = "SeekForward5s"
    LeftTrigger = "None"
    RightTrigger = "None"
}

# === ŚCIEŻKA KONFIGURACJI (użyj ścieżki skryptu) ===
# Użyj $PSScriptRoot gdy skrypt jest uruchamiany z pliku, w przeciwnym razie wyciągnij ścieżkę z MyInvocation
if ($PSCommandPath) {
    $global:ScriptDir = Split-Path -Parent $PSCommandPath
} elseif ($PSScriptRoot) {
    $global:ScriptDir = $PSScriptRoot
} else {
    $global:ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
}
# Ustaw ścieżkę do pliku konfiguracji w katalogu, z którego pochodzi skrypt
$global:ConfigPath = Join-Path $global:ScriptDir "ControllerConfig.json"

# === OPCJONALNA INSTALACJA DO STAŁEGO KATALOGU ===
# Jeśli użytkownik chce, skrypt utworzy folder instalacyjny i skopiuje sam siebie tam,
# a plik konfiguracji będzie zapisywany w tym katalogu.
$installDir = "C:\Controller_Configurator"
try {
    if (-not (Test-Path $installDir)) {
        New-Item -Path $installDir -ItemType Directory -Force | Out-Null
        Write-Host "ℹ Utworzono katalog instalacyjny: $installDir" -ForegroundColor Cyan
    }

    # Ścieżka do aktualnego pliku skryptu
    if ($PSCommandPath) { $currentScriptFile = $PSCommandPath } else { $currentScriptFile = $MyInvocation.MyCommand.Definition }
    $destScript = Join-Path $installDir (Split-Path -Leaf $currentScriptFile)

    if ($currentScriptFile -and ($currentScriptFile -ne $destScript)) {
        try {
            Copy-Item -Path $currentScriptFile -Destination $destScript -Force -ErrorAction Stop
            Write-Host "ℹ Skopiowano skrypt do: $destScript" -ForegroundColor Cyan
        } catch {
            # Użyj ${installDir} aby uniknąć problemów z interpolacją i wypisz wyjątek jako osobny argument
            Write-Host "⚠ Nie udało się skopiować skryptu do ${installDir}:" -ForegroundColor Yellow
            Write-Host $_ -ForegroundColor Yellow
        }
    }

    # Zapisuj konfigurację w katalogu instalacyjnym (nadpisze wcześniejsze ustawienie)
    $global:ScriptDir = $installDir
    $global:ConfigPath = Join-Path $global:ScriptDir "ControllerConfig.json"
} catch {
    Write-Host "✗ Błąd podczas przygotowywania katalogu instalacyjnego: $_" -ForegroundColor Red
}

# === FUNKCJE WINDOWS DOSTĘPNE DO PRZYPISANIA ===
$global:AvailableFunctions = [ordered]@{
    # === BRAK AKCJI ===
    "None" = "───────────  BRAK AKCJI  ───────────"
    
    # === MYSZ ===
    "LeftClick" = "🖱️ Lewy przycisk myszy"
    "RightClick" = "🖱️ Prawy przycisk myszy"
    "MiddleClick" = "🖱️ Środkowy przycisk myszy"
    "DoubleClick" = "🖱️ Podwójne kliknięcie"
    
    # === PODSTAWOWE KLAWISZE ===
    "Enter" = "⏎ Enter"
    "Escape" = "⎋ Escape"
    "Tab" = "⇥ Tab"
    "Space" = "␣ Spacja"
    "Backspace" = "⌫ Backspace"
    "Delete" = "⌦ Delete"
    
    # === STRZAŁKI ===
    "Key_Up" = "↑ Strzałka w górę"
    "Key_Down" = "↓ Strzałka w dół"
    "Key_Left" = "← Strzałka w lewo"
    "Key_Right" = "→ Strzałka w prawo"
    
    # === LITERY A-Z ===
    "Key_A" = "🔤 A"
    "Key_B" = "🔤 B"
    "Key_C" = "🔤 C"
    "Key_D" = "🔤 D"
    "Key_E" = "🔤 E"
    "Key_F" = "🔤 F"
    "Key_G" = "🔤 G"
    "Key_H" = "🔤 H"
    "Key_I" = "🔤 I"
    "Key_J" = "🔤 J"
    "Key_K" = "🔤 K"
    "Key_L" = "🔤 L"
    "Key_M" = "🔤 M"
    "Key_N" = "🔤 N"
    "Key_O" = "🔤 O"
    "Key_P" = "🔤 P"
    "Key_Q" = "🔤 Q"
    "Key_R" = "🔤 R"
    "Key_S" = "🔤 S"
    "Key_T" = "🔤 T"
    "Key_U" = "🔤 U"
    "Key_V" = "🔤 V"
    "Key_W" = "🔤 W"
    "Key_X" = "🔤 X"
    "Key_Y" = "🔤 Y"
    "Key_Z" = "🔤 Z"
    
    # === CYFRY 0-9 ===
    "Key_0" = "🔢 0"
    "Key_1" = "🔢 1"
    "Key_2" = "🔢 2"
    "Key_3" = "🔢 3"
    "Key_4" = "🔢 4"
    "Key_5" = "🔢 5"
    "Key_6" = "🔢 6"
    "Key_7" = "🔢 7"
    "Key_8" = "🔢 8"
    "Key_9" = "🔢 9"
    
    # === KLAWISZE FUNKCYJNE F1-F12 ===
    "Key_F1" = "⌨️ F1"
    "Key_F2" = "⌨️ F2"
    "Key_F3" = "⌨️ F3"
    "Key_F4" = "⌨️ F4"
    "Key_F5" = "⌨️ F5"
    "Key_F6" = "⌨️ F6"
    "Key_F7" = "⌨️ F7"
    "Key_F8" = "⌨️ F8"
    "Key_F9" = "⌨️ F9"
    "Key_F10" = "⌨️ F10"
    "Key_F11" = "⌨️ F11"
    "Key_F12" = "⌨️ F12"
    
    # === MODYFIKATORY ===
    "Key_LShift" = "⇧ Lewy Shift"
    "Key_RShift" = "⇧ Prawy Shift"
    "Key_LControl" = "⌃ Lewy Control"
    "Key_RControl" = "⌃ Prawy Control"
    "Key_LAlt" = "⎇ Lewy Alt"
    "Key_RAlt" = "⎇ Prawy Alt"
    "Key_LWin" = "⊞ Lewy Win"
    "Key_RWin" = "⊞ Prawy Win"
    
    # === NAWIGACJA ===
    "Key_Home" = "⇱ Home"
    "Key_End" = "⇲ End"
    "Key_PageUp" = "⇞ Page Up"
    "Key_PageDown" = "⇟ Page Down"
    "Key_Insert" = "⎀ Insert"
    
    # === KLAWISZE BLOKUJĄCE ===
    "Key_CapsLock" = "⇪ Caps Lock"
    "Key_NumLock" = "⇭ Num Lock"
    "Key_ScrollLock" = "⤓ Scroll Lock"
    "Key_Pause" = "⎉ Pause/Break"
    "Key_PrintScreen" = "🖨️ Print Screen"
    
    # === NUMPAD 0-9 ===
    "Key_Numpad0" = "🔢 Numpad 0"
    "Key_Numpad1" = "🔢 Numpad 1"
    "Key_Numpad2" = "🔢 Numpad 2"
    "Key_Numpad3" = "🔢 Numpad 3"
    "Key_Numpad4" = "🔢 Numpad 4"
    "Key_Numpad5" = "🔢 Numpad 5"
    "Key_Numpad6" = "🔢 Numpad 6"
    "Key_Numpad7" = "🔢 Numpad 7"
    "Key_Numpad8" = "🔢 Numpad 8"
    "Key_Numpad9" = "🔢 Numpad 9"
    
    # === NUMPAD OPERACJE ===
    "Key_NumpadAdd" = "➕ Numpad +"
    "Key_NumpadSubtract" = "➖ Numpad -"
    "Key_NumpadMultiply" = "✖️ Numpad *"
    "Key_NumpadDivide" = "➗ Numpad /"
    "Key_NumpadDecimal" = "◦ Numpad ."
    "Key_NumpadEnter" = "⏎ Numpad Enter"
    
    # === ZNAKI SPECJALNE ===
    "Key_Semicolon" = '; Średnik'
    "Key_Equals" = '= Równa się'
    "Key_Comma" = ', Przecinek'
    "Key_Minus" = '- Minus'
    "Key_Period" = '. Kropka'
    "Key_Slash" = '/ Slash'
    "Key_Backquote" = '` Tylda/Backtick'
    "Key_LeftBracket" = '[ Lewy nawias'
    "Key_Backslash" = '\ Backslash'
    "Key_RightBracket" = '] Prawy nawias'
    "Key_Quote" = "' Apostrof"
    
    # === SKRÓTY EDYCJI ===
    "Copy" = "📋 Kopiuj (Ctrl+C)"
    "Paste" = "📋 Wklej (Ctrl+V)"
    "Cut" = "✂️ Wytnij (Ctrl+X)"
    "Undo" = "↶ Cofnij (Ctrl+Z)"
    "Redo" = "↷ Ponów (Ctrl+Y)"
    "SelectAll" = "📄 Zaznacz wszystko (Ctrl+A)"
    "Save" = "💾 Zapisz (Ctrl+S)"
    "Find" = "🔍 Znajdź (Ctrl+F)"
    
    # === SKRÓTY WINDOWS ===
    "StartMenu" = "⊞ Menu Start"
    "ShowDesktop" = "🖥️ Pokaż pulpit (Win+D)"
    "TaskView" = "🗔 Widok zadań (Win+Tab)"
    "AltTab" = "⇄ Przełącz okna (Alt+Tab)"
    "CloseWindow" = "✖️ Zamknij okno (Alt+F4)"
    "MinimizeAll" = "🗕 Minimalizuj wszystko (Win+M)"
    "Explorer" = "📁 Eksplorator (Win+E)"
    "Run" = "▶️ Uruchom (Win+R)"
    "Screenshot" = "📸 Zrzut ekranu (Win+Shift+S)"
    "LockPC" = "🔒 Zablokuj PC (Win+L)"
    "Refresh" = "🔄 Odśwież (F5)"
    
    # === MULTIMEDIA ===
    "VolumeUp" = "🔊 Głośność +"
    "VolumeDown" = "🔉 Głośność -"
    "VolumeMute" = "🔇 Wycisz"
    "MediaPlay" = "⏯️ Odtwórz/Pauza"
    "MediaNext" = "⏭️ Następny utwór"
    "MediaPrevious" = "⏮️ Poprzedni utwór"
    
    # === PRZEGLĄDARKA ===
    "OpenBrowser" = "🌐 Otwórz przeglądarkę"
    "BrowserBack" = "◀️ Wstecz (przeglądarka)"
    "BrowserForward" = "▶️ Do przodu (przeglądarka)"
    "SeekBack5s" = "⏪ Przewiń -5s"
    "SeekForward5s" = "⏩ Przewiń +5s"
    
    # === INNE ===
    "OpenEmail" = "✉️ Otwórz klienta poczty"
    
    # === WYJŚCIE ===
    "Exit" = "🚪 Wyjście ze skryptu"
}

# === FUNKCJE POMOCNICZE ===
function Load-Config {
    if (Test-Path $global:ConfigPath) {
        try {
            $json = Get-Content $global:ConfigPath -Raw | ConvertFrom-Json
            foreach ($key in $json.PSObject.Properties.Name) {
                $global:Config[$key] = $json.$key
            }
            Write-Host "✓ Konfiguracja wczytana: $global:ConfigPath" -ForegroundColor Green
        }
        catch {
            Write-Host "⚠ Błąd wczytywania konfiguracji, używam domyślnej" -ForegroundColor Yellow
        }
    }
    else {
        # Jeśli plik nie istnieje — utwórz go od razu z domyślną konfiguracją
        try {
            $global:Config | ConvertTo-Json | Set-Content -Path $global:ConfigPath -Encoding UTF8
            Write-Host "ℹ Utworzono domyślny plik konfiguracji: $global:ConfigPath" -ForegroundColor Cyan
        } catch {
            Write-Host "✗ Nie udało się utworzyć pliku konfiguracji: $global:ConfigPath`n  $_" -ForegroundColor Red
        }
    }
}

function Save-Config {
    param($StatusLabel)
    
    try {
        $global:Config | ConvertTo-Json | Set-Content $global:ConfigPath
        
        if ($StatusLabel) {
            $StatusLabel.Text = "✓ Konfiguracja zapisana pomyślnie!"
            $StatusLabel.ForeColor = [System.Drawing.Color]::Green
        }
        
        Write-Host "✓ Konfiguracja zapisana: $global:ConfigPath" -ForegroundColor Green
    } catch {
        if ($StatusLabel) {
            $StatusLabel.Text = "✗ Błąd zapisu: $_"
            $StatusLabel.ForeColor = [System.Drawing.Color]::Red
        }
        Write-Error "Błąd zapisu konfiguracji: $_"
    }
}

# === GUI KONFIGURATOR ===
function Show-ConfigGUI {
    # Zmienne do śledzenia
    $script:controllerProcess = $null
    $script:controllerConfigFile = "$env:TEMP\ControllerLauncher_Active.ps1"
    
    $script:mainForm = New-Object System.Windows.Forms.Form
    $script:mainForm.Text = "Konfigurator Kontrolera Xbox"
    $script:mainForm.Size = New-Object System.Drawing.Size(900, 950)
    $script:mainForm.StartPosition = "CenterScreen"
    $script:mainForm.FormBorderStyle = "FixedDialog"
    $script:mainForm.MaximizeBox = $false
    $script:mainForm.MinimizeBox = $true
    $script:mainForm.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $script:mainForm.BackColor = [System.Drawing.Color]::White
    
    # Ikona okna
    try {
        $pwshPath = (Get-Command pwsh -ErrorAction SilentlyContinue).Source
        if ($pwshPath) {
            $script:mainForm.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($pwshPath)
        }
    } catch { }

    # === IKONA W ZASOBNIKU SYSTEMOWYM (TRAY) ===
    $script:trayIcon = New-Object System.Windows.Forms.NotifyIcon
    $script:trayIcon.Text = "Konfigurator Kontrolera Xbox"
    $script:trayIcon.Visible = $true  # WAŻNE: musi być true od początku!
    
    # Twórz ikonę programowo (jak w MiniWidget - działa niezawodnie)
    $bmp = New-Object System.Drawing.Bitmap(16, 16)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'
    $g.Clear([System.Drawing.Color]::FromArgb(0, 120, 215))  # Niebieski kolor
    $g.DrawString("X", (New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)), [System.Drawing.Brushes]::White, 1, 0)
    $g.Dispose()
    $script:trayIcon.Icon = [System.Drawing.Icon]::FromHandle($bmp.GetHicon())
    
    # Menu kontekstowe dla ikony tray
    $contextMenu = New-Object System.Windows.Forms.ContextMenuStrip
    
    $menuItemRestore = New-Object System.Windows.Forms.ToolStripMenuItem
    $menuItemRestore.Text = "Przywróć okno"
    $menuItemRestore.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $menuItemRestore.Add_Click({
        $script:mainForm.Show()
        $script:mainForm.WindowState = [System.Windows.Forms.FormWindowState]::Normal
        $script:mainForm.BringToFront()
        $script:mainForm.Activate()
    })
    $contextMenu.Items.Add($menuItemRestore) | Out-Null
    
    $menuItemSeparator = New-Object System.Windows.Forms.ToolStripSeparator
    $contextMenu.Items.Add($menuItemSeparator) | Out-Null
    
    $menuItemExit = New-Object System.Windows.Forms.ToolStripMenuItem
    $menuItemExit.Text = "Zamknij konfigurator"
    $menuItemExit.Add_Click({
        # Zamknij kontroler - zabij proces i wszystkie podprocesy
        if ($script:controllerProcess) {
            try {
                $procId = $script:controllerProcess.Id
                Start-Process -FilePath "taskkill" -ArgumentList "/F", "/T", "/PID", $procId -NoNewWindow -Wait -ErrorAction SilentlyContinue
            } catch { }
        }
        # Dodatkowo zabij wszystkie procesy pwsh z tego skryptu
        Get-Process pwsh -ErrorAction SilentlyContinue | Where-Object {
            try {
                $cmdLine = (Get-CimInstance Win32_Process -Filter "ProcessId = $($_.Id)" -ErrorAction SilentlyContinue).CommandLine
                $cmdLine -like "*ControllerLauncher_Active*"
            } catch { $false }
        } | ForEach-Object {
            try { Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue } catch { }
        }
        # Usuń temp plik
        $tempFile = "$env:TEMP\ControllerLauncher_Active.ps1"
        if (Test-Path $tempFile) { Remove-Item $tempFile -Force -ErrorAction SilentlyContinue }
        # Cleanup
        $script:trayIcon.Visible = $false
        $script:trayIcon.Dispose()
        # Całkowicie zakończ proces
        [Environment]::Exit(0)
    })
    $contextMenu.Items.Add($menuItemExit) | Out-Null
    
    $script:trayIcon.ContextMenuStrip = $contextMenu
    
    # Podwójne kliknięcie na ikonie tray - przywróć okno
    $script:trayIcon.Add_DoubleClick({
        $script:mainForm.Show()
        $script:mainForm.WindowState = [System.Windows.Forms.FormWindowState]::Normal
        $script:mainForm.BringToFront()
        $script:mainForm.Activate()
    })
    
    # Obsługa minimalizacji - ukryj okno (ikona tray pozostaje widoczna)
    $script:mainForm.Add_Resize({
        param($sender, $e)
        if ($script:mainForm.WindowState -eq [System.Windows.Forms.FormWindowState]::Minimized) {
            $script:mainForm.Hide()
            $script:trayIcon.ShowBalloonTip(2000, "Konfigurator kontrolera", "Kliknij dwukrotnie ikonę aby przywrócić.", [System.Windows.Forms.ToolTipIcon]::Info)
        }
    })

    $groupSensitivity = New-Object System.Windows.Forms.GroupBox
    $groupSensitivity.Text = "⚙ CZUŁOŚĆ KONTROLERA"
    $groupSensitivity.Location = New-Object System.Drawing.Point(20, 20)
    $groupSensitivity.Size = New-Object System.Drawing.Size(840, 230)
    $groupSensitivity.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $script:mainForm.Controls.Add($groupSensitivity)

    # Cursor Speed
    $labelCursor = New-Object System.Windows.Forms.Label
    $labelCursor.Text = "Szybkość kursora:"
    $labelCursor.Location = New-Object System.Drawing.Point(20, 35)
    $labelCursor.Size = New-Object System.Drawing.Size(180, 25)
    $labelCursor.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $groupSensitivity.Controls.Add($labelCursor)

    $sliderCursor = New-Object System.Windows.Forms.TrackBar
    $sliderCursor.Location = New-Object System.Drawing.Point(210, 30)
    $sliderCursor.Size = New-Object System.Drawing.Size(520, 45)
    $sliderCursor.Minimum = 1
    $sliderCursor.Maximum = 30
    $sliderCursor.Value = $global:Config.CursorSpeed
    $sliderCursor.TickFrequency = 5
    $groupSensitivity.Controls.Add($sliderCursor)

    $labelCursorValue = New-Object System.Windows.Forms.Label
    $labelCursorValue.Text = "$($global:Config.CursorSpeed)"
    $labelCursorValue.Location = New-Object System.Drawing.Point(750, 35)
    $labelCursorValue.Size = New-Object System.Drawing.Size(60, 25)
    $labelCursorValue.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $labelCursorValue.TextAlign = "MiddleCenter"
    $groupSensitivity.Controls.Add($labelCursorValue)

    $script:cursorLabel = $labelCursorValue
    $sliderCursor.Add_ValueChanged({
        try {
            if ($script:cursorLabel -and $this.Value) {
                $script:cursorLabel.Text = $this.Value.ToString()
                $global:Config.CursorSpeed = $this.Value
            }
        } catch { <# ignore #> }
    })

    # Scroll Speed
    $labelScroll = New-Object System.Windows.Forms.Label
    $labelScroll.Text = "Szybkość przewijania:"
    $labelScroll.Location = New-Object System.Drawing.Point(20, 75)
    $labelScroll.Size = New-Object System.Drawing.Size(180, 25)
    $labelScroll.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $groupSensitivity.Controls.Add($labelScroll)

    $sliderScroll = New-Object System.Windows.Forms.TrackBar
    $sliderScroll.Location = New-Object System.Drawing.Point(210, 70)
    $sliderScroll.Size = New-Object System.Drawing.Size(520, 45)
    $sliderScroll.Minimum = 100
    $sliderScroll.Maximum = 1000
    $sliderScroll.Value = $global:Config.ScrollSpeed
    $sliderScroll.TickFrequency = 100
    $groupSensitivity.Controls.Add($sliderScroll)

    $labelScrollValue = New-Object System.Windows.Forms.Label
    $labelScrollValue.Text = "$($global:Config.ScrollSpeed)"
    $labelScrollValue.Location = New-Object System.Drawing.Point(750, 75)
    $labelScrollValue.Size = New-Object System.Drawing.Size(60, 25)
    $labelScrollValue.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $labelScrollValue.TextAlign = "MiddleCenter"
    $groupSensitivity.Controls.Add($labelScrollValue)

    $script:scrollLabel = $labelScrollValue
    $sliderScroll.Add_ValueChanged({
        try {
            if ($script:scrollLabel -and $this.Value) {
                $script:scrollLabel.Text = $this.Value.ToString()
                $global:Config.ScrollSpeed = $this.Value
            }
        } catch { <# ignore #> }
    })

    # Deadzone
    $labelDeadzone = New-Object System.Windows.Forms.Label
    $labelDeadzone.Text = "Martwa strefa gałek:"
    $labelDeadzone.Location = New-Object System.Drawing.Point(20, 115)
    $labelDeadzone.Size = New-Object System.Drawing.Size(180, 25)
    $labelDeadzone.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $groupSensitivity.Controls.Add($labelDeadzone)

    $sliderDeadzone = New-Object System.Windows.Forms.TrackBar
    $sliderDeadzone.Location = New-Object System.Drawing.Point(210, 110)
    $sliderDeadzone.Size = New-Object System.Drawing.Size(520, 45)
    $sliderDeadzone.Minimum = 1000
    $sliderDeadzone.Maximum = 20000
    $sliderDeadzone.Value = $global:Config.Deadzone
    $sliderDeadzone.TickFrequency = 2000
    $groupSensitivity.Controls.Add($sliderDeadzone)

    $labelDeadzoneValue = New-Object System.Windows.Forms.Label
    $labelDeadzoneValue.Text = "$($global:Config.Deadzone)"
    $labelDeadzoneValue.Location = New-Object System.Drawing.Point(750, 115)
    $labelDeadzoneValue.Size = New-Object System.Drawing.Size(60, 25)
    $labelDeadzoneValue.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $labelDeadzoneValue.TextAlign = "MiddleCenter"
    $groupSensitivity.Controls.Add($labelDeadzoneValue)

    $script:deadzoneLabel = $labelDeadzoneValue
    $sliderDeadzone.Add_ValueChanged({
        try {
            if ($script:deadzoneLabel -and $this.Value) {
                $script:deadzoneLabel.Text = $this.Value.ToString()
                $global:Config.Deadzone = $this.Value
            }
        } catch { <# ignore #> }
    })

    # Zamiana funkcji drążków
    $labelSwapSticks = New-Object System.Windows.Forms.Label
    $labelSwapSticks.Text = "Funkcje drążków:"
    $labelSwapSticks.Location = New-Object System.Drawing.Point(20, 160)
    $labelSwapSticks.Size = New-Object System.Drawing.Size(180, 25)
    $labelSwapSticks.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $groupSensitivity.Controls.Add($labelSwapSticks)

    $comboSwapSticks = New-Object System.Windows.Forms.ComboBox
    $comboSwapSticks.Location = New-Object System.Drawing.Point(210, 160)
    $comboSwapSticks.Size = New-Object System.Drawing.Size(410, 28)
    $comboSwapSticks.DropDownStyle = "DropDownList"
    $comboSwapSticks.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $comboSwapSticks.Items.Add("🕹️ Lewy drążek = KURSOR, Prawy drążek = SCROLL") | Out-Null
    $comboSwapSticks.Items.Add("🕹️ Lewy drążek = SCROLL, Prawy drążek = KURSOR") | Out-Null
    
    if ($global:Config.SwapSticks -eq $true) {
        $comboSwapSticks.SelectedIndex = 1
    } else {
        $comboSwapSticks.SelectedIndex = 0
    }
    
    $comboSwapSticks.Add_SelectedIndexChanged({
        $global:Config.SwapSticks = ($comboSwapSticks.SelectedIndex -eq 1)
    })
    $groupSensitivity.Controls.Add($comboSwapSticks)

    $labelSwapInfo = New-Object System.Windows.Forms.Label
    $labelSwapInfo.Text = "💡 Zmień, który drążek kontroluje kursor, a który przewijanie"
    $labelSwapInfo.Location = New-Object System.Drawing.Point(210, 193)
    $labelSwapInfo.Size = New-Object System.Drawing.Size(600, 25)
    $labelSwapInfo.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Italic)
    $labelSwapInfo.ForeColor = [System.Drawing.Color]::Gray
    $groupSensitivity.Controls.Add($labelSwapInfo)

    # === SEKCJA: PRZYCISKI ===
    $groupButtons = New-Object System.Windows.Forms.GroupBox
    $groupButtons.Text = "🎮 PRZYPISANIA PRZYCISKÓW"
    $groupButtons.Location = New-Object System.Drawing.Point(20, 270)
    $groupButtons.Size = New-Object System.Drawing.Size(840, 530)
    $groupButtons.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $script:mainForm.Controls.Add($groupButtons)

    # Panel z przewijaniem
    $panelButtons = New-Object System.Windows.Forms.Panel
    $panelButtons.Location = New-Object System.Drawing.Point(10, 30)
    $panelButtons.Size = New-Object System.Drawing.Size(820, 490)
    $panelButtons.AutoScroll = $true
    $panelButtons.BorderStyle = "None"
    $groupButtons.Controls.Add($panelButtons)

    # Funkcja pomocnicza do tworzenia przycisku z combo box
    function Add-ButtonConfig($buttonName, $displayName, $yPosition) {
        $label = New-Object System.Windows.Forms.Label
        $label.Text = "${displayName}:"
        $label.Location = New-Object System.Drawing.Point(10, $yPosition)
        $label.Size = New-Object System.Drawing.Size(200, 25)
        $label.Font = New-Object System.Drawing.Font("Segoe UI", 10)
        $label.TextAlign = "MiddleLeft"
        $panelButtons.Controls.Add($label)

        $combo = New-Object System.Windows.Forms.ComboBox
        $combo.Location = New-Object System.Drawing.Point(220, $yPosition)
        $combo.Size = New-Object System.Drawing.Size(560, 28)
        $combo.DropDownStyle = "DropDownList"
        $combo.Font = New-Object System.Drawing.Font("Segoe UI", 10)
        
        foreach ($func in $global:AvailableFunctions.Keys) {
            $combo.Items.Add("$func - $($global:AvailableFunctions[$func])") | Out-Null
        }
        
        $currentFunc = $global:Config[$buttonName]
        $targetItem = "$currentFunc - $($global:AvailableFunctions[$currentFunc])"
        for ($i = 0; $i -lt $combo.Items.Count; $i++) {
            if ($combo.Items[$i] -eq $targetItem) {
                $combo.SelectedIndex = $i
                break
            }
        }
        
        $combo.Add_SelectedIndexChanged({
            if ($combo.SelectedItem) {
                $selected = $combo.SelectedItem.ToString() -split ' - ' | Select-Object -First 1
                $global:Config[$buttonName] = $selected
            }
        }.GetNewClosure())
        
        $panelButtons.Controls.Add($combo)
        return $yPosition + 35
    }

    $innerYPos = 10
    
    # Kategoria: Główne przyciski
    $labelCategory1 = New-Object System.Windows.Forms.Label
    $labelCategory1.Text = "═══ GŁÓWNE PRZYCISKI ═══"
    $labelCategory1.Location = New-Object System.Drawing.Point(10, $innerYPos)
    $labelCategory1.Size = New-Object System.Drawing.Size(780, 25)
    $labelCategory1.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $labelCategory1.ForeColor = [System.Drawing.Color]::DarkBlue
    $panelButtons.Controls.Add($labelCategory1)
    $innerYPos += 30
    
    $innerYPos = Add-ButtonConfig "ButtonA" "🅰 Przycisk A" $innerYPos
    $innerYPos = Add-ButtonConfig "ButtonB" "🅱 Przycisk B" $innerYPos
    $innerYPos = Add-ButtonConfig "ButtonX" "🅧 Przycisk X" $innerYPos
    $innerYPos = Add-ButtonConfig "ButtonY" "🅨 Przycisk Y" $innerYPos
    
    $innerYPos += 10
    
    # Kategoria: Bumpers & Triggers
    $labelCategory2 = New-Object System.Windows.Forms.Label
    $labelCategory2.Text = "═══ BUMPERS & TRIGGERS ═══"
    $labelCategory2.Location = New-Object System.Drawing.Point(10, $innerYPos)
    $labelCategory2.Size = New-Object System.Drawing.Size(780, 25)
    $labelCategory2.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $labelCategory2.ForeColor = [System.Drawing.Color]::DarkBlue
    $panelButtons.Controls.Add($labelCategory2)
    $innerYPos += 30
    
    $innerYPos = Add-ButtonConfig "ButtonLB" "LB (Lewy Bumper)" $innerYPos
    $innerYPos = Add-ButtonConfig "ButtonRB" "RB (Prawy Bumper)" $innerYPos
    $innerYPos = Add-ButtonConfig "LeftTrigger" "LT (Lewy Trigger)" $innerYPos
    $innerYPos = Add-ButtonConfig "RightTrigger" "RT (Prawy Trigger)" $innerYPos
    
    $innerYPos += 10
    
    # Kategoria: Stick Clicks
    $labelCategory3 = New-Object System.Windows.Forms.Label
    $labelCategory3.Text = "═══ KLIKNIĘCIA GAŁEK ═══"
    $labelCategory3.Location = New-Object System.Drawing.Point(10, $innerYPos)
    $labelCategory3.Size = New-Object System.Drawing.Size(780, 25)
    $labelCategory3.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $labelCategory3.ForeColor = [System.Drawing.Color]::DarkBlue
    $panelButtons.Controls.Add($labelCategory3)
    $innerYPos += 30
    
    $innerYPos = Add-ButtonConfig "ButtonLStick" "L3 (Kliknięcie lewej gałki)" $innerYPos
    $innerYPos = Add-ButtonConfig "ButtonRStick" "R3 (Kliknięcie prawej gałki)" $innerYPos
    
    $innerYPos += 10
    
    # Kategoria: Menu
    $labelCategory4 = New-Object System.Windows.Forms.Label
    $labelCategory4.Text = "═══ PRZYCISKI MENU ═══"
    $labelCategory4.Location = New-Object System.Drawing.Point(10, $innerYPos)
    $labelCategory4.Size = New-Object System.Drawing.Size(780, 25)
    $labelCategory4.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $labelCategory4.ForeColor = [System.Drawing.Color]::DarkBlue
    $panelButtons.Controls.Add($labelCategory4)
    $innerYPos += 30
    
    $innerYPos = Add-ButtonConfig "ButtonStart" "⏵ Start / Menu" $innerYPos
    $innerYPos = Add-ButtonConfig "ButtonBack" "⏴ Back / Select" $innerYPos
    
    $innerYPos += 10
    
    # Kategoria: D-Pad
    $labelCategory5 = New-Object System.Windows.Forms.Label
    $labelCategory5.Text = "═══ D-PAD (KRZYŻAK) ═══"
    $labelCategory5.Location = New-Object System.Drawing.Point(10, $innerYPos)
    $labelCategory5.Size = New-Object System.Drawing.Size(780, 25)
    $labelCategory5.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $labelCategory5.ForeColor = [System.Drawing.Color]::DarkBlue
    $panelButtons.Controls.Add($labelCategory5)
    $innerYPos += 30
    
    $innerYPos = Add-ButtonConfig "DPadUp" "⬆ D-Pad Góra" $innerYPos
    $innerYPos = Add-ButtonConfig "DPadDown" "⬇ D-Pad Dół" $innerYPos
    $innerYPos = Add-ButtonConfig "DPadLeft" "⬅ D-Pad Lewo" $innerYPos
    $innerYPos = Add-ButtonConfig "DPadRight" "➡ D-Pad Prawo" $innerYPos

    # === PASEK STATUSU ===
    $statusLabel = New-Object System.Windows.Forms.Label
    $statusLabel.Text = "Gotowy. Plik konfiguracji: $global:ConfigPath"
    $statusLabel.Location = New-Object System.Drawing.Point(40, 685)
    $statusLabel.Size = New-Object System.Drawing.Size(800, 25)
    $statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Italic)
    $statusLabel.ForeColor = [System.Drawing.Color]::Gray
    $statusLabel.TextAlign = "MiddleLeft"
    $script:mainForm.Controls.Add($statusLabel)

    # === PRZYCISKI AKCJI ===
    $buttonSave = New-Object System.Windows.Forms.Button
    $buttonSave.Text = "⏺ Zapisz konfigurację"
    $buttonSave.Location = New-Object System.Drawing.Point(40, 840)
    $buttonSave.Size = New-Object System.Drawing.Size(240, 45)
    $buttonSave.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
    $buttonSave.ForeColor = [System.Drawing.Color]::White
    $buttonSave.FlatStyle = "Flat"
    $buttonSave.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $buttonSave.Cursor = [System.Windows.Forms.Cursors]::Hand
    $buttonSave.Add_Click({ 
        try {
            # Zapisz konfigurację do pliku
            $global:Config | ConvertTo-Json | Set-Content $global:ConfigPath
            
            # Sprawdź czy kontroler jest uruchomiony
            $controllerRunning = $script:controllerProcess -and !$script:controllerProcess.HasExited
            
            if ($controllerRunning) {
                # Kontroler sam wykryje zmianę pliku i przeładuje ustawienia (auto-reload)
                $statusLabel.Text = "✓ Zapisano! Kontroler automatycznie zastosuje nowe ustawienia."
                $statusLabel.ForeColor = [System.Drawing.Color]::Green
            } else {
                $statusLabel.Text = "✓ Konfiguracja zapisana! Kliknij 'Uruchom' aby włączyć kontroler."
                $statusLabel.ForeColor = [System.Drawing.Color]::Green
            }
        } catch {
            $statusLabel.Text = "✗ Błąd: $_"
            $statusLabel.ForeColor = [System.Drawing.Color]::Red
        }
    }.GetNewClosure())
    $script:mainForm.Controls.Add($buttonSave)

    $buttonStart = New-Object System.Windows.Forms.Button
    $buttonStart.Text = "▶ URUCHOM KONTROLER"
    $buttonStart.Location = New-Object System.Drawing.Point(300, 840)
    $buttonStart.Size = New-Object System.Drawing.Size(280, 45)
    $buttonStart.BackColor = [System.Drawing.Color]::FromArgb(16, 124, 16)
    $buttonStart.ForeColor = [System.Drawing.Color]::White
    $buttonStart.FlatStyle = "Flat"
    $buttonStart.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $buttonStart.Cursor = [System.Windows.Forms.Cursors]::Hand
    $buttonStart.Add_Click({
        # Zamknij stary proces jeśli istnieje
        if ($script:controllerProcess -and !$script:controllerProcess.HasExited) {
            try {
                $script:controllerProcess.Kill()
                $script:controllerProcess.WaitForExit(1000)
            } catch { }
        }
        
        # Zapisz konfigurację
        $global:Config | ConvertTo-Json | Set-Content $global:ConfigPath
        $statusLabel.Text = "✓ Konfiguracja zapisana. Uruchamiam kontroler..."
        $statusLabel.ForeColor = [System.Drawing.Color]::Green
        
        # Użyj stałej nazwy pliku (nadpisze stary)
        $tempScript = "$env:TEMP\ControllerLauncher_Active.ps1"
        
        # Przygotuj pełny skrypt z funkcją Start-Controller
        $launcherScript = @'
# Wczytaj konfigurację
# Placeholder zostanie zastąpiony rzeczywistą ścieżką $global:ConfigPath przy zapisie
$ConfigPath = "__CONFIG_PATH__"
Write-Host "Szukam konfiguracji w: $ConfigPath" -ForegroundColor Cyan
Write-Host "Plik istnieje: $(Test-Path $ConfigPath)" -ForegroundColor Cyan
if (Test-Path $ConfigPath) {
    $json = Get-Content $ConfigPath -Raw | ConvertFrom-Json
    $global:Config = @{}
    foreach ($prop in $json.PSObject.Properties) {
        $global:Config[$prop.Name] = $prop.Value
    }
    Write-Host "✓ Konfiguracja wczytana z pliku: $ConfigPath" -ForegroundColor Green
} else {
    Write-Host "⚠ Brak pliku konfiguracji pod: $ConfigPath, używam domyślnej" -ForegroundColor Yellow
    $global:Config = @{
        CursorSpeed = 8
        ScrollSpeed = 300
        Deadzone = 10000
        SwapSticks = $false
        ButtonA = "LeftClick"
        ButtonB = "RightClick"
        ButtonX = "ShowDesktop"
        ButtonY = "Exit"
        ButtonLB = "Copy"
        ButtonRB = "Paste"
        ButtonStart = "StartMenu"
        ButtonBack = "AltTab"
        ButtonLStick = "MiddleClick"
        ButtonRStick = "Refresh"
        DPadUp = "VolumeUp"
        DPadDown = "VolumeDown"
        DPadLeft = "SeekBack5s"
        DPadRight = "SeekForward5s"
        LeftTrigger = "None"
        RightTrigger = "None"
    }
}

# Funkcja Start-Controller
function Start-Controller {
    Write-Host "`n╔══════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║   KONTROLER XBOX - TRYB AKTYWNY        ║" -ForegroundColor Cyan
    Write-Host "║   Auto-reload konfiguracji co 1s       ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host "`nWciśnij przycisk przypisany do 'Exit' aby zakończyć.`n" -ForegroundColor Yellow

$csharpCode = @"
using System;
using System.Runtime.InteropServices;
using System.Threading;
using System.Collections.Generic;
using System.IO;

namespace ControllerInput
{
    public class Gamepad
    {
        [DllImport("user32.dll")] static extern bool SetCursorPos(int X, int Y);
        [DllImport("user32.dll")] static extern bool GetCursorPos(out POINT lpPoint);
        [DllImport("user32.dll")] static extern void mouse_event(int dwFlags, int dx, int dy, int dwData, int dwExtraInfo);
        [DllImport("user32.dll")] static extern void keybd_event(byte bVk, byte bScan, int dwFlags, int dwExtraInfo);
        [DllImport("xinput1_4.dll")] static extern int XInputGetState(int dwUserIndex, ref XINPUT_STATE pState);

        public struct POINT { public int X, Y; }
        
        [StructLayout(LayoutKind.Sequential)]
        public struct XINPUT_STATE { public int dwPacketNumber; public XINPUT_GAMEPAD Gamepad; }
        
        [StructLayout(LayoutKind.Sequential)]
        public struct XINPUT_GAMEPAD {
            public ushort wButtons;
            public byte bLeftTrigger, bRightTrigger;
            public short sThumbLX, sThumbLY, sThumbRX, sThumbRY;
        }

        const int MOUSEEVENTF_LEFTDOWN = 0x02, MOUSEEVENTF_LEFTUP = 0x04;
        const int MOUSEEVENTF_RIGHTDOWN = 0x08, MOUSEEVENTF_RIGHTUP = 0x10;
        const int MOUSEEVENTF_MIDDLEDOWN = 0x20, MOUSEEVENTF_MIDDLEUP = 0x40;
        const int MOUSEEVENTF_WHEEL = 0x800;
        const int KEYEVENTF_KEYUP = 0x02;

        const byte VK_LWIN = 0x5B, VK_RWIN = 0x5C, VK_CONTROL = 0x11, VK_LCONTROL = 0xA2, VK_RCONTROL = 0xA3;
        const byte VK_SHIFT = 0x10, VK_LSHIFT = 0xA0, VK_RSHIFT = 0xA1;
        const byte VK_MENU = 0x12, VK_LMENU = 0xA4, VK_RMENU = 0xA5;
        const byte VK_TAB = 0x09, VK_RETURN = 0x0D, VK_ESCAPE = 0x1B, VK_DELETE = 0x2E, VK_BACK = 0x08;
        const byte VK_SPACE = 0x20, VK_INSERT = 0x2D, VK_HOME = 0x24, VK_END = 0x23;
        const byte VK_PRIOR = 0x21, VK_NEXT = 0x22; // PageUp, PageDown
        const byte VK_SNAPSHOT = 0x2C, VK_SCROLL = 0x91, VK_PAUSE = 0x13;
        const byte VK_CAPITAL = 0x14, VK_NUMLOCK = 0x90;
        const byte VK_F1 = 0x70, VK_F2 = 0x71, VK_F3 = 0x72, VK_F4 = 0x73, VK_F5 = 0x74, VK_F6 = 0x75;
        const byte VK_F7 = 0x76, VK_F8 = 0x77, VK_F9 = 0x78, VK_F10 = 0x79, VK_F11 = 0x7A, VK_F12 = 0x7B;
        const byte VK_A = 0x41, VK_B = 0x42, VK_C = 0x43, VK_D = 0x44, VK_E = 0x45, VK_F = 0x46;
        const byte VK_G = 0x47, VK_H = 0x48, VK_I = 0x49, VK_J = 0x4A, VK_K = 0x4B, VK_L = 0x4C;
        const byte VK_M = 0x4D, VK_N = 0x4E, VK_O = 0x4F, VK_P = 0x50, VK_Q = 0x51, VK_R = 0x52;
        const byte VK_S = 0x53, VK_T = 0x54, VK_U = 0x55, VK_V = 0x56, VK_W = 0x57, VK_X = 0x58;
        const byte VK_Y = 0x59, VK_Z = 0x5A;
        const byte VK_0 = 0x30, VK_1 = 0x31, VK_2 = 0x32, VK_3 = 0x33, VK_4 = 0x34;
        const byte VK_5 = 0x35, VK_6 = 0x36, VK_7 = 0x37, VK_8 = 0x38, VK_9 = 0x39;
        const byte VK_NUMPAD0 = 0x60, VK_NUMPAD1 = 0x61, VK_NUMPAD2 = 0x62, VK_NUMPAD3 = 0x63;
        const byte VK_NUMPAD4 = 0x64, VK_NUMPAD5 = 0x65, VK_NUMPAD6 = 0x66, VK_NUMPAD7 = 0x67;
        const byte VK_NUMPAD8 = 0x68, VK_NUMPAD9 = 0x69;
        const byte VK_MULTIPLY = 0x6A, VK_ADD = 0x6B, VK_SUBTRACT = 0x6D;
        const byte VK_DECIMAL = 0x6E, VK_DIVIDE = 0x6F, VK_SEPARATOR = 0x6C; // Numpad Enter
        const byte VK_LEFT = 0x25, VK_UP = 0x26, VK_RIGHT = 0x27, VK_DOWN = 0x28;
        const byte VK_OEM_1 = 0xBA, VK_OEM_PLUS = 0xBB, VK_OEM_COMMA = 0xBC, VK_OEM_MINUS = 0xBD;
        const byte VK_OEM_PERIOD = 0xBE, VK_OEM_2 = 0xBF, VK_OEM_3 = 0xC0; // ; = , - . / `
        const byte VK_OEM_4 = 0xDB, VK_OEM_5 = 0xDC, VK_OEM_6 = 0xDD, VK_OEM_7 = 0xDE; // [ \ ] '
        const byte VK_VOLUME_UP = 0xAF, VK_VOLUME_DOWN = 0xAE, VK_VOLUME_MUTE = 0xAD;
        const byte VK_MEDIA_PLAY = 0xB3, VK_MEDIA_NEXT = 0xB0, VK_MEDIA_PREV = 0xB1;

        const int BTN_A = 0x1000, BTN_B = 0x2000, BTN_X = 0x4000, BTN_Y = 0x8000;
        const int BTN_LB = 0x0100, BTN_RB = 0x0200;
        const int BTN_LSTICK = 0x0040, BTN_RSTICK = 0x0080;
        const int BTN_START = 0x0010, BTN_BACK = 0x0020;
        const int DPAD_UP = 0x0001, DPAD_DOWN = 0x0002, DPAD_LEFT = 0x0004, DPAD_RIGHT = 0x0008;

        public static int DEADZONE = 10000;
        public static double SPEED = 8.0;
        public static int SCROLL_SPEED = 300;
        public static bool SWAP_STICKS = false;  // False = Lewy:Kursor/Prawy:Scroll, True = Lewy:Scroll/Prawy:Kursor
        public static Dictionary<string, string> ButtonMapping = new Dictionary<string, string>();
        
        // Auto-reload config
        public static string ConfigFilePath = "";
        static DateTime lastConfigModified = DateTime.MinValue;
        static DateTime lastConfigCheck = DateTime.MinValue;

        static bool[] wasPressed = new bool[16];
        static bool altHeld = false, winHeld = false;
        static double accX = 0, accY = 0;

        static void KeyDown(byte vk) { keybd_event(vk, 0, 0, 0); }
        static void KeyUp(byte vk) { keybd_event(vk, 0, KEYEVENTF_KEYUP, 0); }
        
        static void Tap(byte vk) {
            KeyDown(vk);
            Thread.Sleep(40);
            KeyUp(vk);
        }
        
        static void Combo(byte mod, byte key) {
            KeyDown(mod);
            Thread.Sleep(30);
            KeyDown(key);
            Thread.Sleep(50);
            KeyUp(key);
            Thread.Sleep(30);
            KeyUp(mod);
        }

        static void Combo3(byte m1, byte m2, byte key) {
            KeyDown(m1); Thread.Sleep(20);
            KeyDown(m2); Thread.Sleep(20);
            KeyDown(key); Thread.Sleep(50);
            KeyUp(key); Thread.Sleep(20);
            KeyUp(m2); Thread.Sleep(20);
            KeyUp(m1);
        }
        
        // Sprawdza czy plik konfiguracji się zmienił i zwraca true jeśli tak
        public static bool CheckConfigChanged() {
            if (string.IsNullOrEmpty(ConfigFilePath)) return false;
            
            // Sprawdzaj co sekundę
            if ((DateTime.Now - lastConfigCheck).TotalSeconds < 1) return false;
            lastConfigCheck = DateTime.Now;
            
            try {
                if (!File.Exists(ConfigFilePath)) return false;
                DateTime modified = File.GetLastWriteTime(ConfigFilePath);
                if (modified > lastConfigModified) {
                    lastConfigModified = modified;
                    return true;
                }
            } catch { }
            return false;
        }
        
        public static void UpdateLastModified() {
            if (!string.IsNullOrEmpty(ConfigFilePath) && File.Exists(ConfigFilePath)) {
                lastConfigModified = File.GetLastWriteTime(ConfigFilePath);
            }
        }

        static string GetAction(string button) {
            string action;
            if (ButtonMapping.TryGetValue(button, out action)) return action ?? "None";
            return "None";
        }

        static void DoAction(string action, int idx, bool pressed)
        {
            if (string.IsNullOrEmpty(action) || action == "None" || action == "Exit") {
                wasPressed[idx] = pressed;
                return;
            }

            bool was = wasPressed[idx];

            // KLIKNIĘCIA MYSZY
            if (action == "LeftClick") {
                if (pressed && !was) mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
                else if (!pressed && was) mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
                wasPressed[idx] = pressed;
                return;
            }
            if (action == "RightClick") {
                if (pressed && !was) mouse_event(MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0);
                else if (!pressed && was) mouse_event(MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0);
                wasPressed[idx] = pressed;
                return;
            }
            if (action == "MiddleClick") {
                if (pressed && !was) mouse_event(MOUSEEVENTF_MIDDLEDOWN, 0, 0, 0, 0);
                else if (!pressed && was) mouse_event(MOUSEEVENTF_MIDDLEUP, 0, 0, 0, 0);
                wasPressed[idx] = pressed;
                return;
            }

            // ALT+TAB
            if (action == "AltTab") {
                if (pressed && !was) {
                    if (!altHeld) { KeyDown(VK_MENU); altHeld = true; Thread.Sleep(30); }
                    Tap(VK_TAB);
                }
                else if (!pressed && was && altHeld) {
                    KeyUp(VK_MENU); altHeld = false;
                }
                wasPressed[idx] = pressed;
                return;
            }

            // WIN+TAB
            if (action == "TaskView") {
                if (pressed && !was) {
                    if (!winHeld) { KeyDown(VK_LWIN); winHeld = true; Thread.Sleep(30); }
                    Tap(VK_TAB);
                }
                else if (!pressed && was && winHeld) {
                    KeyUp(VK_LWIN); winHeld = false;
                }
                wasPressed[idx] = pressed;
                return;
            }

            // POZOSTAŁE - akcje jednorazowe (TAP) i przytrzymanie (HOLD)
            if (pressed && !was) {
                switch (action) {
                    case "DoubleClick":
                        mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
                        Thread.Sleep(20);
                        mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
                        Thread.Sleep(80);
                        mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
                        Thread.Sleep(20);
                        mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
                        break;
                    case "Copy": Combo(VK_CONTROL, VK_C); break;
                    case "Paste": Combo(VK_CONTROL, VK_V); break;
                    case "Cut": Combo(VK_CONTROL, VK_X); break;
                    case "Undo": Combo(VK_CONTROL, VK_Z); break;
                    case "Redo": Combo(VK_CONTROL, VK_Y); break;
                    case "SelectAll": Combo(VK_CONTROL, VK_A); break;
                    case "Save": Combo(VK_CONTROL, VK_S); break;
                    case "Find": Combo(VK_CONTROL, VK_F); break;
                    case "ShowDesktop": Combo(VK_LWIN, VK_D); break;
                    case "StartMenu": Tap(VK_LWIN); break;
                    case "CloseWindow": Combo(VK_MENU, VK_F4); break;
                    case "MinimizeAll": Combo(VK_LWIN, VK_M); break;
                    case "Explorer": Combo(VK_LWIN, VK_E); break;
                    case "Run": Combo(VK_LWIN, VK_R); break;
                    case "Screenshot": Combo3(VK_LWIN, VK_SHIFT, VK_S); break;
                    case "LockPC": Combo(VK_LWIN, VK_L); break;
                    case "VolumeUp": Tap(VK_VOLUME_UP); break;
                    case "VolumeDown": Tap(VK_VOLUME_DOWN); break;
                    case "VolumeMute": Tap(VK_VOLUME_MUTE); break;
                    case "MediaPlay": Tap(VK_MEDIA_PLAY); break;
                    case "MediaNext": Tap(VK_MEDIA_NEXT); break;
                    case "MediaPrevious": Tap(VK_MEDIA_PREV); break;
                    case "OpenBrowser": System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo("http://www.google.com") { UseShellExecute = true }); break;
                    case "OpenEmail": System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo("mailto:") { UseShellExecute = true }); break;
                    case "Refresh": Tap(VK_F5); break;
                    case "Enter": Tap(VK_RETURN); break;
                    case "Escape": Tap(VK_ESCAPE); break;
                    case "Delete": Tap(VK_DELETE); break;
                    case "Backspace": Tap(VK_BACK); break;
                    case "Tab": Tap(VK_TAB); break;
                    case "SeekBack5s": Tap(VK_LEFT); break;
                    case "SeekForward5s": Tap(VK_RIGHT); break;
                    case "BrowserBack": Combo(VK_MENU, VK_LEFT); break;
                    case "BrowserForward": Combo(VK_MENU, VK_RIGHT); break;
                    // === KLAWISZE Z PRZYTRZYMANIEM (dla gier) ===
                    // Space
                    case "Space": KeyDown(VK_SPACE); break;
                    // Strzałki
                    case "Key_Up": KeyDown(VK_UP); break;
                    case "Key_Down": KeyDown(VK_DOWN); break;
                    case "Key_Left": KeyDown(VK_LEFT); break;
                    case "Key_Right": KeyDown(VK_RIGHT); break;
                    // Cyfry
                    case "Key_0": KeyDown(VK_0); break;
                    case "Key_1": KeyDown(VK_1); break;
                    case "Key_2": KeyDown(VK_2); break;
                    case "Key_3": KeyDown(VK_3); break;
                    case "Key_4": KeyDown(VK_4); break;
                    case "Key_5": KeyDown(VK_5); break;
                    case "Key_6": KeyDown(VK_6); break;
                    case "Key_7": KeyDown(VK_7); break;
                    case "Key_8": KeyDown(VK_8); break;
                    case "Key_9": KeyDown(VK_9); break;
                    // Litery
                    case "Key_A": KeyDown(VK_A); break;
                    case "Key_B": KeyDown(VK_B); break;
                    case "Key_C": KeyDown(VK_C); break;
                    case "Key_D": KeyDown(VK_D); break;
                    case "Key_E": KeyDown(VK_E); break;
                    case "Key_F": KeyDown(VK_F); break;
                    case "Key_G": KeyDown(VK_G); break;
                    case "Key_H": KeyDown(VK_H); break;
                    case "Key_I": KeyDown(VK_I); break;
                    case "Key_J": KeyDown(VK_J); break;
                    case "Key_K": KeyDown(VK_K); break;
                    case "Key_L": KeyDown(VK_L); break;
                    case "Key_M": KeyDown(VK_M); break;
                    case "Key_N": KeyDown(VK_N); break;
                    case "Key_O": KeyDown(VK_O); break;
                    case "Key_P": KeyDown(VK_P); break;
                    case "Key_Q": KeyDown(VK_Q); break;
                    case "Key_R": KeyDown(VK_R); break;
                    case "Key_S": KeyDown(VK_S); break;
                    case "Key_T": KeyDown(VK_T); break;
                    case "Key_U": KeyDown(VK_U); break;
                    case "Key_V": KeyDown(VK_V); break;
                    case "Key_W": KeyDown(VK_W); break;
                    case "Key_X": KeyDown(VK_X); break;
                    case "Key_Y": KeyDown(VK_Y); break;
                    case "Key_Z": KeyDown(VK_Z); break;
                    // Modyfikatory
                    case "Key_LShift": KeyDown(VK_LSHIFT); break;
                    case "Key_RShift": KeyDown(VK_RSHIFT); break;
                    case "Key_LControl": KeyDown(VK_LCONTROL); break;
                    case "Key_RControl": KeyDown(VK_RCONTROL); break;
                    case "Key_LAlt": KeyDown(VK_LMENU); break;
                    case "Key_RAlt": KeyDown(VK_RMENU); break;
                    // Klawisze funkcyjne - TAP (jednorazowe)
                    case "Key_F1": Tap(VK_F1); break;
                    case "Key_F2": Tap(VK_F2); break;
                    case "Key_F3": Tap(VK_F3); break;
                    case "Key_F4": Tap(VK_F4); break;
                    case "Key_F5": Tap(VK_F5); break;
                    case "Key_F6": Tap(VK_F6); break;
                    case "Key_F7": Tap(VK_F7); break;
                    case "Key_F8": Tap(VK_F8); break;
                    case "Key_F9": Tap(VK_F9); break;
                    case "Key_F10": Tap(VK_F10); break;
                    case "Key_F11": Tap(VK_F11); break;
                    case "Key_F12": Tap(VK_F12); break;
                    case "Key_LWin": Tap(VK_LWIN); break;
                    case "Key_RWin": Tap(VK_RWIN); break;
                    // Klawisze specjalne - TAP
                    case "Key_Insert": Tap(VK_INSERT); break;
                    case "Key_Home": Tap(VK_HOME); break;
                    case "Key_End": Tap(VK_END); break;
                    case "Key_PageUp": Tap(VK_PRIOR); break;
                    case "Key_PageDown": Tap(VK_NEXT); break;
                    case "Key_PrintScreen": Tap(VK_SNAPSHOT); break;
                    case "Key_ScrollLock": Tap(VK_SCROLL); break;
                    case "Key_Pause": Tap(VK_PAUSE); break;
                    case "Key_CapsLock": Tap(VK_CAPITAL); break;
                    case "Key_NumLock": Tap(VK_NUMLOCK); break;
                    // Numpad - przytrzymanie
                    case "Key_Numpad0": KeyDown(VK_NUMPAD0); break;
                    case "Key_Numpad1": KeyDown(VK_NUMPAD1); break;
                    case "Key_Numpad2": KeyDown(VK_NUMPAD2); break;
                    case "Key_Numpad3": KeyDown(VK_NUMPAD3); break;
                    case "Key_Numpad4": KeyDown(VK_NUMPAD4); break;
                    case "Key_Numpad5": KeyDown(VK_NUMPAD5); break;
                    case "Key_Numpad6": KeyDown(VK_NUMPAD6); break;
                    case "Key_Numpad7": KeyDown(VK_NUMPAD7); break;
                    case "Key_Numpad8": KeyDown(VK_NUMPAD8); break;
                    case "Key_Numpad9": KeyDown(VK_NUMPAD9); break;
                    case "Key_NumpadMultiply": KeyDown(VK_MULTIPLY); break;
                    case "Key_NumpadAdd": KeyDown(VK_ADD); break;
                    case "Key_NumpadSubtract": KeyDown(VK_SUBTRACT); break;
                    case "Key_NumpadDecimal": KeyDown(VK_DECIMAL); break;
                    case "Key_NumpadDivide": KeyDown(VK_DIVIDE); break;
                    case "Key_NumpadEnter": Tap(VK_SEPARATOR); break;
                    // Znaki specjalne - przytrzymanie
                    case "Key_Semicolon": KeyDown(VK_OEM_1); break;
                    case "Key_Equals": KeyDown(VK_OEM_PLUS); break;
                    case "Key_Comma": KeyDown(VK_OEM_COMMA); break;
                    case "Key_Minus": KeyDown(VK_OEM_MINUS); break;
                    case "Key_Period": KeyDown(VK_OEM_PERIOD); break;
                    case "Key_Slash": KeyDown(VK_OEM_2); break;
                    case "Key_Backquote": KeyDown(VK_OEM_3); break;
                    case "Key_LeftBracket": KeyDown(VK_OEM_4); break;
                    case "Key_Backslash": KeyDown(VK_OEM_5); break;
                    case "Key_RightBracket": KeyDown(VK_OEM_6); break;
                    case "Key_Quote": KeyDown(VK_OEM_7); break;
                }
            }
            // Zwolnienie klawiszy przy puszczeniu przycisku (dla klawiszy z przytrzymaniem)
            else if (!pressed && was) {
                switch (action) {
                    // Space
                    case "Space": KeyUp(VK_SPACE); break;
                    // Strzałki
                    case "Key_Up": KeyUp(VK_UP); break;
                    case "Key_Down": KeyUp(VK_DOWN); break;
                    case "Key_Left": KeyUp(VK_LEFT); break;
                    case "Key_Right": KeyUp(VK_RIGHT); break;
                    // Cyfry
                    case "Key_0": KeyUp(VK_0); break;
                    case "Key_1": KeyUp(VK_1); break;
                    case "Key_2": KeyUp(VK_2); break;
                    case "Key_3": KeyUp(VK_3); break;
                    case "Key_4": KeyUp(VK_4); break;
                    case "Key_5": KeyUp(VK_5); break;
                    case "Key_6": KeyUp(VK_6); break;
                    case "Key_7": KeyUp(VK_7); break;
                    case "Key_8": KeyUp(VK_8); break;
                    case "Key_9": KeyUp(VK_9); break;
                    // Litery
                    case "Key_A": KeyUp(VK_A); break;
                    case "Key_B": KeyUp(VK_B); break;
                    case "Key_C": KeyUp(VK_C); break;
                    case "Key_D": KeyUp(VK_D); break;
                    case "Key_E": KeyUp(VK_E); break;
                    case "Key_F": KeyUp(VK_F); break;
                    case "Key_G": KeyUp(VK_G); break;
                    case "Key_H": KeyUp(VK_H); break;
                    case "Key_I": KeyUp(VK_I); break;
                    case "Key_J": KeyUp(VK_J); break;
                    case "Key_K": KeyUp(VK_K); break;
                    case "Key_L": KeyUp(VK_L); break;
                    case "Key_M": KeyUp(VK_M); break;
                    case "Key_N": KeyUp(VK_N); break;
                    case "Key_O": KeyUp(VK_O); break;
                    case "Key_P": KeyUp(VK_P); break;
                    case "Key_Q": KeyUp(VK_Q); break;
                    case "Key_R": KeyUp(VK_R); break;
                    case "Key_S": KeyUp(VK_S); break;
                    case "Key_T": KeyUp(VK_T); break;
                    case "Key_U": KeyUp(VK_U); break;
                    case "Key_V": KeyUp(VK_V); break;
                    case "Key_W": KeyUp(VK_W); break;
                    case "Key_X": KeyUp(VK_X); break;
                    case "Key_Y": KeyUp(VK_Y); break;
                    case "Key_Z": KeyUp(VK_Z); break;
                    // Modyfikatory
                    case "Key_LShift": KeyUp(VK_LSHIFT); break;
                    case "Key_RShift": KeyUp(VK_RSHIFT); break;
                    case "Key_LControl": KeyUp(VK_LCONTROL); break;
                    case "Key_RControl": KeyUp(VK_RCONTROL); break;
                    case "Key_LAlt": KeyUp(VK_LMENU); break;
                    case "Key_RAlt": KeyUp(VK_RMENU); break;
                    // Numpad
                    case "Key_Numpad0": KeyUp(VK_NUMPAD0); break;
                    case "Key_Numpad1": KeyUp(VK_NUMPAD1); break;
                    case "Key_Numpad2": KeyUp(VK_NUMPAD2); break;
                    case "Key_Numpad3": KeyUp(VK_NUMPAD3); break;
                    case "Key_Numpad4": KeyUp(VK_NUMPAD4); break;
                    case "Key_Numpad5": KeyUp(VK_NUMPAD5); break;
                    case "Key_Numpad6": KeyUp(VK_NUMPAD6); break;
                    case "Key_Numpad7": KeyUp(VK_NUMPAD7); break;
                    case "Key_Numpad8": KeyUp(VK_NUMPAD8); break;
                    case "Key_Numpad9": KeyUp(VK_NUMPAD9); break;
                    case "Key_NumpadMultiply": KeyUp(VK_MULTIPLY); break;
                    case "Key_NumpadAdd": KeyUp(VK_ADD); break;
                    case "Key_NumpadSubtract": KeyUp(VK_SUBTRACT); break;
                    case "Key_NumpadDecimal": KeyUp(VK_DECIMAL); break;
                    case "Key_NumpadDivide": KeyUp(VK_DIVIDE); break;
                    // Znaki specjalne
                    case "Key_Semicolon": KeyUp(VK_OEM_1); break;
                    case "Key_Equals": KeyUp(VK_OEM_PLUS); break;
                    case "Key_Comma": KeyUp(VK_OEM_COMMA); break;
                    case "Key_Minus": KeyUp(VK_OEM_MINUS); break;
                    case "Key_Period": KeyUp(VK_OEM_PERIOD); break;
                    case "Key_Slash": KeyUp(VK_OEM_2); break;
                    case "Key_Backquote": KeyUp(VK_OEM_3); break;
                    case "Key_LeftBracket": KeyUp(VK_OEM_4); break;
                    case "Key_Backslash": KeyUp(VK_OEM_5); break;
                    case "Key_RightBracket": KeyUp(VK_OEM_6); break;
                    case "Key_Quote": KeyUp(VK_OEM_7); break;
                }
            }
            wasPressed[idx] = pressed;
        }

        // Zwraca: 0 = exit, 1 = reload config
        public static int Run()
        {
            XINPUT_STATE state = new XINPUT_STATE();
            Console.WriteLine("Kontroler aktywny! (auto-reload co 1s)");

            while (true)
            {
                // Sprawdź czy plik konfiguracji się zmienił
                if (CheckConfigChanged()) {
                    Console.WriteLine(">>> Wykryto zmianę konfiguracji - przeładowuję...");
                    return 1; // reload
                }
                
                if (XInputGetState(0, ref state) != 0) { Thread.Sleep(500); continue; }
                
                ushort btns = state.Gamepad.wButtons;

                // Exit
                string exitBtn = "";
                foreach (var kv in ButtonMapping) if (kv.Value == "Exit") { exitBtn = kv.Key; break; }
                
                bool shouldExit = false;
                if (exitBtn == "ButtonA" && (btns & BTN_A) != 0) shouldExit = true;
                if (exitBtn == "ButtonB" && (btns & BTN_B) != 0) shouldExit = true;
                if (exitBtn == "ButtonX" && (btns & BTN_X) != 0) shouldExit = true;
                if (exitBtn == "ButtonY" && (btns & BTN_Y) != 0) shouldExit = true;
                if (exitBtn == "ButtonStart" && (btns & BTN_START) != 0) shouldExit = true;
                if (exitBtn == "ButtonBack" && (btns & BTN_BACK) != 0) shouldExit = true;
                if (shouldExit) break;

                // TRYB PRECYZYJNY/SZYBKI - RT zwalnia kursor 4x, LT przyspiesza 1.5x
                bool rtPressed = state.Gamepad.bRightTrigger > 100;
                bool ltPressed = state.Gamepad.bLeftTrigger > 100;
                double currentSpeed = SPEED;
                if (rtPressed) currentSpeed = SPEED * 0.25;      // Precyzyjny - 4x wolniej
                else if (ltPressed) currentSpeed = SPEED * 2.5;  // Szybki - 2.5x szybciej

                // POBIERZ WARTOŚCI DRĄŻKÓW
                double lx = state.Gamepad.sThumbLX, ly = state.Gamepad.sThumbLY;
                double rx = state.Gamepad.sThumbRX, ry = state.Gamepad.sThumbRY;
                
                // ZAMIANA DRĄŻKÓW (jeśli włączona)
                double cursorX, cursorY, scrollY;
                if (SWAP_STICKS) {
                    // Lewy = Scroll, Prawy = Kursor
                    cursorX = rx;
                    cursorY = ry;
                    scrollY = ly;
                } else {
                    // Lewy = Kursor, Prawy = Scroll (domyślnie)
                    cursorX = lx;
                    cursorY = ly;
                    scrollY = ry;
                }
                
                // KURSOR
                bool joystickMoving = Math.Abs(cursorX) > DEADZONE || Math.Abs(cursorY) > DEADZONE;
                
                if (Math.Abs(cursorX) <= DEADZONE) { accX = 0; cursorX = 0; }
                if (Math.Abs(cursorY) <= DEADZONE) { accY = 0; cursorY = 0; }
                if (cursorX != 0 || cursorY != 0) {
                    double nx = cursorX / 32767.0, ny = cursorY / 32767.0;
                    accX += nx * Math.Abs(nx) * currentSpeed * 0.5;
                    accY += ny * Math.Abs(ny) * currentSpeed * 0.5;
                    int mx = (int)accX, my = (int)accY;
                    if (mx != 0 || my != 0) {
                        POINT p; GetCursorPos(out p);
                        SetCursorPos(p.X + mx, p.Y - my);
                        accX -= mx; accY -= my;
                    }
                }

                // SCROLL (RT = precyzyjny scroll 10x wolniej)
                if (Math.Abs(scrollY) > DEADZONE) {
                    int currentScrollSpeed = rtPressed ? SCROLL_SPEED * 10 : SCROLL_SPEED;
                    int scroll = (int)(scrollY / currentScrollSpeed);
                    if (scroll != 0) mouse_event(MOUSEEVENTF_WHEEL, 0, 0, scroll, 0);
                }

                // PRZYCISKI - A i B działają jak normalna myszka
                DoAction(GetAction("ButtonA"), 0, (btns & BTN_A) != 0);
                DoAction(GetAction("ButtonB"), 1, (btns & BTN_B) != 0);
                DoAction(GetAction("ButtonX"), 2, (btns & BTN_X) != 0);
                DoAction(GetAction("ButtonY"), 3, (btns & BTN_Y) != 0);
                DoAction(GetAction("ButtonLB"), 4, (btns & BTN_LB) != 0);
                DoAction(GetAction("ButtonRB"), 5, (btns & BTN_RB) != 0);
                DoAction(GetAction("ButtonLStick"), 6, (btns & BTN_LSTICK) != 0);
                DoAction(GetAction("ButtonRStick"), 7, (btns & BTN_RSTICK) != 0);
                DoAction(GetAction("ButtonStart"), 8, (btns & BTN_START) != 0);
                DoAction(GetAction("ButtonBack"), 9, (btns & BTN_BACK) != 0);
                DoAction(GetAction("DPadUp"), 10, (btns & DPAD_UP) != 0);
                DoAction(GetAction("DPadDown"), 11, (btns & DPAD_DOWN) != 0);
                DoAction(GetAction("DPadLeft"), 12, (btns & DPAD_LEFT) != 0);
                DoAction(GetAction("DPadRight"), 13, (btns & DPAD_RIGHT) != 0);
                // LT - nie wykonuj akcji gdy joystick się rusza (tryb szybki)
                DoAction(GetAction("LeftTrigger"), 14, ltPressed && !joystickMoving);
                // RT - nie wykonuj akcji gdy joystick się rusza (tryb precyzyjny)
                DoAction(GetAction("RightTrigger"), 15, rtPressed && !joystickMoving);

                Thread.Sleep(10);
            }
            
            if (altHeld) KeyUp(VK_MENU);
            if (winHeld) KeyUp(VK_LWIN);
            Console.WriteLine("Kontroler zatrzymany.");
            return 0; // exit
        }
    }
}
"@

    if (-not ("ControllerInput.Gamepad" -as [type])) {
        try { 
            Add-Type -TypeDefinition $csharpCode -Language CSharp 
        }
        catch { 
            Write-Error "Błąd kompilacji kontrolera: $_"
            Read-Host "`nNaciśnij Enter aby zakończyć"
            return
        }
    }

    # Ustaw ścieżkę pliku konfiguracji dla auto-reload
    [ControllerInput.Gamepad]::ConfigFilePath = $ConfigPath
    
    # Funkcja ładująca konfigurację
    function Load-ControllerConfig {
        if (Test-Path $ConfigPath) {
            $json = Get-Content $ConfigPath -Raw | ConvertFrom-Json
            $global:Config = @{}
            foreach ($prop in $json.PSObject.Properties) {
                $global:Config[$prop.Name] = $prop.Value
            }
        }
        
        [ControllerInput.Gamepad]::DEADZONE = $global:Config.Deadzone
        [ControllerInput.Gamepad]::SPEED = [double]$global:Config.CursorSpeed
        [ControllerInput.Gamepad]::SCROLL_SPEED = $global:Config.ScrollSpeed
        [ControllerInput.Gamepad]::SWAP_STICKS = [bool]$global:Config.SwapSticks
        
        [ControllerInput.Gamepad]::ButtonMapping.Clear()
        foreach ($key in $global:Config.Keys) {
            if ($key -like "Button*" -or $key -like "DPad*" -or $key -like "*Trigger") {
                [ControllerInput.Gamepad]::ButtonMapping[$key] = $global:Config[$key]
            }
        }
        
        [ControllerInput.Gamepad]::UpdateLastModified()
        Write-Host "Konfiguracja załadowana:" -ForegroundColor Yellow
        Write-Host "  • Szybkość kursora: $($global:Config.CursorSpeed)" -ForegroundColor Gray
        Write-Host "  • Szybkość scroll: $($global:Config.ScrollSpeed)" -ForegroundColor Gray
        if ($global:Config.SwapSticks) {
            Write-Host "  • Drążki: Lewy=SCROLL | Prawy=KURSOR" -ForegroundColor Cyan
        } else {
            Write-Host "  • Drążki: Lewy=KURSOR | Prawy=SCROLL" -ForegroundColor Cyan
        }
    }
    
    # Załaduj początkową konfigurację
    Load-ControllerConfig
    
    # Pętla główna z auto-reload
    $running = $true
    while ($running) {
        try {
            $result = [ControllerInput.Gamepad]::Run()
            if ($result -eq 1) {
                # Reload - przeładuj konfigurację i kontynuuj
                Write-Host "`n>>> Przeładowuję konfigurację..." -ForegroundColor Cyan
                Load-ControllerConfig
                Write-Host ">>> Konfiguracja przeładowana! Kontroler działa dalej.`n" -ForegroundColor Green
            } else {
                # Exit
                $running = $false
            }
        }
        catch {
            Write-Error "Błąd podczas działania kontrolera: $_"
            $running = $false
        }
    }

    Write-Host "`nKontroler zakończył działanie." -ForegroundColor Yellow
}

# Uruchom kontroler
Start-Controller
'@
        
        # Podmień placeholder na rzeczywistą ścieżkę konfiguracji
        $launcherScript = $launcherScript -replace '__CONFIG_PATH__', $global:ConfigPath

        # Zapisz launcher script (ścieżka już jest poprawna)
        $launcherScript | Set-Content $tempScript -Encoding UTF8
        
        # Uruchom w tle (bez widocznego okna)
        $script:controllerProcess = Start-Process pwsh -ArgumentList "-WindowStyle", "Hidden", "-File", "`"$tempScript`"" -PassThru -WindowStyle Hidden
        
        $statusLabel.Text = "🎮 Kontroler uruchomiony! Zmiany ustawień będą automatycznie stosowane po zapisie."
        $statusLabel.ForeColor = [System.Drawing.Color]::Green
    }.GetNewClosure())
    $script:mainForm.Controls.Add($buttonStart)

    $buttonExit = New-Object System.Windows.Forms.Button
    $buttonExit.Text = "✖ Zamknij"
    $buttonExit.Location = New-Object System.Drawing.Point(600, 840)
    $buttonExit.Size = New-Object System.Drawing.Size(240, 45)
    $buttonExit.BackColor = [System.Drawing.Color]::FromArgb(232, 17, 35)
    $buttonExit.ForeColor = [System.Drawing.Color]::White
    $buttonExit.FlatStyle = "Flat"
    $buttonExit.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $buttonExit.Cursor = [System.Windows.Forms.Cursors]::Hand
    $buttonExit.Add_Click({ 
        # Zamknij kontroler - zabij proces i wszystkie podprocesy
        if ($script:controllerProcess) {
            try {
                $procId = $script:controllerProcess.Id
                # Zabij drzewo procesów (proces i wszystkie jego dzieci)
                Start-Process -FilePath "taskkill" -ArgumentList "/F", "/T", "/PID", $procId -NoNewWindow -Wait -ErrorAction SilentlyContinue
            } catch { }
        }
        # Dodatkowo zabij wszystkie procesy pwsh uruchomione z tego skryptu temp
        Get-Process pwsh -ErrorAction SilentlyContinue | Where-Object {
            try {
                $cmdLine = (Get-CimInstance Win32_Process -Filter "ProcessId = $($_.Id)" -ErrorAction SilentlyContinue).CommandLine
                $cmdLine -like "*ControllerLauncher_Active*"
            } catch { $false }
        } | ForEach-Object {
            try { Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue } catch { }
        }
        # Usuń temp plik
        $tempFile = "$env:TEMP\ControllerLauncher_Active.ps1"
        if (Test-Path $tempFile) { Remove-Item $tempFile -Force -ErrorAction SilentlyContinue }
        # Cleanup
        $script:trayIcon.Visible = $false
        $script:trayIcon.Dispose()
        # Całkowicie zakończ proces
        [Environment]::Exit(0)
    }.GetNewClosure())
    $script:mainForm.Controls.Add($buttonExit)

    # Obsługa zamknięcia formularza
    $script:mainForm.Add_FormClosing({
        param($formSender, $formEvent)
        
        # Zamknij kontroler - zabij proces i wszystkie podprocesy
        if ($script:controllerProcess) {
            try {
                $procId = $script:controllerProcess.Id
                Start-Process -FilePath "taskkill" -ArgumentList "/F", "/T", "/PID", $procId -NoNewWindow -Wait -ErrorAction SilentlyContinue
            } catch { }
        }
        # Dodatkowo zabij wszystkie procesy pwsh z tego skryptu
        Get-Process pwsh -ErrorAction SilentlyContinue | Where-Object {
            try {
                $cmdLine = (Get-CimInstance Win32_Process -Filter "ProcessId = $($_.Id)" -ErrorAction SilentlyContinue).CommandLine
                $cmdLine -like "*ControllerLauncher_Active*"
            } catch { $false }
        } | ForEach-Object {
            try { Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue } catch { }
        }
        
        # Usuń tymczasowy plik
        $tempFile = "$env:TEMP\ControllerLauncher_Active.ps1"
        if (Test-Path $tempFile) {
            Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
        }
        
        $script:trayIcon.Visible = $false
        $script:trayIcon.Dispose()
        
        # Całkowicie zakończ proces PowerShell
        [Environment]::Exit(0)
    })

    # Użyj Application.Run zamiast ShowDialog - prawidłowo obsługuje NotifyIcon
    [System.Windows.Forms.Application]::Run($script:mainForm)
    
    # Czyszczenie zasobów
    $script:cursorLabel = $null
    $script:scrollLabel = $null
    $script:deadzoneLabel = $null
    
    try {
        $script:mainForm.Dispose()
    } catch { }
}

# === GŁÓWNY PUNKT WEJŚCIA ===
Clear-Host
Write-Host @"
╔═══════════════════════════════════════════════════════╗
║                                                       ║
║    🎮  KONTROLER XBOX - KONFIGURATOR PRO  🎮          ║
║                                                       ║
║    Sterowanie myszką i klawiaturą za pomocą           ║
║    kontrolera Xbox z pełną konfiguracją GUI           ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

Write-Host "`nŁadowanie..." -ForegroundColor Yellow
Load-Config

# Uruchomienie GUI
Show-ConfigGUI

Write-Host "`nDo zobaczenia!" -ForegroundColor Cyan