@echo off
title Flutter Mobile App
echo ==========================================
echo    Starting Flutter App in Chrome
echo ==========================================
cd /d "%~dp0flutter_product_crud"
flutter run -d chrome
pause
