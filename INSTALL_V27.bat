@echo off
chcp 65001 >nul
title mom-ai-report V27 安全覆蓋
cd /d "%~dp0"

echo ==========================================
echo mom-ai-report V27 安全覆蓋
echo ==========================================

if not exist "..\backup" mkdir "..\backup"

set TS=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TS=%TS: =0%
set BK=..\backup\before_V27_%TS%
mkdir "%BK%"

if exist "..\index.html" copy /Y "..\index.html" "%BK%\index.html" >nul
if exist "..\styles\v27.css" copy /Y "..\styles\v27.css" "%BK%\v27.css" >nul

if not exist "..\styles" mkdir "..\styles"
copy /Y "v27_files\index.html" "..\index.html" >nul
copy /Y "v27_files\v27.css" "..\styles\v27.css" >nul

echo.
echo 已完成：
echo 1. 舊版已備份到 backup 資料夾
echo 2. index.html 已更新
echo 3. styles\v27.css 已更新
echo 4. app.py、config、data、tools、api_key 都未更動
echo.
pause
