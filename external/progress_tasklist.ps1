#Copyright (c) 2014 Serguei Kouzmine
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.



$shared_assemblies = @{
  'ProgressTaskList.dll' = $null;
  'nunit.core.dll' = $null;
  'nunit.framework.dll' = $null;

}


$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}

pushd $shared_assemblies_path


$shared_assemblies.Keys | ForEach-Object {
  # http://all-things-pure.blogspot.com/2009/09/assembly-version-file-version-product.html
  $assembly = $_
  $assembly_path = [System.IO.Path]::Combine($shared_assemblies_path,$assembly)
  Write-Debug $assembly_path
  $assembly_version = [Reflection.AssemblyName]::GetAssemblyName($assembly_path).Version
  $assembly_version_string = ('{0}.{1}' -f $assembly_version.Major,$assembly_version.Minor)
  if ($shared_assemblies[$assembly] -ne $null) {
    # http://stackoverflow.com/questions/26999510/selenium-webdriver-2-44-firefox-33
    if (-not ($shared_assemblies[$assembly] -match $assembly_version_string)) {
      Write-Output ('Need {0} {1}, got {2}' -f $assembly,$shared_assemblies[$assembly],$assembly_path)
      Write-Output $assembly_version
      throw ('invalid version :{0}' -f $assembly)
    }
  }

  if ($host.Version.Major -gt 2) {
    Unblock-File -Path $_
  }
  Write-Debug $_
  Add-Type -Path $_
}
popd

Add-Type -TypeDefinition @"
using System;
using System.Windows.Forms;
public class Win32Window : IWin32Window
{
    private IntPtr _hWnd;
    private int _data;
    private string _script_directory;

    public int Data
    {
        get { return _data; }
        set { _data = value; }
    }
    public string ScriptDirectory
    {
        get { return _script_directory; }
        set { _script_directory = value; }
    }

    public Win32Window(IntPtr handle)
    {
        _hWnd = handle;
    }

    public IntPtr Handle
    {
        get { return _hWnd; }
    }
}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll'


function Progressbar {
  param(
    [string]$title,
    [string]$message,
    [object]$caller
  )

  @( 'System.Drawing','System.Windows.Forms') | ForEach-Object { [void][System.Reflection.Assembly]::LoadWithPartialName($_) }

  $f = New-Object -TypeName 'System.Windows.Forms.Form'
  $f.Text = $title

  $f.Size = New-Object System.Drawing.Size (650,120)
  $f.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
  $f.AutoScaleBaseSize = New-Object System.Drawing.Size (5,14)
  $f.ClientSize = New-Object System.Drawing.Size (292,104)


  $panel = New-Object System.Windows.Forms.Panel
  $panel.BackColor = [System.Drawing.Color]::Silver
  $panel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle

  $b = New-Object System.Windows.Forms.Button
  $b.Location = New-Object System.Drawing.Point (140,72)
  $b.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font
  $b.Font = New-Object System.Drawing.Font ('Microsoft Sans Serif',7,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,0)
  $b.Text = 'forward'
  $b.add_click({ $u.PerformStep()
      if ($u.Maximum -eq $u.Value)
      {
        $b.Enabled = false
      }

    })

  $o = New-Object -TypeName 'Ibenza.UI.Winforms.ProgressTaskList' -ArgumentList @()
  $o.BackColor = [System.Drawing.Color]::Transparent
  $o.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
  $o.Dock = [System.Windows.Forms.DockStyle]::Fill
  $o.Location = New-Object System.Drawing.Point (0,0)
  $o.Name = "progressTaskList1"
  $o.Size = New-Object System.Drawing.Size (288,159)
  $o.TabIndex = 2
  $o.TaskItems.AddRange(@(
      "Verifying cabinet integrity",
      "Checking necessary disk space",
      "Extracting files",
      "Modifying registry",
      "Installing files",
      "Removing temporary files"))
  $o.Visible = $false
  $panel.SuspendLayout()
  $panel.ForeColor = [System.Drawing.Color]::Black
  $panel.Location = New-Object System.Drawing.Point (0,0)
  $panel.Name = 'panel'
  $panel.Size = New-Object System.Drawing.Size (($f.Size.Width),($f.Size.Height))
  $panel.TabIndex = 1

  $panel.Controls.Add($o)
  $panel.ResumeLayout($false)
  $panel.PerformLayout()


  $f.Controls.AddRange(@( $b,$panel))
  $f.Topmost = $True

  $so.Visible = $caller.Visible = $true
  $f.Add_Shown({ $f.Activate() })

  [void]$f.ShowDialog([win32window]($caller))

  $f.Dispose()
}

$title = 'test'
$caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)
[void](ProgressbarTasklist -Title $title -caller $caller)




