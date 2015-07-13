#Copyright (c) 2015 Serguei Kouzmine
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

# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory
{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  if ($Invocation.PSScriptRoot) {
    $Invocation.PSScriptRoot
  }
  elseif ($Invocation.MyCommand.Path) {
    Split-Path $Invocation.MyCommand.Path
  } else {
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf(""))
  }
}
$shared_assemblies = @(
  'nunit.framework.dll'
)

$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}

pushd $shared_assemblies_path

$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd


$extra_assemblies = @(
  'FastColoredTextBox.dll'
)



$extra_assemblies_path = 'C:\developer\sergueik\swd-recorder\SwdPageRecorder\vendor\FastColoredTextBox-PavelTorgashov'

if (($env:EXTRA_ASSEMBLIES_PATH -ne $null) -and ($env:EXTRA_ASSEMBLIES_PATH -ne '')) {
  $extra_assemblies_path = $env:extra_ASSEMBLIES_PATH
}

pushd $extra_assemblies_path


$extra_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd


Add-Type -TypeDefinition @"
using System;
using System.Windows.Forms;
public class Win32Window : IWin32Window
{
    private IntPtr _hWnd;
    private int _numeric;
    private string _timestr;

    public int Numeric
    {
        get { return _numeric; }
        set { _numeric = value; }
    }

    public string TimeStr
    {
        get { return _timestr; }
        set { _timestr = value; }
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


#  http://www.codeproject.com/Articles/161871/Fast-Colored-TextBox-for-syntax-highlighting
function PromptFastColoredTextBox {
  param(
    [object]$caller
  )
  $f = New-Object System.Windows.Forms.Form
  $f.MaximizeBox = $false
  $f.MinimizeBox = $false

  ('System.Drawing','System.ComponentModel','System.Text','System.Data','System.Windows.Forms') | ForEach-Object { [void][System.Reflection.Assembly]::LoadWithPartialName($_) }

  $panel = New-Object System.Windows.Forms.Panel
  $button = New-Object System.Windows.Forms.Button



  $o = New-Object FastColoredTextBoxNS.FastColoredTextBox
  $o.Text = @"
// WebDriver Playground enables you to operate the WebElements at runtime. 
// Go to any page and define any web element into PageObject tree on the right side. 
// For instance, you have declared a text field with name �txtLogin�. 
// Now you can write the following JavaScript to manipulate the web element: 
// 
//      txtLogin.Clear()
//      txtLogin.SendKeys(""Hello World"")
// 
// WebDriver Playground is in ALPHA quality. The following classes supported: 
// PageObject web elements, (IWebElement), driver (IWebDriver), By, Keys, Actions.

driver.Navigate().GoToUrl(""https://github.com/dzharii/swd-recorder"");
driver.GetScreenshot().SaveAsFile(""Screenshots\\mywebpagetest.png"", ImageFormat.Png); // See <SwdRecorder.exe-folder>\Screenshots

"@
  $o.AllowMacroRecording = $false
  $o.Language = [FastColoredTextBoxNS.Language]::JS
  $o.AutoScrollMinSize = New-Object System.Drawing.Size (120,120)
  $o.BackBrush = $null
  $o.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
  $o.CharHeight = 12
  $o.CharWidth = 8
  $o.Cursor = [System.Windows.Forms.Cursors]::IBeam
  $o.DisabledColor = [System.Drawing.Color]::FromArgb([byte](100),[byte](180),[byte](180),[byte](180))
  $o.Dock = [System.Windows.Forms.DockStyle]::Fill
  $o.Font = New-Object System.Drawing.Font ("Lucida Console",9.75)
  $o.IsReplaceMode = $false
  $o.Location = New-Object System.Drawing.Point (3,16)
  $o.Name = "txtJavaScriptCode"
  $o.Paddings = New-Object System.Windows.Forms.Padding (0)
  $o.SelectionColor = [System.Drawing.Color]::FromArgb([byte](60),[byte](0),[byte](0),[byte](255))
  $o.Size = New-Object System.Drawing.Size (697,180)
  $o.TabIndex = 5
  $o.WordWrapAutoIndent = $false
  $o.Zoom = 100

  $panel.SuspendLayout()
  $f.SuspendLayout()

  $panel.Controls.Add($o)
  $panel.ForeColor = [System.Drawing.Color]::Black
  $panel.Location = New-Object System.Drawing.Point (0,0)
  $panel.Name = 'panel'
  $panel.Size = New-Object System.Drawing.Size (700,270)
  $panel.TabIndex = 3

  $f.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::None
  $f.BackColor = [System.Drawing.Color]::White
  $f.Controls.Add($panel)
  $f.Name = 'FastColoredTextBox'
  $f.Size = New-Object System.Drawing.Size (706,286)
  $panel.ResumeLayout($false)
  $panel.PerformLayout()
  $f.ResumeLayout($false)
  [void]$f.ShowDialog([win32window ]($caller))
  $f.Dispose()
}



$DebugPreference = 'Continue'
$title = 'Enter credentials'
$user = 'admin'
$caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)
PromptFastColoredTextBox -caller $caller



