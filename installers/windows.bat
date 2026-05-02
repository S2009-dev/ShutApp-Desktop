@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:check_admin
:: Check if the script is running with administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Administrator privileges are required to install ShutApp Desktop.
    echo Attempting to elevate privileges...
    goto elevate
) else (
    goto main
)

:elevate
:: Use a temporary VBS script to elevate privileges
set "vbs_script=%temp%\getadmin.vbs"
echo Set UAC = CreateObject^("Shell.Application"^) > "%vbs_script%"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%vbs_script%"
"%vbs_script%"
del "%vbs_script%" >nul 2>&1
exit /b

:main
::Check if ShutApp Desktop is already running and kill it
tasklist | find /i "ShutApp Desktop.exe" >nul
if %errorlevel% equ 0 (
    taskkill /f /im "ShutApp Desktop.exe" >n
)

:: Fetch the asset URL via PowerShell
set "api_url=https://api.github.com/repos/S2009-dev/ShutApp-Desktop/releases/latest"
set "asset_name=ShutApp-win-x86_64.exe"
set "download_url="

for /f "delims=" %%i in ('powershell -Command "(Invoke-RestMethod -Uri '%api_url%').assets | Where-Object { $_.name -eq '%asset_name%' } | Select-Object -ExpandProperty browser_download_url"') do (
    set "download_url=%%i"
)

if "%download_url%"=="" (
    echo Error: Could not find the file %asset_name% in the latest release.
    pause
    exit /b 1
)

:: Download the asset using bitsadmin
set "startup_folder=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "dest_path=%startup_folder%\ShutApp Desktop.exe"

if not exist "%startup_folder%" mkdir "%startup_folder%"

bitsadmin /transfer "Downloading ShutApp Desktop" /download /priority high "%download_url%" "%dest_path%"

if not exist "%dest_path%" (
    echo Error: Download failed.
    pause
    exit /b 1
)

:: Check if the firewall rule already exists
netsh advfirewall firewall show rule name="ShutApp" >nul 2>&1
if %errorlevel% equ 0 (
    echo The firewall rule "ShutApp" already exists. Ensure it is enabled.
    goto end
)

:: Add the firewall rule (ignore output to avoid false errors)
netsh advfirewall firewall add rule name="ShutApp" dir=in action=allow protocol=TCP localport=7421 >nul 2>&1
if %errorlevel% equ 0 (
    echo Firewall rule "ShutApp" successfully created for TCP port 7421.
) else (
    echo Error: Failed to create the firewall rule.
    pause
    exit /b 1
)

:end
echo Installation completed successfully.
pause
echo Starting ShutApp in background...
start "" "%dest_path%"