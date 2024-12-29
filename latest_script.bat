@echo off
color 02
setlocal enabledelayedexpansion

echo ========================================
echo Checking for administrative privileges...
echo ========================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ========================================
    echo [argon admin perms checker] Please run this script as an administrator!
    echo Requesting administrative privileges...
    echo ========================================
    powershell -Command "Start-Process cmd -ArgumentList '/c %~dpnx0' -Verb RunAs"
    exit /b
) else (
    echo Admin privileges check passed.
    echo ========================================
)

echo ========================================
echo Defining download URLs...
echo ========================================
set "VC_REDIST_X64=https://aka.ms/vs/16/release/vc_redist.x64.exe"
set "VC_REDIST_X86=https://aka.ms/vs/16/release/vc_redist.x86.exe"
set "NET_FRAMEWORK=https://go.microsoft.com/fwlink/?LinkId=2085155"
set "WEBVIEW2=https://go.microsoft.com/fwlink/p/?LinkId=2124703"
set "ROBLOX_INSTALLER=https://setup.rbxcdn.com/RobloxPlayerLauncher.exe"
set "NODEJS=https://nodejs.org/dist/v20.8.0/node-v20.8.0-x64.msi"
set "NODEJSX86=https://nodejs.org/dist/v20.8.0/node-v20.8.0-x86.msi"
set "BLOXSTRAP_INSTALLER=https://github.com/bloxstraplabs/bloxstrap/releases/download/v2.8.5/Bloxstrap-v2.8.5.exe"

echo Download URLs set.
echo ========================================

echo ========================================
echo Checking if download directory exists...
echo ========================================
set "DOWNLOAD_DIR=C:\downloads"
if not exist "%DOWNLOAD_DIR%" (
    echo Creating download directory...
    mkdir "%DOWNLOAD_DIR%"
) else (
    echo Download directory already exists.
)

echo Download directory set to: %DOWNLOAD_DIR%.
echo ========================================

echo ========================================
echo Starting file downloads...
echo ========================================

curl -L %VC_REDIST_X64% -o "%DOWNLOAD_DIR%\vc_redist_x64.exe"
echo vc_redist_x64.exe downloaded.
echo ----------------------------------------

curl -L %VC_REDIST_X86% -o "%DOWNLOAD_DIR%\vc_redist_x86.exe"
echo vc_redist_x86.exe downloaded.
echo ----------------------------------------

curl -L %NET_FRAMEWORK% -o "%DOWNLOAD_DIR%\net48-installer.exe"
echo net48-installer.exe downloaded.
echo ****************************************
echo * THIS MAY TAKE UP TO 5 MINUTES OR MORE. PLEASE BE PATIENT. *
echo ****************************************
echo ----------------------------------------

curl -L %WEBVIEW2% -o "%DOWNLOAD_DIR%\webview2-installer.exe"
echo webview2-installer.exe downloaded.
echo ----------------------------------------

curl -L %NODEJS% -o "%DOWNLOAD_DIR%\nodejs-installer.msi"
echo nodejs-installer.msi downloaded.
echo ----------------------------------------

curl -L %NODEJSX86% -o "%DOWNLOAD_DIR%\nodejs-installer-x86.msi"
echo nodejs-installer-x86.msi downloaded.
echo ----------------------------------------

curl -L %BLOXSTRAP_INSTALLER% -o "%DOWNLOAD_DIR%\BloxstrapInstaller.exe"
echo BloxstrapInstaller.exe downloaded.
echo ----------------------------------------

echo All files downloaded.
echo ========================================

echo [argon dependencies installer] Installing required dependencies...
start /wait "" "%DOWNLOAD_DIR%\vc_redist_x64.exe" /quiet /norestart
echo vc_redist_x64.exe installed.
echo ----------------------------------------

start /wait "" "%DOWNLOAD_DIR%\vc_redist_x86.exe" /quiet /norestart
echo vc_redist_x86.exe installed.
echo ----------------------------------------

start /wait "" "%DOWNLOAD_DIR%\net48-installer.exe" /quiet /norestart
echo net48-installer.exe installed.
echo ****************************************
echo * THIS MAY TAKE UP TO 5 MINUTES OR MORE. PLEASE BE PATIENT. *
echo ****************************************
echo ----------------------------------------

start /wait "" "%DOWNLOAD_DIR%\webview2-installer.exe" /silent /install
echo webview2-installer.exe installed.
echo ----------------------------------------

start /wait msiexec.exe /i "%DOWNLOAD_DIR%\nodejs-installer.msi" /quiet /norestart
echo nodejs-installer.msi installed.
echo ----------------------------------------

start /wait msiexec.exe /i "%DOWNLOAD_DIR%\nodejs-installer-x86.msi" /quiet /norestart
echo nodejs-installer-x86.msi installed.
echo ----------------------------------------

echo [argon dependencies installer] Installed required dependencies!
echo ========================================

echo ----------
echo WARNING: If you choose to delete Bloxstrap, make sure to back up your settings as they will be permanently deleted.
echo Your settings could not be loaded after reinstallation if not backed up.
echo Do you want to delete Bloxstrap from your PC? (Y/N)
echo ----------
set /p deleteBloxstrap="Choice: "

if /I "%deleteBloxstrap%"=="Y" (
    echo [argon fixer] Deleting Bloxstrap...
    del /q /s "%localappdata%\Bloxstrap" >nul 2>&1
    echo Bloxstrap deleted.
    echo ----------------------------------------
) else (
    echo Skipping Bloxstrap deletion.
    echo ----------------------------------------
)

echo [argon fixer] Fixing...
del /q /s "%localappdata%\Roblox" >nul 2>&1
del /q /s "%appdata%\Roblox" >nul 2>&1
echo ----------------------------------------

echo Installing Roblox...
curl -L %ROBLOX_INSTALLER% -o "%DOWNLOAD_DIR%\RobloxInstaller.exe"
start /wait "" "%DOWNLOAD_DIR%\RobloxInstaller.exe" /silent
echo Roblox installed.
echo ----------------------------------------

echo ----------
echo Do you want to install Bloxstrap on your PC? (Y/N)
echo Learn more about Bloxstrap: https://github.com/bloxstraplabs/bloxstrap
echo ----------
set /p installBloxstrap="Choice: "

if /I "%installBloxstrap%"=="Y" (
    echo Installing Bloxstrap...
    start /wait "" "%DOWNLOAD_DIR%\BloxstrapInstaller.exe" /silent
    echo Bloxstrap installed.
    echo ----------------------------------------
) else (
    echo Skipping Bloxstrap installation.
    echo ----------------------------------------
)

echo ----------
echo Do you want to open the website to download the latest version of Argon? (Y/N)
echo NOTE: You must download the latest version of Argon, as versions like 2.0.1 are unstable.
echo ----------
set /p openWebsite="Choice: "

if /I "%openWebsite%"=="Y" (
    echo Opening https://getargon.xyz/ ...
    start https://getargon.xyz/
    echo ----------------------------------------
) else (
    echo Skipping website opening.
    echo ----------------------------------------
)

echo Running system health checks...

echo Checking component store corruption...
DISM /Online /Cleanup-Image /CheckHealth
echo Component store corruption check completed.

echo Scanning component store for corruption...
DISM /Online /Cleanup-Image /ScanHealth
echo Component store corruption scan completed.

echo Verifying component store corruption...
DISM /Online /Cleanup-Image /VerifyHealth
echo Component store corruption verification completed.

echo Restoring component store health...
DISM /Online /Cleanup-Image /RestoreHealth
echo Component store health restored.

echo Running system file checker...
sfc /scannow
echo System file check completed.
echo ========================================

echo Flushing DNS...
ipconfig /flushdns
echo DNS cache flushed.
echo ========================================

:end
cls
echo ************************************************************
echo * MADE BY M1JP WITH BERY *
echo ************************************************************
echo * Argon not working/not stable on Win 11 24H2 and Win 10 22H2 *
echo * No solutions may help (do win + r, type winver to check) *
echo ************************************************************
echo * Thank you for your patience. This troubleshooter doesn't guarantee to solve problems by 100%. *
echo ************************************************************
echo * Would you like to reboot your PC now? (Y/N) *
echo ************************************************************
set /p rebootPC="Choice: "

if /I "%rebootPC%"=="Y" (
    echo Rebooting PC...
    shutdown /r /t 0
) else (
    echo Skipping reboot.
    echo Press Enter to close.
    pause >nul
)
