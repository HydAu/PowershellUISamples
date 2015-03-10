# converted from Powershell Module back to standalone script to refactor
# origin: http://www.automatedops.com/blog/2013/06/07/get-storedcredentials-module/

function Get-StoredCredential
{
  [CmdletBinding()]
  [OutputType([pscredential])]
  param
  (
    [Parameter(Mandatory,Position = 0)]
    [ValidateNotNullOrEmpty()]
    [Alias("Address","Location","TargetName")]
    [string]$Name
  )
  try
  {
    # http://stackoverflow.com/questions/19410186/c-sharp-using-credwrite-to-access-c
    Add-Type -ErrorAction Stop -TypeDefinition @"
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using Microsoft.Win32.SafeHandles;
using System.Data;
using System.Diagnostics;
using System.Reflection;
using System.Text;

namespace ADVAPI32
{
    public partial class Util
    {

        public static string ReadCred(string key, UInt32 type = (UInt32) CRED_TYPE.GENERIC )
        {
            // Validations.

            IntPtr nCredPtr = IntPtr.Zero;
            string readPasswordText = null;
             bool read = false;
            // Make the API call using the P/Invoke signature
            // http://www.pinvoke.net/default.aspx/advapi32/CredRead.html

            read = CredRead(key, (CRED_TYPE)type, 0,  out  nCredPtr);
            int lastError = Marshal.GetLastWin32Error();
            // If the API was successful then...
            if (read)
            {
                using (CriticalCredentialHandle critCred = new CriticalCredentialHandle(nCredPtr))
                {
                    Credential cred = critCred.GetCredential();
                    readPasswordText = cred.CredentialBlob;
                }
            }
            else
            {
                readPasswordText = string.Empty;

                //1168 is "element not found" -- ignore that one and return empty string:
                if (lastError != 1168)
                {
                    string message = string.Format("ReadCred failed with the error code {0}.", lastError);
                    throw new Exception(message);
                }

            }
            return readPasswordText;
        }



        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
        public struct NativeCredential
        {
            public UInt32 Flags;
            public CRED_TYPE Type;
            public IntPtr TargetName;
            public IntPtr Comment;
            public System.Runtime.InteropServices.ComTypes.FILETIME LastWritten;
            public UInt32 CredentialBlobSize;
            public IntPtr CredentialBlob;
            public CRED_PERSIST Persist;
            public UInt32 AttributeCount;
            public IntPtr Attributes;
            public IntPtr TargetAlias;
            public IntPtr UserName;

            internal static NativeCredential GetNativeCredential(Credential cred)
            {
                NativeCredential ncred = new NativeCredential();
                ncred.AttributeCount = 0;
                ncred.Attributes = IntPtr.Zero;
                ncred.Comment = IntPtr.Zero;
                ncred.TargetAlias = IntPtr.Zero;
                ncred.Type = CRED_TYPE.GENERIC;
                ncred.Persist = CRED_PERSIST.SESSION;
                ncred.CredentialBlobSize = (UInt32)cred.CredentialBlobSize;
                ncred.TargetName = Marshal.StringToCoTaskMemUni(cred.TargetName);
                ncred.CredentialBlob = Marshal.StringToCoTaskMemUni(cred.CredentialBlob);
                ncred.UserName = Marshal.StringToCoTaskMemUni(System.Environment.UserName);
                return ncred;
            }
        }

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
        public struct Credential
        {
            public UInt32 Flags;
            public CRED_TYPE Type;
            public string TargetName;
            public string Comment;
            public System.Runtime.InteropServices.ComTypes.FILETIME LastWritten;
            public UInt32 CredentialBlobSize;
            public string CredentialBlob;
            public CRED_PERSIST Persist;
            public UInt32 AttributeCount;
            public IntPtr Attributes;
            public string TargetAlias;
            public string UserName;
        }

        public enum CRED_TYPE : uint
        {
            GENERIC = 1,
            DOMAIN_PASSWORD = 2,
            DOMAIN_CERTIFICATE = 3,
            DOMAIN_VISIBLE_PASSWORD = 4,
            GENERIC_CERTIFICATE = 5,
            DOMAIN_EXTENDED = 6,
            MAXIMUM = 7,      // Maximum supported cred type
            MAXIMUM_EX = (MAXIMUM + 1000),  // Allow new applications to run on old OSes
        }


        public enum CRED_PERSIST : uint
        {
            SESSION = 1,
            LOCAL_MACHINE = 2,
            ENTERPRISE = 3,
        }
        
        public class CriticalCredentialHandle : CriticalHandleZeroOrMinusOneIsInvalid
        {
            public CriticalCredentialHandle(IntPtr preexistingHandle)
            {
                SetHandle(preexistingHandle);
            }

            public Credential GetCredential()
            {
                if (!IsInvalid)
                {
                    NativeCredential ncred = (NativeCredential)Marshal.PtrToStructure(handle,
                          typeof(NativeCredential));
                    Credential cred = new Credential();
                    cred.CredentialBlobSize = ncred.CredentialBlobSize;
                    cred.CredentialBlob = Marshal.PtrToStringUni(ncred.CredentialBlob,
                          (int)ncred.CredentialBlobSize / 2);
                    cred.UserName = Marshal.PtrToStringUni(ncred.UserName);
                    cred.TargetName = Marshal.PtrToStringUni(ncred.TargetName);
                    cred.TargetAlias = Marshal.PtrToStringUni(ncred.TargetAlias);
                    cred.Type = ncred.Type;
                    cred.Flags = ncred.Flags;
                    cred.Persist = (CRED_PERSIST)ncred.Persist;
                    // cred.Persist = ncred.Persist;
                    return cred;
                }
                else
                {
                    throw new InvalidOperationException("Invalid CriticalHandle!");
                }
            }

            override protected bool ReleaseHandle()
            {
                if (!IsInvalid)
                {
                    CredFree(handle);
                    SetHandleAsInvalid();
                    return true;
                }
                return false;
            }
        }

        [DllImport("Advapi32.dll", EntryPoint = "CredReadW", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern bool CredRead(string target, CRED_TYPE type, int reservedFlag, out IntPtr CredentialPtr);

        [DllImport("Advapi32.dll", EntryPoint = "CredFree", SetLastError = true)]
        public static extern bool CredFree([In] IntPtr cred);

    }

}
"@ -ReferencedAssemblies 'System.Data.dll'
  }
  catch [exception]
  {
    Write-Error -Message "Could not load custom type. $($_.Exception.Message)"
  }


  $nCredPtr = New-Object IntPtr

  $success = [ADVAPI32.Util]::CredRead($Name,1,0,[ref]$nCredPtr)

  if ($success) {
    $critCred = New-Object ADVAPI32.Util+CriticalCredentialHandle $nCredPtr
    $cred = $critCred.GetCredential()
    $username = $cred.UserName
    $securePassword = $cred.CredentialBlob | ConvertTo-SecureString -AsPlainText -Force
    $cred = $null
    Write-Output (New-Object System.Management.Automation.PSCredential $username,$securePassword)
  } else {
    Write-Verbose "No credentials where found in Windows Credential Manager for TargetName: $Name"
  }
  try {
    $str_res = [ADVAPI32.Util]::ReadCred($name)
    Write-Output $str_res
  }
  catch [exception]
  {
    Write-Output "Could not invoke method:"
    Write-Output $_.Exception.Message
  }
  try {
    $str_res = [ADVAPI32.Util]::ReadCred('SERGUEIK42',[uint32]2)
    Write-Output $str_res
  }
  catch [exception]
  {
    Write-Output "Could not invoke method:"
    Write-Output $_.Exception.Message
  }

}

Get-StoredCredential -Name 'generic_entry'

