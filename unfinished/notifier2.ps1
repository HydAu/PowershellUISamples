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
  'NotificationWindow_1.dll',
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
      'NotificationWindow_1.dll',
      'nunit.framework.dll'
    )

    $env:SHARED_ASSEMBLIES_PATH = "c:\developer\sergueik\csharp\SharedAssemblies"
    $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
    pushd $shared_assemblies_path
    $shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_; Write-Debug ("Loaded {0} " -f $_) }
    popd

    $so.Notifier = $helper = New-Object -TypeName 'NotificationWindow.PopupNotifier'

    Write-Host '!!!'
    Write-Host $helper.GetType()


    $helper.TitleText = 'Test Title Text'
    $helper.ContentText = 'Test of Contents'
    $helper.ShowCloseButton = $false
    $helper.ShowOptionsButton = $false
    $helper.ShowGrip = $false
    $helper.Delay = 500 # 2000
    $helper.AnimationInterval = 400
    $helper.AnimationDuration = 400
    #$helper.TitlePadding = new Padding(10)
    #$helper.ContentPadding = new Padding(int.Parse(txtPaddingContent.Text));
    #$helper.ImagePadding = new Padding(int.Parse(txtPaddingIcon.Text));
    $helper.Scroll = $false

    # BUG ? need two calls 
    $helper.Popup()
    Start-Sleep 10
    $helper.Popup()
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
  $so.Notifier.Popup()
  Write-Output -InputObject ('{0}:{1}' -f $title,$message)
}



# -- main program -- 
# Clear-Host
$run_script.Runspace = $rs

$cnt = 0
$total = 6
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



