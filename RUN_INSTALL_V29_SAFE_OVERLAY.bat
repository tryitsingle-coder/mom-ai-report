@echo off
setlocal
chcp 65001 >nul
title Mom AI Report V29.2 Installer
echo ==========================================
echo Mom AI Report V29 Safe Overlay Installer
echo ==========================================
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0INSTALL_V29_SAFE_OVERLAY.ps1"
echo.
if errorlevel 1 (
  echo Installation failed. Please copy these V29 files into the mom-ai-report folder and run again.
) else (
  echo Installation completed.
  echo Now run auto_update_1min_public_v24.bat and refresh the webpage with Ctrl+F5.
)
echo.
pause
