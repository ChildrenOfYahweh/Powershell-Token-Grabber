@echo off

cd /d %~dp0

mkdir dist 2>nul

del dist\*.* /q

fyne package --os windows --exe dist\Builder.exe --appID com.builder.app --release

timeout /t 1 /nobreak >nul

dist\Builder.exe

echo %errorlevel%

pause

exit
