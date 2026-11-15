@echo off
title Backend API Server
echo ==========================================
echo    Starting Backend API Server (Port 8000)
echo ==========================================
cd /d "%~dp0backend_api"
php artisan storage:link
php artisan serve --host=0.0.0.0 --port=8000
pause
