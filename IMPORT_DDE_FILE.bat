@echo off
chcp 65001 >nul
cd /d "%~dp0"
if "%~1"=="" (
  echo 請把 TSV/TXT 檔案拖曳到本 BAT 上，或在命令列帶入檔案路徑。
  pause
  exit /b 1
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\Import-DDE.ps1" -InputFile "%~1"
pause
