@echo off
chcp 65001 >nul
title 小駿媽媽AI網頁一鍵更新

echo.
echo =========================================
echo   小駿媽媽AI網頁一鍵更新
echo =========================================
echo.
echo 1. 請確認點金靈 DDE 開著
echo 2. 請確認 C:\DDE\yuanta_dde.xlsx 有在跳動
echo 3. 請確認本資料夾是 mom-ai-report GitHub 專案資料夾
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0update_mom_report.ps1"

echo.
echo 如果上面顯示完成，等 30 秒～2 分鐘後刷新媽媽網頁。
echo https://tryitsingle-coder.github.io/mom-ai-report/
echo.
pause
