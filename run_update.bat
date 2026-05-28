@echo off
title Mom AI Report Updater
echo =========================================
echo Mom AI Report Updater
echo =========================================
echo.
echo Check:
echo 1. Yuanta DDE is running
echo 2. C:\DDE\yuanta_dde.xlsx is open and updating
echo 3. This folder is your mom-ai-report GitHub repo
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0update_mom_report.ps1"

echo.
echo Done. Wait 30 seconds to 2 minutes, then refresh:
echo https://tryitsingle-coder.github.io/mom-ai-report/
echo.
pause
