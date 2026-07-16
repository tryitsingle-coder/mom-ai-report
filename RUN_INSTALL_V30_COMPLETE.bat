@echo off
chcp 65001 >nul
set "ROOT=%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%INSTALL_V30_COMPLETE.ps1" -ProjectDir "%ROOT%"
echo.
pause
