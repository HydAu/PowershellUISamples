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

  $shared_assemblies = @(
    'NotificationWindow.dll',
    'nunit.framework.dll'
  )

  Add-Type -AssemblyName PresentationFramework

  function Get-ScriptDirectory
  {
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value;
    if ($Invocation.PSScriptRoot)
    {
      $Invocation.PSScriptRoot;
    }
    elseif ($Invocation.MyCommand.Path)
    {
      Split-Path $Invocation.MyCommand.Path
    }
    else
    {
      $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf("\"));
    }
  }


  $env:SHARED_ASSEMBLIES_PATH = "c:\developer\sergueik\csharp\SharedAssemblies"
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
  pushd $shared_assemblies_path
  $shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_; Write-Debug ("Loaded {0} " -f $_) }
  popd


function try_pop_up (
  [string]$title,
  [string]$message,
  [object]$caller
) {



  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')


  $helper = New-Object -TypeName 'NotificationWindow.PopupNotifier'



  $helper.AnimationDuration = 150
  $helper.AnimationInterval = 1
  $helper.BodyColor = [System.Drawing.SystemColors]::GradientActiveCaption
  $helper.BorderColor = [System.Drawing.Color]::Aqua
  $helper.ButtonBorderColor = [System.Drawing.Color]::FromArgb([int]([byte]192),[int]([byte]255),[int]([byte]255))
  $helper.ContentFont = New-Object System.Drawing.Font ("Tahoma",8)
  $helper.ContentPadding = New-Object System.Windows.Forms.Padding (0,17,0,0)
  $helper.ContentText = $null
  $helper.GradientPower = 300
  $helper.HeaderColor = [System.Drawing.Color]::SteelBlue
  $helper.HeaderFont = New-Object System.Drawing.Font ("Bookman Old Style",`
       9.75,`
       [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold -bor [System.Drawing.FontStyle]::Italic),`
       [System.Drawing.GraphicsUnit]::Point,[byte]0)
  $helper.HeaderHeight = 20
  $helper.HeaderPadding = New-Object System.Windows.Forms.Padding (0)
  $helper.HeaderText = "Header Text"
  #  $helper.Image = global::try_pop_up.Properties.Resources]::DispatcherIcon
  $helper.ImagePadding = New-Object System.Windows.Forms.Padding (10,13,0,0)
  $helper.ImageSize = New-Object System.Drawing.Size (30,30)
  $helper.OptionsMenu = $null
  # $helper.Scroll = $false
  # $helper.ShowCloseButton = $false
  $helper.Size = New-Object System.Drawing.Size (220,75)
  $helper.TitleColor = [System.Drawing.Color]::Black;
  $helper.TitleFont = New-Object System.Drawing.Font ("Segoe UI",`
       9.75,`
       [System.Drawing.FontStyle]::Bold,`
       [System.Drawing.GraphicsUnit]::Point,`
       [byte]0)
  $helper.TitlePadding = New-Object System.Windows.Forms.Padding (0,2,0,0)
  $helper.TitleText = "Hello"


  $helper.TitleText = "Hello"
  $helper.ContentText = "content text"
  $helper.ShowCloseButton = $true
  $helper.ShowOptionsButton = $false
  $helper.ShowGripText = $true
  $helper.Delay = 5000
  $helper.AnimationInterval = 1
  $helper.AnimationDuration = 400
  $helper.Scroll = $true
  $helper.ShowCloseButton = $true



  $f = New-Object System.Windows.Forms.Form
  $f.Text = $title


  $f.Size = New-Object System.Drawing.Size (150,120)
  $f.StartPosition = 'CenterScreen'

  $f.KeyPreview = $True
  $f.Add_KeyDown({

      if ($_.KeyCode -ne 'Escape') { return }
      $f.Close()

    })

  $b = New-Object System.Windows.Forms.Button
  $b.Location = New-Object System.Drawing.Size (30,40)
  $b.Size = New-Object System.Drawing.Size (50,23)
  $b.Text = 'Show'
  $f.Controls.Add($b)

  $b.add_Click({

      $helper.popup("Message Type 0","Message Detail Message Detail Message Detail 0",10,10,10,10,[System.Drawing.Image]([System.Drawing.SystemIcons]::Error).ToBitmap())

    })

  $l = New-Object System.Windows.Forms.Label
  $l.Location = New-Object System.Drawing.Size (10,20)
  $l.Size = New-Object System.Drawing.Size (80,20)
  $f.Controls.Add($l)
  $f.Topmost = $True


  $f.Add_Shown({ $f.Activate() })

  [void]$f.ShowDialog([win32window ]($caller))

  $f.Dispose()
}

Add-Type -TypeDefinition @" 

// "
using System;
using System.Windows.Forms;
public class Win32Window : IWin32Window
{
    private IntPtr _hWnd;


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

$DebugPreference = 'Continue'
$title = 'Floating Notification'
$message = "Floating Notification"
$caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)

try_pop_up -Title $title -Message $message -caller $caller
