@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0build-apk.ps1" %*
set "APK_BUILD_EXIT_CODE=%ERRORLEVEL%"
echo.
if "%APK_BUILD_EXIT_CODE%"=="0" (
    echo APK ready: %~dp0apk\Turbo-Kart-Rally-Samsung.apk
) else (
    echo APK build failed. See the error above.
)
pause
exit /b %APK_BUILD_EXIT_CODE%
