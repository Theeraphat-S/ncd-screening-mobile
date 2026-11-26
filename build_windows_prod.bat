@echo off
echo ========================================
echo  Building NCD Screening - Windows (Prod)
echo ========================================

:: Read version from pubspec.yaml
for /f "tokens=2 delims= " %%a in ('findstr /B "version:" pubspec.yaml') do set FULL_VERSION=%%a
for /f "tokens=1 delims=+" %%a in ("%FULL_VERSION%") do set VERSION=%%a
echo  Version: %VERSION%
echo ========================================

echo.
echo [1/5] Killing existing ncd_screening_mobile.exe...
taskkill /f /im ncd_screening_mobile.exe >nul 2>&1


echo.
echo [4/5] Building Windows release...
call fvm flutter build windows --dart-define=flavor=prod
if %errorlevel% neq 0 (
    echo.
    echo BUILD FAILED!
    pause
    exit /b 1
)

echo.
echo [5/5] Creating zip...
set ZIP_NAME=NCD-Screening-Windows-v%VERSION%.zip
set RELEASE_DIR=%~dp0build\windows\x64\runner\Release
set OUTPUT_ZIP=%~dp0build\%ZIP_NAME%

:: Delete old zip if exists
if exist "%OUTPUT_ZIP%" del "%OUTPUT_ZIP%"

:: Use PowerShell to create zip
powershell -Command "Compress-Archive -Path '%RELEASE_DIR%\*' -DestinationPath '%OUTPUT_ZIP%' -Force"

if %errorlevel% neq 0 (
    echo.
    echo ZIP FAILED!
    pause
    exit /b 1
)

echo.
echo ========================================
echo  BUILD SUCCESS!
echo  Output: build\%ZIP_NAME%
echo ========================================

pause
