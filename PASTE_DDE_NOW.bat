@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo 請先在 Excel / DDE 表格選取「表頭 + 全部股票」，按 Ctrl+C。
echo 然後回到這個視窗按任意鍵。
pause >nul
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\Import-DDE.ps1" -FromClipboard
if errorlevel 1 (
  echo.
  echo 更新失敗。請確認複製內容第一列包含「代號」與「成交價」。
  pause
  exit /b 1
)
echo.
echo 更新完成。瀏覽器會在 60 秒內自動重載，也可按 Ctrl+F5。
pause
