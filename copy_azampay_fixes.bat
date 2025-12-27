@echo off
echo 🚀 Copying AzamPay fixes to live server...

REM Define paths
set SOURCE_DIR=D:\wamp64\www\masoko_tips_api
set TARGET_DIR=C:\Users\%USERNAME%\Desktop\temp_laravel_copy

echo 📁 Source: %SOURCE_DIR%
echo 📁 Target: %TARGET_DIR%
echo.

REM Check if source directory exists
if not exist "%SOURCE_DIR%" (
    echo ❌ Source directory not found: %SOURCE_DIR%
    pause
    exit /b 1
)

echo 📋 Copying files...

REM Copy the fixed files
echo   ✅ Copying config\services.php...
copy "%SOURCE_DIR%\config\services.php" "%TARGET_DIR%\config\services.php" >nul 2>&1

echo   ✅ Copying app\Services\AzamPayService.php...
copy "%SOURCE_DIR%\app\Services\AzamPayService.php" "%TARGET_DIR%\app\Services\AzamPayService.php" >nul 2>&1

echo   ✅ Copying app\Http\Controllers\Api\AzamPayCheckoutController.php...
copy "%SOURCE_DIR%\app\Http\Controllers\Api\AzamPayCheckoutController.php" "%TARGET_DIR%\app\Http\Controllers\Api\AzamPayCheckoutController.php" >nul 2>&1

echo.
echo 🎉 Files copied to temporary location: %TARGET_DIR%
echo.
echo 📋 Now you need to manually copy these files to your live server:
echo    %TARGET_DIR%\config\services.php
echo    %TARGET_DIR%\app\Services\AzamPayService.php  
echo    %TARGET_DIR%\app\Http\Controllers\Api\AzamPayCheckoutController.php
echo.
echo 🔧 After copying to live server, run:
echo    php artisan config:clear
echo.
pause