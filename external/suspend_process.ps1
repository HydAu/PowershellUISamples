# http://poshcode.org/5635
#requires -version 2.0

<#
    .Synopsis
        Output the results of a command in a Windows Form
    .Description
        Output the results of a command in a Windows Form with possibility to add buttons with actions 
    .Example
    
        out-form 
                 -title "Services" 
                 -data (get-service) 
                 -columnNames ("Name", "Status") 
                 -columnProperties ("DisplayName", "Status") 
                 -actions @{"Start" = {$_.start()}; "Stop" = {$_.stop()}; }
    #>
# http://stackoverflow.com/questions/11010165/how-to-suspend-resume-a-process-in-windows
# http://poshcode.org/2189

function Out-Form {
  param(
    $title = '', 
    $data = $null,
    $columnNames = $null,
    $columnTag,
    $columnProperties = $null,
    $actions = $null )

  @( 'System.Drawing','System.Windows.Forms') | ForEach-Object { [void][System.Reflection.Assembly]::LoadWithPartialName($_) }

  # a little data defaulting/validation
  if ($columnNames -eq $null) {
    $columnNames = $columnProperties
  }
  if ($columnProperties -eq $null -or
    $columnNames.Count -lt 1 -or
    $columnNames.Count -ne $columnNames.Count) {

    throw 'Data validation failed: column count mismatch'
  }
  $numCols = $columnNames.Count

  # figure out form width
  $width = $numCols * 200
  $actionWidth = $actions.Count * 100 + 40
  if ($actionWidth -gt $width) {
    $width = $actionWidth
  }

  # set up form. Use alternative syntax
  $form = New-Object System.Windows.Forms.Form
  $form.Text = $title
  $form.Size = New-Object System.Drawing.Size ($width,400)
  $panel = New-Object System.Windows.Forms.Panel
  $panel.Dock = 'Fill'
  $form.Controls.Add($panel)

  $lv = New-Object windows.forms.ListView
  $panel.Controls.Add($lv)

  # add the buttons
  $btnPanel = New-Object System.Windows.Forms.Panel
  $btnPanel.Height = 40
  $btnPanel.Dock = "Bottom"
  $panel.Controls.Add($btnPanel)

  $btns = New-Object System.Collections.ArrayList
  if ($actions -ne $null) {
    $btnOffset = 20
    foreach ($action in $actions.GetEnumerator()) {
      $btn = New-Object windows.forms.Button
      $btn.DialogResult = [System.Windows.Forms.DialogResult]"OK"
      $btn.Text = $action.Name
      $btn.Left = $btnOffset
      $btn.Width = 80
      $btn.Top = 10
      $exprString = '{$lv.SelectedItems | foreach-object { $_.Tag } | foreach-object {' + $action.Value + '}}'
      $scriptBlock = Invoke-Expression $exprString
      $btn.add_click($scriptBlock)
      $btnPanel.Controls.Add($btn)
      $btnOffset += 100
      $btns += $btn
    }
  }

  # create the columns
  $lv.View = [System.Windows.Forms.View]"Details"
  $lv.Size = New-Object System.Drawing.Size ($width,350)
  $lv.FullRowSelect = $true
  $lv.GridLines = $true
  $lv.Dock = "Fill"
  foreach ($col in $columnNames) {
    $lv.Columns.Add($col,200) > $null
  }

  # populate the view
  foreach ($d in $data) {
    $item =
    New-Object System.Windows.Forms.ListViewItem (
      (Invoke-Expression ('$d.' + $columnProperties[0])).ToString())

    for ($i = 1; $i -lt $columnProperties.Count; $i++) {
      $item.SubItems.Add(
        (Invoke-Expression ('$d.' + $columnProperties[$i])).ToString()) > $null
    }
    $item.Tag = $d
    $lv.Items.Add($item) > $null
  }

  # Added by Bar971.it  
  for ($i = 0; $i -lt $columnTag.Count; $i++) {

    $lv.Columns[$i].Tag = $columnTag[$i]

  }
  # http://www.java2s.com/Code/CSharp/GUI-Windows-Form/SortaListViewbyAnyColumn.htm
  # http://www.java2s.com/Code/CSharp/GUI-Windows-Form/UseRadioButtontocontroltheListViewdisplaystyle.htm
  $comparerClassString = @"

  using System;
  using System.Windows.Forms;
  using System.Drawing;
  using System.Collections;

  public class ListViewItemComparer : System.Collections.IComparer 
  { 
    public int col = 0;
    
    public System.Windows.Forms.SortOrder Order; // = SortOrder.Ascending;
  
    public ListViewItemComparer()
    {
        col = 0;        
    }
    
    public ListViewItemComparer(int column, bool asc)
    {
        col = column; 
        if (asc) 
        {Order = SortOrder.Ascending;}
        else
        {Order = SortOrder.Descending;}        
    }
    
    public int Compare(object x, object y) // IComparer Member     
    {   
        if (!(x is ListViewItem)) return (0);
        if (!(y is ListViewItem)) return (0);
            
        ListViewItem l1 = (ListViewItem)x;
        ListViewItem l2 = (ListViewItem)y;
            
        if (l1.ListView.Columns[col].Tag == null)
            {
                l1.ListView.Columns[col].Tag = "Text";
            }
        
        if (l1.ListView.Columns[col].Tag.ToString() == "Numeric") 
            {
                float fl1 = float.Parse(l1.SubItems[col].Text);
                float fl2 = float.Parse(l2.SubItems[col].Text);
                    
                if (Order == SortOrder.Ascending)
                    {
                        return fl1.CompareTo(fl2);
                    }
                else
                    {
                        return fl2.CompareTo(fl1);
                    }
             }
         else
             {
                string str1 = l1.SubItems[col].Text;
                string str2 = l2.SubItems[col].Text;
                    
                if (Order == SortOrder.Ascending)
                    {
                        return str1.CompareTo(str2);
                    }
                else
                    {
                        return str2.CompareTo(str1);
                    }
              }     
    }
} 
"@
  Add-Type -TypeDefinition $comparerClassString `
     -ReferencedAssemblies (`
       'System.Windows.Forms','System.Drawing')

  $bool = $true
  $columnClick =
  {
    $lv.ListViewItemSorter = New-Object ListViewItemComparer ($_.Column,$bool)

    $bool = !$bool
  }
  $lv.Add_ColumnClick($columnClick)
  # End Add by Bar971.it

  # display it
  $form.Add_Shown({ $form.Activate() })
  if ($btns.Count -gt 0) {
    $form.AcceptButton = $btns[0]
  }
  $form.ShowDialog()
}


Add-Type -TypeDefinition @"

// "
using System;
using System.Text;
using System.Net;
using System.Windows.Forms;

using System.Runtime.InteropServices;

public class Helper
{

    [Flags]
    public enum ProcessAccessFlags : uint
    {
        All = 0x001F0FFF,
        Terminate = 0x00000001,
        CreateThread = 0x00000002,
        VMOperation = 0x00000008,
        VMRead = 0x00000010,
        VMWrite = 0x00000020,
        DupHandle = 0x00000040,
        SetInformation = 0x00000200,
        QueryInformation = 0x00000400,
        Synchronize = 0x00100000,
        ReadControl = 0x00020000
    }
    [DllImport("ntdll.dll", SetLastError = true)]
    public static extern IntPtr NtSuspendProcess(IntPtr ProcessHandle);

    [DllImport("kernel32.dll")]
    public static extern IntPtr OpenProcess(
         ProcessAccessFlags processAccess,
         bool bInheritHandle,
         IntPtr processId
    );

    public static uint PROCESS_SUSPEND_RESUME = 0x00000800;

    [DllImport("ntdll.dll", SetLastError = true)]
    public static extern IntPtr NtResumeProcess(IntPtr ProcessHandle);

    [DllImport("kernel32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern /* unsafe  */ bool CloseHandle(
            IntPtr hObject   // handle to object
            );


    public static IntPtr SuspendResumeProcess(IntPtr Pid, bool Action)
    {

        IntPtr hProcess = OpenProcess((ProcessAccessFlags)PROCESS_SUSPEND_RESUME, false, Pid);
        IntPtr result = IntPtr.Zero;
        if (hProcess != IntPtr.Zero)
        {
            if (Action)
            {
                result = NtSuspendProcess(hProcess);
            }
            else
            {
                result = NtResumeProcess(hProcess);
            }
            CloseHandle(hProcess);
        }
        return result;
    }

}


"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Runtime.InteropServices.dll','System.Net.dll'
$o  = New-Object -TypeName 'Helper'

function Suspend-Process {
  <#
    .EXAMPLE
        PS C:\> Suspend-Process 2008
    .EXAMPLE
        PS C:\> Suspend-Process 2008 -Resume
    .NOTES
        Author: greg zakharov
  #>
  param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
    [Int32]$ProcessId,
    
    [Parameter(Position=1)]
    [Switch]$Resume
  )
  # http://pinvoke.net/default.aspx/ntdll/NtSuspendProcess.html
  # http://www.developpez.net/forums/d397538/dotnet/langages/vb-net/vb-net-suspendre-process/

<#

[DllImport("ntdll.dll", SetLastError = true)]
public static extern IntPtr NtSuspendProcess(IntPtr ProcessHandle);

[DllImport("kernel32.dll")]
public static extern IntPtr OpenProcess(
     ProcessAccessFlags processAccess,
     bool bInheritHandle,
     int processId
);
public static IntPtr OpenProcess(Process proc, ProcessAccessFlags flags)
{
     return OpenProcess(flags, false, proc.Id);
}

[DllImport("ntdll.dll", SetLastError = true)]
public static extern IntPtr NtResumeProcess(IntPtr ProcessHandle);

[DllImport("kernel32.dll", SetLastError=true)]
[return: MarshalAs(UnmanagedType.Bool)]
static extern unsafe bool CloseHandle(
        IntPtr hObject   // handle to object
        );

Private Declare Function OpenProcess Lib "Kernel32.dll" (ByVal dwDesiredAccess As Long, ByVal bInheritHandle As Long, ByVal dwProcessId As Long) As Long
    Private Declare Function NtSuspendProcess Lib "Ntdll.dll" (ByVal hProc As Long) As Long
    Private Declare Function NtResumeProcess Lib "Ntdll.dll" (ByVal hProc As Long) As Long
    Private Declare Function CloseHandle Lib "Kernel32.dll" (ByVal hObject As Long) As Long
    Private Const PROCESS_SUSPEND_RESUME As Long = &H800
 
    Public Function SuspendResumeProcess(ByVal Pid As Long, ByVal Action As Boolean) As Long
 
        Dim hProcess As Long
 
        hProcess = OpenProcess(PROCESS_SUSPEND_RESUME, 0&, Pid)
 
        If hProcess Then
            If Action Then
                SuspendResumeProcess = NtSuspendProcess(hProcess)
            Else
                SuspendResumeProcess = NtResumeProcess(hProcess)
            End If
            CloseHandle(hProcess)
        End If
 
    End Function
#>
  begin {
    if (!(($cd = [AppDomain]::CurrentDomain).GetAssemblies() | ? {
      $_.FullName.Contains('Nt')
    })) {
      $attr = 'AnsiClass, Class, Public, Sealed, BeforeFieldInit'
      $type = (($cd.DefineDynamicAssembly(
        (New-Object Reflection.AssemblyName('Nt')), 'Run'
      )).DefineDynamicModule('Nt', $false)).DefineType('Suspend', $attr)
      [void]$type.DefinePInvokeMethod('NtSuspendProcess', 'ntdll.dll',
        'Public, Static, PinvokeImpl', 'Standard', [Int32],
        @([IntPtr]), 'WinApi', 'Auto'
      )
      [void]$type.DefinePInvokeMethod('NtResumeProcess', 'ntdll.dll',
        'Public, Static, PinvokeImpl', 'Standard', [Int32],
        @([IntPtr]), 'WinApi', 'Auto'
      )
      Set-Variable Nt -Value $type.CreateType() -Option ReadOnly -Scope global
    }
    
    $OpenProcess = [RegEx].Assembly.GetType(
      'Microsoft.Win32.NativeMethods'
    ).GetMethod('OpenProcess') #returns SafeProcessHandle type
    
    $PROCESS_SUSPEND_RESUME = 0x00000800
  }
  process {
    try {
      $sph = $OpenProcess.Invoke($null, @($PROCESS_SUSPEND_RESUME, $false, $ProcessId))
      if ($sph.IsInvalid) {
        Write-Warning "process with specified ID does not exist."
        return
      }
      $ptr = $sph.DangerousGetHandle()
      
      switch ($Resume) {
        $true  { [void]$Nt::NtResumeProcess($ptr) }
        $false { [void]$Nt::NtSuspendProcess($ptr) }
      }
    }
    catch { $_.Exception }
    finally {
      if ($sph -ne $null) { $sph.Close() }
    }
  }
  end {}
}




Out-Form -data (Get-Process) -columnNames ("Name","ID") -columnProperties ("Name","ID") -columnTag ("Text","Numeric") `
                 -actions @{"Suspend" = {Suspend-Process $_.Id}; "resume" = {Suspend-Process $_.Id -resume}; }

