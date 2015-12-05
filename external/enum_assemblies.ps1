# origin http://powershell.com/cs/media/p/43529.aspx
# Author: greg zakharov 
Add-Type @' 
using System;
using System.Text;
using System.Reflection;
using System.Collections.Generic;
using System.Security.Permissions;
using System.Runtime.InteropServices;

[assembly: AssemblyVersion("1.0.0.0")]
[assembly: CLSCompliant(true)]
[assembly: ComVisible(false)]

namespace GacView
{
    [
      ComImport,
      InterfaceType(ComInterfaceType.InterfaceIsIUnknown),
      Guid("CD193BC0-B4BC-11d2-9833-00C04FC31D2E")
    ]
    internal interface IAssemblyName
    {
        Int32 SetProperty();
        Int32 GetProperty();
        Int32 Finalize();
        [PreserveSig]
        Int32 GetDisplayName(
            StringBuilder szDisplayName,
            ref Int32 pccDisplayName,
            Int32 dwDisplayFlags
        );
        Int32 Reserved();
        Int32 GetName();
        Int32 GetVersion();
        Int32 IsEqual();
        Int32 Clone();
    }

    [
      ComImport,
      InterfaceType(ComInterfaceType.InterfaceIsIUnknown),
      Guid("21b8916c-f28e-11d2-a473-00c04f8ef448")
    ]
    internal interface IAssemblyEnum
    {
        [PreserveSig]
        Int32 GetNextAssembly(
            IntPtr pvReserved,
            out IAssemblyName ppName,
            Int32 dwFlags
        );
        Int32 Reset();
        Int32 Clone();
    }

    internal static class NativeMethods
    {
        [DllImport("fusion.dll")]
        internal static extern Int32 CreateAssemblyEnum(
            out IAssemblyEnum pEnum,
            IntPtr pUnkReserved,
            IAssemblyName pName,
            Int32 dwFlags,
            IntPtr pwReserved
        );

        [DllImport("fusion.dll")]
        internal static extern Int32 CreateAssemblyNameObject(
            out IAssemblyName ppAssemblyNameObj,
            [MarshalAs(UnmanagedType.LPWStr)] 
            String szAssemblyName,
            Int32 dwFlags,
            IntPtr pvReserved
        );
    }

    public sealed class Tool
    {
        private Tool() { }

        [EnvironmentPermissionAttribute(SecurityAction.LinkDemand, Unrestricted = true)]
        public static Dictionary<String, String> EnumAssemblies(String asm)
        {
            IAssemblyName ian = null;
            IAssemblyEnum iae;
            Int32 res, len;
            StringBuilder sb;
            AssemblyName an;
            Dictionary<String, String> dic = new Dictionary<String, String>();

            if (!String.IsNullOrEmpty(asm))
            {
                res = NativeMethods.CreateAssemblyNameObject(out ian, asm, 0, IntPtr.Zero);
                if (res != 0) Marshal.ThrowExceptionForHR(res);
            }

            res = NativeMethods.CreateAssemblyEnum(out iae, IntPtr.Zero, ian, 2, IntPtr.Zero);
            if (res != 0) Marshal.ThrowExceptionForHR(res);

            while (iae.GetNextAssembly(IntPtr.Zero, out ian, 0) == 0)
            {
                sb = new StringBuilder(512);
                len = sb.Capacity;
                if ((res = ian.GetDisplayName(sb, ref len, 0xA7)) != 0) Marshal.ThrowExceptionForHR(res);
                an = new AssemblyName(sb.ToString());
                dic.Add(an.FullName, an.ProcessorArchitecture.ToString());
            }
            return dic;
        }
    } 
}
'@ 
# Example 1: 
# [GacView.Tool]::EnumAssemblies($null) | Out-GridView -Title GACView 
# Example 2: 
# [GacView.Tool]::EnumAssemblies('System.Xml') | Format-List * 

