@echo off
chcp 65001 >nul
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\INSTALL_V27_SAFE_OVERLAY.ps1"
echo.
pause
