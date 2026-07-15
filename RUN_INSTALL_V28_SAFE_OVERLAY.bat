@echo off
chcp 65001 >nul
setlocal
cd /d "%~dp0"
echo ==========================================
echo Mom AI Report V28 Safe Overlay
echo ==========================================
echo.
echo This installer keeps both api_key files untouched.
echo It only backs up index.html and injects the V28 JS overlay.
echo.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0INSTALL_V28_SAFE_OVERLAY.ps1"
echo.
if errorlevel 1 (
  echo Installation failed. Please copy the full error text.
) else (
  echo Installation completed. Open the webpage and press Ctrl+F5.
)
echo.
pause
