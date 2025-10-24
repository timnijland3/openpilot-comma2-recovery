@echo off
:: Check if running as Administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Set working directory to the location of this batch file
cd /d "%~dp0"

:: Run PowerShell script with elevated permissions
echo Running PowerShell script: scripts\flash_neos.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File "scripts\flash_neos.ps1"

echo.
echo ===============================================
echo Script finished. Press any key to close this window.
pause >nul
