@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title Mom AI Report - DDE Update

echo ==================================================
echo Mom AI Report - DDE Clipboard Update
echo ==================================================
echo 1. Select the header row and all stock rows in Excel.
echo 2. Press Ctrl+C.
echo 3. Return here and press any key.
echo.
pause

set "LOG=%TEMP%\mom_ai_dde_import.log"
powershell.exe -NoLogo -NoProfile -STA -ExecutionPolicy Bypass -File "%~dp0tools\Import-DDE.ps1" -FromClipboard > "%LOG%" 2>&1
set "ERR=%ERRORLEVEL%"
type "%LOG%"
echo.

if not "%ERR%"=="0" (
  echo ==================================================
  echo UPDATE FAILED. Error code: %ERR%
  echo Log file: %LOG%
  echo ==================================================
  pause
  exit /b %ERR%
)

echo ==================================================
echo UPDATE COMPLETED.
echo Next: run OPEN_REPORT, then press Ctrl+F5 in browser.
echo ==================================================
pause
exit /b 0
