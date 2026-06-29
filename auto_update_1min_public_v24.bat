@echo off
chcp 65001 >nul
title AI Report Auto Update - Dark Theme and Lights
cd /d "%~dp0"
echo ==========================================
echo AI Report Auto Update - Dark Theme + DDE Lights
echo Repo: %cd%
echo ==========================================
:loop
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0update_ai_report_public_v24.ps1"
timeout /t 60 /nobreak >nul
goto loop
