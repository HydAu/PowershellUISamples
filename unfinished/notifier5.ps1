#Copyright (c) 2014 Serguei Kouzmine
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.

# https://sites.google.com/site/assafmiron/MiscScripts/exchangebackupsummery2
# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
#requires -version 2
Add-Type -AssemblyName PresentationFramework
$shared_assemblies = @(
  'NotificationWindow_2.dll',
  'nunit.framework.dll'
)

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

$so = [hashtable]::Synchronized(@{
    'Result' = [string]'';
    'ScriptDirectory' = [string]'';
    'Form' = [System.Windows.Forms.Form]$null;
    'Notifier' = [NotificationWindow.PopupNotifier]$null;
  })
$so.ScriptDirectory = Get-ScriptDirectory
$so.Result = ''
$rs = [runspacefactory]::CreateRunspace()
$rs.ApartmentState = 'STA'
$rs.ThreadOptions = 'ReuseThread'
$rs.Open()
$rs.SessionStateProxy.SetVariable('so',$so)

$run_script = [powershell]::Create().AddScript({

    [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')

    $f = New-Object System.Windows.Forms.Form
    $so.Form = $f
    $context_menu = New-Object System.Windows.Forms.ContextMenu
    $exit_menu_item = New-Object System.Windows.Forms.MenuItem
    $AddContentMenuItem = New-Object System.Windows.Forms.MenuItem

    # http://bytecookie.wordpress.com/2011/12/28/gui-creation-with-powershell-part-2-the-notify-icon-or-how-to-make-your-own-hdd-health-monitor/

    $shared_assemblies = @(
      'NotificationWindow_2.dll',
      'nunit.framework.dll'
    )

    $env:SHARED_ASSEMBLIES_PATH = "c:\developer\sergueik\csharp\SharedAssemblies"
    $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
    pushd $shared_assemblies_path
    $shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_; Write-Debug ("Loaded {0} " -f $_) }
    popd

    $so.Notifier = $helper = New-Object -TypeName 'NotificationWindow.PopupNotifier'

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



    # BUG ? need two calls 
    $helper.Popup("Message Type 0","Message Detail Message Detail Message Detail 0",10,10,10,10,[System.Drawing.Image]([System.Drawing.SystemIcons]::Error).ToBitmap())
    Start-Sleep 10
    #    $helper.Popup()
    $helper.Popup("Message Type 0","Message Detail Message Detail Message Detail 0",10,10,10,10,[System.Drawing.Image]([System.Drawing.SystemIcons]::Error).ToBitmap())
    $f.visible = $false
    $f.WindowState = 'minimized'
    $f.ShowInTaskbar = $false
    $f.add_Closing({ $f.ShowInTaskbar = $False })


    $f.ShowDialog()
  })

function send_text {
  param(
    [string]$title = 'script',
    [string]$message,
    [int]$timeout = 10,
    [switch]$append
  )
  $so.Notifier.TitleText = ('Test Title: ' + ('{0}:{1}' -f $title,$message))
  #  $so.Notifier.Popup()
  $so.Notifier.Popup("Message Type 0",('{0}:{1}' -f $title,$message),10,10,10,10,$null)

}



# -- main program -- 
# Clear-Host
$run_script.Runspace = $rs

$cnt = 0
$total = 5
$handle = $run_script.BeginInvoke()

Start-Sleep 1

send_text -Title 'script' -Message 'Starting...' -Timeout 10

while (-not $handle.IsCompleted -and $cnt -lt $total) {
  Start-Sleep -Milliseconds 10000
  #  Start-Sleep -Milliseconds 20000
  $cnt++
  send_text -Title 'script' -Message ("Finished {0} of {1} items..." -f $cnt,$total) -Timeout 10
}

# TODO - collapse, close,  displose 
$so.Form.Close()

$run_script.EndInvoke($handle) | Out-Null


$rs.Close()
Write-Output 'All finished'



