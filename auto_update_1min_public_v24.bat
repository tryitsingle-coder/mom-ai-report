@echo off
setlocal
title AI Report Auto Update - Public Mode V27.0 0701 Close FIX
pushd "%~dp0"
echo ==========================================
echo AI Report Auto Update - Every 1 minute
echo V27.0 FIX: 2026-07-01 close package
echo Working folder: %CD%
echo ==========================================
:loop
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0update_ai_report_public_v24.ps1"
echo.
echo Next update in 60 seconds. Press Ctrl+C to stop.
timeout /t 60 /nobreak > nul
goto loop
