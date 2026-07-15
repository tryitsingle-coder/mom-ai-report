@echo off
chcp 65001 >nul
setlocal
cd /d "%~dp0"

echo ==========================================
echo V27 Safe Overlay Installer - FIXED
echo ==========================================
echo.

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0INSTALL_V27_SAFE_OVERLAY_FIXED.ps1"

echo.
if errorlevel 1 (
  echo Installation failed. Please copy the full error text.
) else (
  echo Installation completed. Open the webpage and press Ctrl+F5.
)
echo.
pause
