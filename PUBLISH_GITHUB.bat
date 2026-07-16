@echo off
setlocal EnableExtensions
cd /d "%~dp0"

where git >nul 2>&1
if errorlevel 1 (
  echo ERROR: Git was not found. Install Git for Windows first.
  pause
  exit /b 1
)

if not exist ".git\" (
  echo ERROR: This folder has no .git directory.
  echo Copy the .git folder from your old backup into this folder first.
  pause
  exit /b 1
)

rem Never publish local API keys.
git rm -r --cached --ignore-unmatch api_key api_key.txt .env >nul 2>&1

rem Stage the clean V32 replacement, including intended old-file deletions.
git add -A

echo.
echo ===== Changes ready to publish =====
git status --short
echo ====================================
echo.

git diff --cached --quiet
if not errorlevel 1 (
  echo No new changes to publish.
  pause
  exit /b 0
)

set "STAMP=%date:/=-%_%time::=-%"
set "STAMP=%STAMP: =0%"
git commit -m "Mom AI Report V32 update %STAMP%"
if errorlevel 1 (
  echo ERROR: Git commit failed.
  pause
  exit /b 1
)

git push origin main
if errorlevel 1 (
  echo ERROR: Git push failed. Check your network or GitHub login.
  pause
  exit /b 1
)

echo.
echo Publish completed successfully.
pause
