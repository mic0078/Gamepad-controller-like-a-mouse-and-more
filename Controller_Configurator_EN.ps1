Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# === HIDE POWERSHELL CONSOLE ===
Add-Type -Name Win32 -Namespace ControllerGUI -MemberDefinition @'
[DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
'@ -ErrorAction SilentlyContinue

# Hide console window
try { [ControllerGUI.Win32]::ShowWindow([ControllerGUI.Win32]::GetConsoleWindow(), 0) | Out-Null } catch {}

# === DEFAULT CONFIGURATION ===
$global:Config = @{
    # Sensitivity
    CursorSpeed = 8
    ScrollSpeed = 300
    Deadzone = 10000
    SwapSticks = $false  # False = Left:Cursor/Right:Scroll, True = Left:Scroll/Right:Cursor
    
    # Button mappings
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

# === CONFIG PATH (use script folder for portability) ===
$global:ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$global:ConfigPath = Join-Path $global:ScriptDir 'ControllerConfig.json'

# === AVAILABLE ACTIONS FOR BUTTON ASSIGNMENT ===
$global:AvailableFunctions = [ordered]@{
    "None" = "───────────  NO ACTION  ───────────"
    
    # MOUSE
    "LeftClick" = "🖱️ Left mouse button"
    "RightClick" = "🖱️ Right mouse button"
    "MiddleClick" = "🖱️ Middle mouse button"
    "DoubleClick" = "🖱️ Double click"
    
    # BASIC KEYS
    "Enter" = "⏎ Enter"
    "Escape" = "⎋ Escape"
    "Tab" = "⇥ Tab"
    "Space" = "␣ Space"
    "Backspace" = "⌫ Backspace"
    "Delete" = "⌦ Delete"
    
    # ARROWS
    "Key_Up" = "↑ Arrow Up"
    "Key_Down" = "↓ Arrow Down"
    "Key_Left" = "← Arrow Left"
    "Key_Right" = "→ Arrow Right"
    
    # LETTERS A-Z
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
    
    # DIGITS 0-9
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
    
    # FUNCTION KEYS F1-F12
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
    
    # MODIFIERS
    "Key_LShift" = "⇧ Left Shift"
    "Key_RShift" = "⇧ Right Shift"
    "Key_LControl" = "⌃ Left Control"
    "Key_RControl" = "⌃ Right Control"
    "Key_LAlt" = "⎇ Left Alt"
    "Key_RAlt" = "⎇ Right Alt"
    "Key_LWin" = "⊞ Left Win"
    "Key_RWin" = "⊞ Right Win"
    
    # NAVIGATION
    "Key_Home" = "⇱ Home"
    "Key_End" = "⇲ End"
    "Key_PageUp" = "⇞ Page Up"
    "Key_PageDown" = "⇟ Page Down"
    "Key_Insert" = "⎀ Insert"
    
    # LOCK KEYS
    "Key_CapsLock" = "⇪ Caps Lock"
    "Key_NumLock" = "⇭ Num Lock"
    "Key_ScrollLock" = "⤓ Scroll Lock"
    "Key_Pause" = "⎉ Pause/Break"
    "Key_PrintScreen" = "🖨️ Print Screen"
    
    # NUMPAD 0-9
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
    
    # NUMPAD OPERATIONS
    "Key_NumpadAdd" = "➕ Numpad +"
    "Key_NumpadSubtract" = "➖ Numpad -"
    "Key_NumpadMultiply" = "✖️ Numpad *"
    "Key_NumpadDivide" = "➗ Numpad /"
    "Key_NumpadDecimal" = "◦ Numpad ."
    "Key_NumpadEnter" = "⏎ Numpad Enter"
    
    # SPECIAL CHARACTERS
    "Key_Semicolon" = '; Semicolon'
    "Key_Equals" = '= Equals'
    "Key_Comma" = ', Comma'
    "Key_Minus" = '- Minus'
    "Key_Period" = '. Period'
    "Key_Slash" = '/ Slash'
    "Key_Backquote" = '` Tilde/Backtick'
    "Key_LeftBracket" = '[ Left bracket'
    "Key_Backslash" = '\\ Backslash'
    "Key_RightBracket" = '] Right bracket'
    "Key_Quote" = "' Apostrophe"
    
    # EDIT SHORTCUTS
    "Copy" = "📋 Copy (Ctrl+C)"
    "Paste" = "📋 Paste (Ctrl+V)"
    "Cut" = "✂️ Cut (Ctrl+X)"
    "Undo" = "↶ Undo (Ctrl+Z)"
    "Redo" = "↷ Redo (Ctrl+Y)"
    "SelectAll" = "📄 Select All (Ctrl+A)"
    "Save" = "💾 Save (Ctrl+S)"
    "Find" = "🔍 Find (Ctrl+F)"
    
    # WINDOWS SHORTCUTS
    "StartMenu" = "⊞ Start Menu"
    "ShowDesktop" = "🖥️ Show Desktop (Win+D)"
    "TaskView" = "🗔 Task View (Win+Tab)"
    "AltTab" = "⇄ Switch Windows (Alt+Tab)"
    "CloseWindow" = "✖️ Close Window (Alt+F4)"
    "MinimizeAll" = "🗕 Minimize All (Win+M)"
    "Explorer" = "📁 Explorer (Win+E)"
    "Run" = "▶️ Run (Win+R)"
    "Screenshot" = "📸 Screenshot (Win+Shift+S)"
    "LockPC" = "🔒 Lock PC (Win+L)"
    "Refresh" = "🔄 Refresh (F5)"
    
    # MULTIMEDIA
    "VolumeUp" = "🔊 Volume +"
    "VolumeDown" = "🔉 Volume -"
    "VolumeMute" = "🔇 Mute"
    "MediaPlay" = "⏯️ Play/Pause"
    "MediaNext" = "⏭️ Next track"
    "MediaPrevious" = "⏮️ Previous track"
    
    # BROWSER
    "OpenBrowser" = "🌐 Open browser"
    "BrowserBack" = "◀️ Browser Back"
    "BrowserForward" = "▶️ Browser Forward"
    "SeekBack5s" = "⏪ Seek -5s"
    "SeekForward5s" = "⏩ Seek +5s"
    
    # OTHER
    "OpenEmail" = "✉️ Open email client"
    
    # EXIT
    "Exit" = "🚪 Exit script"
}

# === HELPER FUNCTIONS ===
function Load-Config {
    if (Test-Path $global:ConfigPath) {
        try {
            $json = Get-Content $global:ConfigPath -Raw | ConvertFrom-Json
            foreach ($key in $json.PSObject.Properties.Name) {
                $global:Config[$key] = $json.$key
            }
            Write-Host "✓ Configuration loaded" -ForegroundColor Green
        } catch {
            Write-Host "⚠ Error loading configuration, using defaults" -ForegroundColor Yellow
        }
    }
}

function Save-Config {
    param($StatusLabel)
    
    try {
        $global:Config | ConvertTo-Json | Set-Content $global:ConfigPath
        
        if ($StatusLabel) {
            $StatusLabel.Text = "✓ Configuration saved successfully!"
            $StatusLabel.ForeColor = [System.Drawing.Color]::Green
        }
        
        Write-Host "✓ Configuration saved: $global:ConfigPath" -ForegroundColor Green
    } catch {
        if ($StatusLabel) {
            $StatusLabel.Text = "✗ Save error: $_"
            $StatusLabel.ForeColor = [System.Drawing.Color]::Red
        }
        Write-Error "Error saving configuration: $_"
    }
}

# === CONFIG GUI ===
function Show-ConfigGUI {
    # Track controller process and temp launcher script
    $script:controllerProcess = $null
    $script:controllerConfigFile = "$env:TEMP\ControllerLauncher_Active.ps1"
    
    $script:mainForm = New-Object System.Windows.Forms.Form
    $script:mainForm.Text = "Xbox Controller Configurator"
    $script:mainForm.Size = New-Object System.Drawing.Size(900, 950)
    $script:mainForm.StartPosition = "CenterScreen"
    $script:mainForm.FormBorderStyle = "FixedDialog"
    $script:mainForm.MaximizeBox = $false
    $script:mainForm.MinimizeBox = $true
    $script:mainForm.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $script:mainForm.BackColor = [System.Drawing.Color]::White
    
    # Window icon (try to use pwsh icon)
    try {
        $pwshPath = (Get-Command pwsh -ErrorAction SilentlyContinue).Source
        if ($pwshPath) {
            $script:mainForm.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($pwshPath)
        }
    } catch { }

    # === SYSTEM TRAY ICON ===
    $script:trayIcon = New-Object System.Windows.Forms.NotifyIcon
    $script:trayIcon.Text = "Xbox Controller Configurator"
    $script:trayIcon.Visible = $true
    
    # Create small icon programmatically
    $bmp = New-Object System.Drawing.Bitmap(16, 16)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'
    $g.Clear([System.Drawing.Color]::FromArgb(0, 120, 215))
    $g.DrawString("X", (New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)), [System.Drawing.Brushes]::White, 1, 0)
    $g.Dispose()
    $script:trayIcon.Icon = [System.Drawing.Icon]::FromHandle($bmp.GetHicon())
    
    # Context menu for tray icon
    $contextMenu = New-Object System.Windows.Forms.ContextMenuStrip
    
    $menuItemRestore = New-Object System.Windows.Forms.ToolStripMenuItem
    $menuItemRestore.Text = "Restore Window"
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
    $menuItemExit.Text = "Close Configurator"
    $menuItemExit.Add_Click({
        # Kill controller process if running
        if ($script:controllerProcess) {
            try {
                $procId = $script:controllerProcess.Id
                Start-Process -FilePath "taskkill" -ArgumentList "/F", "/T", "/PID", $procId -NoNewWindow -Wait -ErrorAction SilentlyContinue
            } catch { }
        }
        # Kill any pwsh processes running the launcher
        Get-Process pwsh -ErrorAction SilentlyContinue | Where-Object {
            try {
                $cmdLine = (Get-CimInstance Win32_Process -Filter "ProcessId = $($_.Id)" -ErrorAction SilentlyContinue).CommandLine
                $cmdLine -like "*ControllerLauncher_Active*"
            } catch { $false }
        } | ForEach-Object {
            try { Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue } catch { }
        }
        # Remove temp file
        $tempFile = "$env:TEMP\ControllerLauncher_Active.ps1"
        if (Test-Path $tempFile) { Remove-Item $tempFile -Force -ErrorAction SilentlyContinue }
        $script:trayIcon.Visible = $false
        $script:trayIcon.Dispose()
        [Environment]::Exit(0)
    })
    $contextMenu.Items.Add($menuItemExit) | Out-Null
    
    $script:trayIcon.ContextMenuStrip = $contextMenu
    
    # Double-click tray icon to restore
    $script:trayIcon.Add_DoubleClick({
        $script:mainForm.Show()
        $script:mainForm.WindowState = [System.Windows.Forms.FormWindowState]::Normal
        $script:mainForm.BringToFront()
        $script:mainForm.Activate()
    })
    
    # Minimize -> hide to tray
    $script:mainForm.Add_Resize({
        param($sender, $e)
        if ($script:mainForm.WindowState -eq [System.Windows.Forms.FormWindowState]::Minimized) {
            $script:mainForm.Hide()
            $script:trayIcon.ShowBalloonTip(2000, "Controller Configurator", "Double-click the icon to restore.", [System.Windows.Forms.ToolTipIcon]::Info)
        }
    })

    # Sensitivity group
    $groupSensitivity = New-Object System.Windows.Forms.GroupBox
    $groupSensitivity.Text = "⚙ CONTROLLER SENSITIVITY"
    $groupSensitivity.Location = New-Object System.Drawing.Point(20, 20)
    $groupSensitivity.Size = New-Object System.Drawing.Size(840, 230)
    $groupSensitivity.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $script:mainForm.Controls.Add($groupSensitivity)

    # Cursor Speed
    $labelCursor = New-Object System.Windows.Forms.Label
    $labelCursor.Text = "Cursor speed:"
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
        } catch { }
    })

    # Scroll Speed
    $labelScroll = New-Object System.Windows.Forms.Label
    $labelScroll.Text = "Scroll speed:"
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
        } catch { }
    })

    # Deadzone
    $labelDeadzone = New-Object System.Windows.Forms.Label
    $labelDeadzone.Text = "Stick deadzone:"
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
        } catch { }
    })

    # Swap sticks
    $labelSwapSticks = New-Object System.Windows.Forms.Label
    $labelSwapSticks.Text = "Stick functions:"
    $labelSwapSticks.Location = New-Object System.Drawing.Point(20, 160)
    $labelSwapSticks.Size = New-Object System.Drawing.Size(180, 25)
    $labelSwapSticks.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $groupSensitivity.Controls.Add($labelSwapSticks)

    $comboSwapSticks = New-Object System.Windows.Forms.ComboBox
    $comboSwapSticks.Location = New-Object System.Drawing.Point(210, 160)
    $comboSwapSticks.Size = New-Object System.Drawing.Size(410, 28)
    $comboSwapSticks.DropDownStyle = "DropDownList"
    $comboSwapSticks.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $comboSwapSticks.Items.Add("🕹️ Left stick = CURSOR, Right stick = SCROLL") | Out-Null
    $comboSwapSticks.Items.Add("🕹️ Left stick = SCROLL, Right stick = CURSOR") | Out-Null
    
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
    $labelSwapInfo.Text = "💡 Change which stick controls cursor vs. scrolling"
    $labelSwapInfo.Location = New-Object System.Drawing.Point(210, 193)
    $labelSwapInfo.Size = New-Object System.Drawing.Size(600, 25)
    $labelSwapInfo.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Italic)
    $labelSwapInfo.ForeColor = [System.Drawing.Color]::Gray
    $groupSensitivity.Controls.Add($labelSwapInfo)

    # === BUTTON MAPPINGS ===
    $groupButtons = New-Object System.Windows.Forms.GroupBox
    $groupButtons.Text = "🎮 BUTTON MAPPINGS"
    $groupButtons.Location = New-Object System.Drawing.Point(20, 270)
    $groupButtons.Size = New-Object System.Drawing.Size(840, 530)
    $groupButtons.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $script:mainForm.Controls.Add($groupButtons)

    $panelButtons = New-Object System.Windows.Forms.Panel
    $panelButtons.Location = New-Object System.Drawing.Point(10, 30)
    $panelButtons.Size = New-Object System.Drawing.Size(820, 490)
    $panelButtons.AutoScroll = $true
    $panelButtons.BorderStyle = "None"
    $groupButtons.Controls.Add($panelButtons)

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
    
    # Category: Main buttons
    $labelCategory1 = New-Object System.Windows.Forms.Label
    $labelCategory1.Text = "═══ MAIN BUTTONS ═══"
    $labelCategory1.Location = New-Object System.Drawing.Point(10, $innerYPos)
    $labelCategory1.Size = New-Object System.Drawing.Size(780, 25)
    $labelCategory1.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $labelCategory1.ForeColor = [System.Drawing.Color]::DarkBlue
    $panelButtons.Controls.Add($labelCategory1)
    $innerYPos += 30
    
    $innerYPos = Add-ButtonConfig "ButtonA" "🅰 Button A" $innerYPos
    $innerYPos = Add-ButtonConfig "ButtonB" "🅱 Button B" $innerYPos
    $innerYPos = Add-ButtonConfig "ButtonX" "🅧 Button X" $innerYPos
    $innerYPos = Add-ButtonConfig "ButtonY" "🅨 Button Y" $innerYPos
    
    $innerYPos += 10
    
    # Category: Bumpers & Triggers
    $labelCategory2 = New-Object System.Windows.Forms.Label
    $labelCategory2.Text = "═══ BUMPERS & TRIGGERS ═══"
    $labelCategory2.Location = New-Object System.Drawing.Point(10, $innerYPos)
    $labelCategory2.Size = New-Object System.Drawing.Size(780, 25)
    $labelCategory2.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $labelCategory2.ForeColor = [System.Drawing.Color]::DarkBlue
    $panelButtons.Controls.Add($labelCategory2)
    $innerYPos += 30
    
    $innerYPos = Add-ButtonConfig "ButtonLB" "LB (Left Bumper)" $innerYPos
    $innerYPos = Add-ButtonConfig "ButtonRB" "RB (Right Bumper)" $innerYPos
    $innerYPos = Add-ButtonConfig "LeftTrigger" "LT (Left Trigger)" $innerYPos
    $innerYPos = Add-ButtonConfig "RightTrigger" "RT (Right Trigger)" $innerYPos
    
    $innerYPos += 10
    
    # Sticks clicks
    $labelCategory3 = New-Object System.Windows.Forms.Label
    $labelCategory3.Text = "═══ STICK CLICKS ═══"
    $labelCategory3.Location = New-Object System.Drawing.Point(10, $innerYPos)
    $labelCategory3.Size = New-Object System.Drawing.Size(780, 25)
    $labelCategory3.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $labelCategory3.ForeColor = [System.Drawing.Color]::DarkBlue
    $panelButtons.Controls.Add($labelCategory3)
    $innerYPos += 30
    
    $innerYPos = Add-ButtonConfig "ButtonLStick" "L3 (Left stick click)" $innerYPos
    $innerYPos = Add-ButtonConfig "ButtonRStick" "R3 (Right stick click)" $innerYPos
    
    $innerYPos += 10
    
    # Menu buttons
    $labelCategory4 = New-Object System.Windows.Forms.Label
    $labelCategory4.Text = "═══ MENU BUTTONS ═══"
    $labelCategory4.Location = New-Object System.Drawing.Point(10, $innerYPos)
    $labelCategory4.Size = New-Object System.Drawing.Size(780, 25)
    $labelCategory4.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $labelCategory4.ForeColor = [System.Drawing.Color]::DarkBlue
    $panelButtons.Controls.Add($labelCategory4)
    $innerYPos += 30
    
    $innerYPos = Add-ButtonConfig "ButtonStart" "⏵ Start / Menu" $innerYPos
    $innerYPos = Add-ButtonConfig "ButtonBack" "⏴ Back / Select" $innerYPos
    
    $innerYPos += 10
    
    # D-Pad
    $labelCategory5 = New-Object System.Windows.Forms.Label
    $labelCategory5.Text = "═══ D-PAD ═══"
    $labelCategory5.Location = New-Object System.Drawing.Point(10, $innerYPos)
    $labelCategory5.Size = New-Object System.Drawing.Size(780, 25)
    $labelCategory5.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $labelCategory5.ForeColor = [System.Drawing.Color]::DarkBlue
    $panelButtons.Controls.Add($labelCategory5)
    $innerYPos += 30
    
    $innerYPos = Add-ButtonConfig "DPadUp" "⬆ D-Pad Up" $innerYPos
    $innerYPos = Add-ButtonConfig "DPadDown" "⬇ D-Pad Down" $innerYPos
    $innerYPos = Add-ButtonConfig "DPadLeft" "⬅ D-Pad Left" $innerYPos
    $innerYPos = Add-ButtonConfig "DPadRight" "➡ D-Pad Right" $innerYPos

    # STATUS LABEL
    $statusLabel = New-Object System.Windows.Forms.Label
    $statusLabel.Text = "Ready. Configure buttons and save."
    $statusLabel.Location = New-Object System.Drawing.Point(40, 685)
    $statusLabel.Size = New-Object System.Drawing.Size(800, 25)
    $statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Italic)
    $statusLabel.ForeColor = [System.Drawing.Color]::Gray
    $statusLabel.TextAlign = "MiddleLeft"
    $script:mainForm.Controls.Add($statusLabel)

    # ACTION BUTTONS
    $buttonSave = New-Object System.Windows.Forms.Button
    $buttonSave.Text = "💾 Save configuration"
    $buttonSave.Location = New-Object System.Drawing.Point(40, 840)
    $buttonSave.Size = New-Object System.Drawing.Size(240, 45)
    $buttonSave.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
    $buttonSave.ForeColor = [System.Drawing.Color]::White
    $buttonSave.FlatStyle = "Flat"
    $buttonSave.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $buttonSave.Cursor = [System.Windows.Forms.Cursors]::Hand
    $buttonSave.Add_Click({ 
        try {
            $global:Config | ConvertTo-Json | Set-Content $global:ConfigPath
            
            $controllerRunning = $script:controllerProcess -and !$script:controllerProcess.HasExited
            
            if ($controllerRunning) {
                $statusLabel.Text = "✓ Saved! Controller will auto-apply new settings."
                $statusLabel.ForeColor = [System.Drawing.Color]::Green
            } else {
                $statusLabel.Text = "✓ Configuration saved! Click 'START' to run the controller."
                $statusLabel.ForeColor = [System.Drawing.Color]::Green
            }
        } catch {
            $statusLabel.Text = "✗ Error: $_"
            $statusLabel.ForeColor = [System.Drawing.Color]::Red
        }
    }.GetNewClosure())
    $script:mainForm.Controls.Add($buttonSave)

    $buttonStart = New-Object System.Windows.Forms.Button
    $buttonStart.Text = "▶ START CONTROLLER"
    $buttonStart.Location = New-Object System.Drawing.Point(300, 840)
    $buttonStart.Size = New-Object System.Drawing.Size(280, 45)
    $buttonStart.BackColor = [System.Drawing.Color]::FromArgb(16, 124, 16)
    $buttonStart.ForeColor = [System.Drawing.Color]::White
    $buttonStart.FlatStyle = "Flat"
    $buttonStart.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $buttonStart.Cursor = [System.Windows.Forms.Cursors]::Hand
    $buttonStart.Add_Click({
        # Kill old process if exists
        if ($script:controllerProcess -and !$script:controllerProcess.HasExited) {
            try {
                $script:controllerProcess.Kill()
                $script:controllerProcess.WaitForExit(1000)
            } catch { }
        }
        
        # Save configuration
        $global:Config | ConvertTo-Json | Set-Content $global:ConfigPath
        $statusLabel.Text = "✓ Configuration saved. Launching controller..."
        $statusLabel.ForeColor = [System.Drawing.Color]::Green
        
        # Temp launcher script path
        $tempScript = "$env:TEMP\ControllerLauncher_Active.ps1"
        
        # Build full launcher script (embed current config path)
        $launcherScript = @'
# Load configuration
$ConfigPath = "___CONFIG_PATH___"
Write-Host "Looking for configuration at: $ConfigPath" -ForegroundColor Cyan
Write-Host "Config file exists: $(Test-Path $ConfigPath)" -ForegroundColor Cyan
if (Test-Path $ConfigPath) {
    $json = Get-Content $ConfigPath -Raw | ConvertFrom-Json
    $global:Config = @{}
    foreach ($prop in $json.PSObject.Properties) {
        $global:Config[$prop.Name] = $prop.Value
    }
    Write-Host "✓ Configuration loaded from file: $ConfigPath" -ForegroundColor Green
} else {
    Write-Host "⚠ No configuration file found at: $ConfigPath, using defaults" -ForegroundColor Yellow
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

# Function Start-Controller
function Start-Controller {
    Write-Host "`n╔══════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║   XBOX CONTROLLER - ACTIVE MODE         ║" -ForegroundColor Cyan
    Write-Host "║   Auto-reload configuration every 1s    ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host "`nPress the button mapped to 'Exit' to stop the controller.`n" -ForegroundColor Yellow

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
        const byte VK_PRIOR = 0x21, VK_NEXT = 0x22;
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
        const byte VK_DECIMAL = 0x6E, VK_DIVIDE = 0x6F, VK_SEPARATOR = 0x6C;
        const byte VK_LEFT = 0x25, VK_UP = 0x26, VK_RIGHT = 0x27, VK_DOWN = 0x28;
        const byte VK_OEM_1 = 0xBA, VK_OEM_PLUS = 0xBB, VK_OEM_COMMA = 0xBC, VK_OEM_MINUS = 0xBD;
        const byte VK_OEM_PERIOD = 0xBE, VK_OEM_2 = 0xBF, VK_OEM_3 = 0xC0;
        const byte VK_OEM_4 = 0xDB, VK_OEM_5 = 0xDC, VK_OEM_6 = 0xDD, VK_OEM_7 = 0xDE;
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
        public static bool SWAP_STICKS = false;
        public static Dictionary<string, string> ButtonMapping = new Dictionary<string, string>();
        
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
        
        public static bool CheckConfigChanged() {
            if (string.IsNullOrEmpty(ConfigFilePath)) return false;
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
                    case "Space": KeyDown(VK_SPACE); break;
                    case "Key_Up": KeyDown(VK_UP); break;
                    case "Key_Down": KeyDown(VK_DOWN); break;
                    case "Key_Left": KeyDown(VK_LEFT); break;
                    case "Key_Right": KeyDown(VK_RIGHT); break;
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
                    case "Key_LShift": KeyDown(VK_LSHIFT); break;
                    case "Key_RShift": KeyDown(VK_RSHIFT); break;
                    case "Key_LControl": KeyDown(VK_LCONTROL); break;
                    case "Key_RControl": KeyDown(VK_RCONTROL); break;
                    case "Key_LAlt": KeyDown(VK_LMENU); break;
                    case "Key_RAlt": KeyDown(VK_RMENU); break;
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
            else if (!pressed && was) {
                switch (action) {
                    case "Space": KeyUp(VK_SPACE); break;
                    case "Key_Up": KeyUp(VK_UP); break;
                    case "Key_Down": KeyUp(VK_DOWN); break;
                    case "Key_Left": KeyUp(VK_LEFT); break;
                    case "Key_Right": KeyUp(VK_RIGHT); break;
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
                    case "Key_LShift": KeyUp(VK_LSHIFT); break;
                    case "Key_RShift": KeyUp(VK_RSHIFT); break;
                    case "Key_LControl": KeyUp(VK_LCONTROL); break;
                    case "Key_RControl": KeyUp(VK_RCONTROL); break;
                    case "Key_LAlt": KeyUp(VK_LMENU); break;
                    case "Key_RAlt": KeyUp(VK_RMENU); break;
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

        public static int Run()
        {
            XINPUT_STATE state = new XINPUT_STATE();
            Console.WriteLine("Controller active! (auto-reload every 1s)");

            while (true)
            {
                if (CheckConfigChanged()) {
                    Console.WriteLine(">>> Configuration change detected - reloading...");
                    return 1;
                }
                
                if (XInputGetState(0, ref state) != 0) { Thread.Sleep(500); continue; }
                
                ushort btns = state.Gamepad.wButtons;

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

                bool rtPressed = state.Gamepad.bRightTrigger > 100;
                bool ltPressed = state.Gamepad.bLeftTrigger > 100;
                double currentSpeed = SPEED;
                if (rtPressed) currentSpeed = SPEED * 0.25;
                else if (ltPressed) currentSpeed = SPEED * 2.5;

                double lx = state.Gamepad.sThumbLX, ly = state.Gamepad.sThumbLY;
                double rx = state.Gamepad.sThumbRX, ry = state.Gamepad.sThumbRY;
                
                double cursorX, cursorY, scrollY;
                if (SWAP_STICKS) {
                    cursorX = rx;
                    cursorY = ry;
                    scrollY = ly;
                } else {
                    cursorX = lx;
                    cursorY = ly;
                    scrollY = ry;
                }
                
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

                if (Math.Abs(scrollY) > DEADZONE) {
                    int currentScrollSpeed = rtPressed ? SCROLL_SPEED * 10 : SCROLL_SPEED;
                    int scroll = (int)(scrollY / currentScrollSpeed);
                    if (scroll != 0) mouse_event(MOUSEEVENTF_WHEEL, 0, 0, scroll, 0);
                }

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
                DoAction(GetAction("LeftTrigger"), 14, ltPressed && !joystickMoving);
                DoAction(GetAction("RightTrigger"), 15, rtPressed && !joystickMoving);

                Thread.Sleep(10);
            }
            
            if (altHeld) KeyUp(VK_MENU);
            if (winHeld) KeyUp(VK_LWIN);
            Console.WriteLine("Controller stopped.");
            return 0;
        }
    }
}
"@

    if (-not ("ControllerInput.Gamepad" -as [type])) {
        try { 
            Add-Type -TypeDefinition $csharpCode -Language CSharp 
        }
        catch { 
            Write-Error "Controller compilation error: $_"
            Read-Host "`nPress Enter to exit"
            return
        }
    }

    [ControllerInput.Gamepad]::ConfigFilePath = $ConfigPath
    
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
        Write-Host "Configuration loaded:" -ForegroundColor Yellow
        Write-Host "  • Cursor speed: $($global:Config.CursorSpeed)" -ForegroundColor Gray
        Write-Host "  • Scroll speed: $($global:Config.ScrollSpeed)" -ForegroundColor Gray
        if ($global:Config.SwapSticks) {
            Write-Host "  • Sticks: Left=SCROLL | Right=CURSOR" -ForegroundColor Cyan
        } else {
            Write-Host "  • Sticks: Left=CURSOR | Right=SCROLL" -ForegroundColor Cyan
        }
    }
    
    Load-ControllerConfig
    
    $running = $true
    while ($running) {
        try {
            $result = [ControllerInput.Gamepad]::Run()
            if ($result -eq 1) {
                Write-Host "`n>>> Reloading configuration..." -ForegroundColor Cyan
                Load-ControllerConfig
                Write-Host ">>> Configuration reloaded! Controller continues.`n" -ForegroundColor Green
            } else {
                $running = $false
            }
        }
        catch {
            Write-Error "Controller runtime error: $_"
            $running = $false
        }
    }

Write-Host "`nController exited." -ForegroundColor Yellow
}

Start-Controller

# End of launcher script
'@

$launcherScript = $launcherScript.Replace('___CONFIG_PATH___', $global:ConfigPath)

# Save launcher to temp and run
$launcherScript | Set-Content $tempScript -Encoding UTF8
$script:controllerProcess = Start-Process pwsh -ArgumentList "-WindowStyle", "Hidden", "-File", "`"$tempScript`"" -PassThru -WindowStyle Hidden

$statusLabel.Text = "🎮 Controller started! Settings will be auto-applied after save."
$statusLabel.ForeColor = [System.Drawing.Color]::Green
    }.GetNewClosure())
    $script:mainForm.Controls.Add($buttonStart)

    $buttonExit = New-Object System.Windows.Forms.Button
    $buttonExit.Text = "✖ Close"
    $buttonExit.Location = New-Object System.Drawing.Point(600, 840)
    $buttonExit.Size = New-Object System.Drawing.Size(240, 45)
    $buttonExit.BackColor = [System.Drawing.Color]::FromArgb(232, 17, 35)
    $buttonExit.ForeColor = [System.Drawing.Color]::White
    $buttonExit.FlatStyle = "Flat"
    $buttonExit.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $buttonExit.Cursor = [System.Windows.Forms.Cursors]::Hand
    $buttonExit.Add_Click({ 
        if ($script:controllerProcess) {
            try {
                $procId = $script:controllerProcess.Id
                Start-Process -FilePath "taskkill" -ArgumentList "/F", "/T", "/PID", $procId -NoNewWindow -Wait -ErrorAction SilentlyContinue
            } catch { }
        }
        Get-Process pwsh -ErrorAction SilentlyContinue | Where-Object {
            try {
                $cmdLine = (Get-CimInstance Win32_Process -Filter "ProcessId = $($_.Id)" -ErrorAction SilentlyContinue).CommandLine
                $cmdLine -like "*ControllerLauncher_Active*"
            } catch { $false }
        } | ForEach-Object {
            try { Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue } catch { }
        }
        $tempFile = "$env:TEMP\ControllerLauncher_Active.ps1"
        if (Test-Path $tempFile) { Remove-Item $tempFile -Force -ErrorAction SilentlyContinue }
        $script:trayIcon.Visible = $false
        $script:trayIcon.Dispose()
        [Environment]::Exit(0)
    }.GetNewClosure())
    $script:mainForm.Controls.Add($buttonExit)

    $script:mainForm.Add_FormClosing({
        param($formSender, $formEvent)
        
        if ($script:controllerProcess) {
            try {
                $procId = $script:controllerProcess.Id
                Start-Process -FilePath "taskkill" -ArgumentList "/F", "/T", "/PID", $procId -NoNewWindow -Wait -ErrorAction SilentlyContinue
            } catch { }
        }
        Get-Process pwsh -ErrorAction SilentlyContinue | Where-Object {
            try {
                $cmdLine = (Get-CimInstance Win32_Process -Filter "ProcessId = $($_.Id)" -ErrorAction SilentlyContinue).CommandLine
                $cmdLine -like "*ControllerLauncher_Active*"
            } catch { $false }
        } | ForEach-Object {
            try { Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue } catch { }
        }
        
        $tempFile = "$env:TEMP\ControllerLauncher_Active.ps1"
        if (Test-Path $tempFile) {
            Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
        }
        
        $script:trayIcon.Visible = $false
        $script:trayIcon.Dispose()
        
        [Environment]::Exit(0)
    })

    [System.Windows.Forms.Application]::Run($script:mainForm)
    
    $script:cursorLabel = $null
    $script:scrollLabel = $null
    $script:deadzoneLabel = $null
    
    try {
        $script:mainForm.Dispose()
    } catch { }
}

# === MAIN ENTRY ===
Clear-Host
Write-Host @"
╔═══════════════════════════════════════════════════════╗
║                                                       ║
║    🎮  XBOX CONTROLLER - CONFIGURATOR PRO  🎮         ║
║                                                       ║
║    Control mouse and keyboard with an Xbox controller ║
║    Full GUI configurator                              ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

Write-Host "`nLoading..." -ForegroundColor Yellow
Load-Config

Show-ConfigGUI

Write-Host "`nSee you!" -ForegroundColor Cyan
