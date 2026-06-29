@echo off
chcp 65001 >nul
title AI Report Run Once - Dark Theme and Lights
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0update_ai_report_public_v24.ps1"
pause
