@echo off
chcp 65001 >nul
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File ".\install_V27_完整覆蓋.ps1" -IndexPath ".\index.html"
echo.
pause
