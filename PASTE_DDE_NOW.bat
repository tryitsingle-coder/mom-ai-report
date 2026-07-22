@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 950 >nul
cd /d "%~dp0"
title Mom AI Report - DDE 一鍵同步公開網頁

echo ==================================================
echo Mom AI Report - DDE 一鍵更新 + GitHub 公開同步
echo ==================================================
echo.
echo 1. 在 Excel 選取「表頭 + 全部股票列」
echo 2. 按 Ctrl+C
echo 3. 回到這個視窗後按任意鍵
echo.
pause

set "IMPORTER=%~dp0tools\Import-DDE.ps1"
set "LIVE=%~dp0data\live.js"
set "LOG=%TEMP%\mom_ai_dde_import.log"

if not exist "%IMPORTER%" (
  echo [錯誤] 找不到：
  echo %IMPORTER%
  echo.
  echo 請確認 tools 資料夾與 Import-DDE.ps1 已一起覆蓋。
  pause
  exit /b 2
)

powershell.exe -NoLogo -NoProfile -STA -ExecutionPolicy Bypass -File "%IMPORTER%" -FromClipboard > "%LOG%" 2>&1
set "ERR=%ERRORLEVEL%"
type "%LOG%"
echo.

if not "%ERR%"=="0" (
  echo ==================================================
  echo [失敗] DDE 匯入失敗，錯誤碼：%ERR%
  echo 記錄：%LOG%
  echo ==================================================
  pause
  exit /b %ERR%
)

if not exist "%LIVE%" (
  echo [失敗] 匯入完成後仍找不到 data\live.js
  pause
  exit /b 3
)

echo ==================================================
echo [成功] 本機 data\live.js 已更新
for %%F in ("%LIVE%") do echo 修改時間：%%~tF
echo ==================================================
echo.

where git >nul 2>&1
if errorlevel 1 (
  echo [提醒] 找不到 Git，因此只更新本機。
  echo 請稍後使用 GitHub Desktop Commit / Push。
  start "" "%~dp0index.html"
  pause
  exit /b 0
)

if not exist "%~dp0.git\" (
  echo [提醒] 這個資料夾沒有 .git，因此只更新本機。
  start "" "%~dp0index.html"
  pause
  exit /b 0
)

echo 正在同步到 GitHub 公開網頁...
git add data/live.js
git diff --cached --quiet
if not errorlevel 1 (
  echo GitHub 已經是相同資料，不需要重複提交。
) else (
  powershell -NoProfile -Command "$s=Get-Date -Format 'yyyy-MM-dd HH:mm:ss'; git commit -m ('DDE live update ' + $s)"
  if errorlevel 1 (
    echo [失敗] Git commit 失敗。
    pause
    exit /b 4
  )
  git push origin main
  if errorlevel 1 (
    echo [失敗] Git push 失敗，請檢查網路或 GitHub 登入。
    pause
    exit /b 5
  )
  echo [成功] 已推送 GitHub。
)

echo.
echo 公開網頁通常需要約 30 秒到 2 分鐘部署。
echo 現在先開本機報告確認即時價格：
start "" "%~dp0index.html"
echo.
echo 稍後公開網址請按 Ctrl+F5：
echo https://tryitsingle-coder.github.io/mom-ai-report/
echo.
pause
exit /b 0
