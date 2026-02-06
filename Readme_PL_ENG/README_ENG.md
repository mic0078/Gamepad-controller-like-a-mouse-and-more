# Controller_Configurator.ps1 (English)

## Description

The **Controller_Configurator.ps1** script allows you to configure a controller to work as a mouse with a graphical user interface (GUI). It lets you customize controller settings according to your preferences, saving the configuration in the `ControllerConfig.json` file.

## Script Features
- Configure controller buttons and axes to control the mouse cursor and clicks.
- User-friendly GUI for selecting and assigning functions.
- Save and load settings from a JSON configuration file.
- Quickly change settings without manually editing files.

## Requirements
- Windows
- PowerShell

## Usage
1. Run the `Controller_Configurator.ps1` script in PowerShell.
2. Use the GUI to assign functions to controller buttons.
3. Save the configuration – settings will be saved in the `ControllerConfig.json` file.

*This project allows you to easily adapt your controller to work as a mouse on a Windows computer.*

## User Manual

1. **Running the script**
   - Right-click the `Controller_Configurator.ps1` file and select "Run with PowerShell" or open PowerShell in the script's folder and enter:
     ```powershell
     ./Controller_Configurator.ps1
     ```

2. **Using the GUI**
   - After launching the script, a graphical window will appear.
   - Assign functions (e.g., mouse movement, clicks, scrolling) to selected controller buttons and axes using the available GUI options.
   - You can test assignments live by observing the cursor's response.

3. **Saving the configuration**
   - When finished, click the "Save" and "Start Controller" buttons.
   - Settings will be saved in the `ControllerConfig.json` file in the same folder.
   - After configuring and saving, do not close the window—minimize it to the system tray.
   - Important: The "CLOSE" button kills its own process (PID) and its "children"—the app will disappear from processes. To keep the controller working, the app should be minimized to the tray.

4. **Changing settings**
   - To change the configuration, simply save new settings. The new settings will reload automatically without needing to use the "START CONTROLLER" button again.

5. **Restoring default settings**
   - Delete the `ControllerConfig.json` file or select the appropriate option in the GUI (if available) to restore factory settings.

---

If you encounter problems, check if the controller is properly connected to the computer and if you have permission to run PowerShell scripts.

Author: MichAel 2026
