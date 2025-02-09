@echo off
setlocal

rem Configure Chrome path here
set CHROME_PATH="C:\Program Files\Google\Chrome\Application\chrome.exe"
echo Chrome Resolver v2
echo ==================
echo.
echo This tool allows you to force Chrome to resolve a domain name to a specific IP address.
echo It's useful for testing websites that haven't had their DNS updated yet or for local development.
echo You can also save the configuration as a desktop shortcut for quick access.
echo.

rem Check if Chrome exists
if not exist %CHROME_PATH% (
    echo Error: Chrome not found at %CHROME_PATH%
    echo Please ensure Chrome is installed in the configured location.
    pause
    exit /b 1
)

rem Check if Chrome is running
:check_chrome
tasklist /FI "IMAGENAME eq chrome.exe" 2>NUL | find /I /N "chrome.exe">NUL
if "%ERRORLEVEL%"=="0" (
    if not defined chromeMessage (
        echo Chrome is currently running. Please close all Chrome windows before continuing.
        set chromeMessage=1
    )
    timeout /t 2 /nobreak >nul
    goto check_chrome
)

rem Chrome is closed, wait x seconds before continuing
timeout /t 2 /nobreak >nul

rem Prompt user for the domain name and IP address to map
set /p HOST_NAME="Enter the host name: "
set /p IP_ADDRESS="Enter the IP address: "
rem Generate shortcut filename based on host
set SHORTCUT_NAME=%HOST_NAME%.lnk
set SHORTCUT_PATH=%USERPROFILE%\Desktop\%SHORTCUT_NAME%

echo.
set /p CREATE_SHORTCUT="Would you like to save this as a shortcut? (y/n): "
if /i "%CREATE_SHORTCUT%"=="y" (
    rem Create .lnk shortcut using PowerShell
    powershell -Command "$WS = New-Object -ComObject WScript.Shell; $SC = $WS.CreateShortcut('%USERPROFILE%\Desktop\%HOST_NAME%.lnk'); $SC.TargetPath = '%CHROME_PATH%'; $SC.Arguments = '--host-resolver-rules=\""MAP %HOST_NAME% %IP_ADDRESS%\"" http://%HOST_NAME%'; $SC.Save()"
    echo Shortcut created at %SHORTCUT_PATH%
    set shortcutCreated=1
)

if defined shortcutCreated (
    goto ask_launch
) else (
    goto launch_chrome
)

:ask_launch
echo.
set /p LAUNCH_SHORTCUT="Would you like to run the shortcut now? (y/n): "
if /i "%LAUNCH_SHORTCUT%" neq "y" (
    pause
    goto after_launch
)

rem Launch Chrome with host resolver rules to map the domain to the specified IP
:launch_chrome
start "" %CHROME_PATH% --host-resolver-rules="MAP %HOST_NAME% %IP_ADDRESS%" http://%HOST_NAME%
:after_launch
