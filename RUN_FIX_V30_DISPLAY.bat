@echo off
setlocal
cd /d "%~dp0"
if not exist "V30_DISPLAY_FIX_FILES\mom-ai-report-overlay-v30-20260716.js" (
  echo Patch file not found.
  pause
  exit /b 1
)
copy /Y "V30_DISPLAY_FIX_FILES\mom-ai-report-overlay-v30-20260716.js" "mom-ai-report-overlay-v30-20260716.js" >nul
if errorlevel 1 (
  echo Copy failed. Extract this ZIP inside the mom-ai-report folder and run again.
  pause
  exit /b 1
)
echo V30 display fix installed.
echo Please press Ctrl+F5 in the browser.
pause
