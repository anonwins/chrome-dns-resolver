@echo off
setlocal

echo Browser Resolver v2.1
echo =====================
echo.
echo This tool allows you to force Chrome or Brave to resolve a domain name to a specific IP address.
echo It's useful for testing websites that haven't had their DNS updated yet or for local development.
echo You can also save the configuration as a desktop shortcut for quick access.
echo.

rem Determine default browser executable path from common installations (Chrome first, then Brave)
if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" (
    set "BROWSER_PATH=C:\Program Files\Google\Chrome\Application\chrome.exe"
) else if exist "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" (
    set "BROWSER_PATH=C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
) else if exist "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe" (
    set "BROWSER_PATH=C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe"
) else if exist "C:\Program Files (x86)\BraveSoftware\Brave-Browser\Application\brave.exe" (
    set "BROWSER_PATH=C:\Program Files (x86)\BraveSoftware\Brave-Browser\Application\brave.exe"
) else (
    echo Error: Neither Chrome nor Brave browser found.
    pause
    exit /b 1
)

rem Determine the process name based on the selected browser
echo %BROWSER_PATH% | findstr /I "chrome" >nul
if %ERRORLEVEL%==0 (
    set "PROCESS_NAME=chrome.exe"
) else (
    echo %BROWSER_PATH% | findstr /I "brave" >nul
    if %ERRORLEVEL%==0 (
        set "PROCESS_NAME=brave.exe"
    ) else (
        set "PROCESS_NAME="
    )
)

rem Check if the browser is currently running
:check_browser
tasklist /FI "IMAGENAME eq %PROCESS_NAME%" 2>NUL | find /I /N "%PROCESS_NAME%">NUL
if "%ERRORLEVEL%"=="0" (
    if not defined browserMessage (
        echo %PROCESS_NAME% is currently running. Please close all browser windows before continuing.
        set browserMessage=1
    )
    timeout /t 2 /nobreak >nul
    goto check_browser
)

rem Browser is closed, wait a moment before continuing
timeout /t 2 /nobreak >nul

rem Prompt user for the domain name and IP address to map
set /p HOST_NAME="Enter the host name: "
set /p IP_ADDRESS="Enter the IP address: "

rem Generate shortcut filename based on host
set SHORTCUT_NAME=%HOST_NAME%.lnk
set SHORTCUT_PATH=%USERPROFILE%\Desktop\%SHORTCUT_NAME%

rem Prompt user to create a shortcut
echo.
set /p CREATE_SHORTCUT="Would you like to save this as a shortcut? (y/n): "
if /i "%CREATE_SHORTCUT%"=="y" (
    rem Create .lnk shortcut using PowerShell
    powershell -Command "$WS = New-Object -ComObject WScript.Shell; $SC = $WS.CreateShortcut('%USERPROFILE%\Desktop\%HOST_NAME%.lnk'); $SC.TargetPath = '%BROWSER_PATH%'; $SC.Arguments = '--host-resolver-rules=\""MAP %HOST_NAME% %IP_ADDRESS%\"" http://%HOST_NAME%'; $SC.Save()"
    echo Shortcut created at %SHORTCUT_PATH%
    set shortcutCreated=1
)

rem If shortcut was created, ask user to run it. Otherwise, launch the browser directly.
if defined shortcutCreated (
    goto ask_launch
) else (
    goto launch_browser
)

rem Ask user to run the shortcut
:ask_launch
echo.
set /p LAUNCH_SHORTCUT="Would you like to run the shortcut now? (y/n): "
if /i "%LAUNCH_SHORTCUT%" neq "y" (
    pause
    goto after_launch
)

rem Launch the browser with the host resolver rules
:launch_browser
start "" "%BROWSER_PATH%" --host-resolver-rules="MAP %HOST_NAME% %IP_ADDRESS%" http://%HOST_NAME%
:after_launch
