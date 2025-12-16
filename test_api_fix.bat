@echo off
echo Testing Laravel API fixes...
echo.

echo 1. Testing main endpoint...
curl -s http://localhost:8000 | findstr "Laravel" >nul && echo ✓ Laravel is running || echo ✗ Laravel is not running

echo.
echo 2. Testing main-categories endpoint...
curl -s http://localhost:8000/api/main-categories | findstr "data" >nul && echo ✓ main-categories working || echo ✗ main-categories not working

echo.
echo 3. Testing regular categories endpoint...
curl -s http://localhost:8000/api/categories | findstr "data" >nul && echo ✓ categories working || echo ✗ categories not working

echo.
echo Test complete! Check the results above.
pause