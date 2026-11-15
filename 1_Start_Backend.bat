@echo off
title Laravel Backend API
echo ==========================================
echo    Starting Laravel Backend API (Port 8000)
echo ==========================================
cd /d "%~dp0laravel_api"
php artisan storage:link
php artisan serve --host=0.0.0.0 --port=8000
pause
