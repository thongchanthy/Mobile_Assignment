@echo off
title Mobile Application
echo ==========================================
echo    Starting Mobile App in Chrome
echo ==========================================
cd /d "%~dp0mobile_app"
flutter run -d chrome
pause
