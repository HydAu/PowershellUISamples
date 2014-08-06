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

function Get-ScriptDirectory
{
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value;
    if($Invocation.PSScriptRoot)
    {
        $Invocation.PSScriptRoot;
    }
    Elseif($Invocation.MyCommand.Path)
    {
        Split-Path $Invocation.MyCommand.Path
    }
    else
    {
        $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf("\"));
    }
}

$so = [hashtable]::Synchronized(@{ 
        'Result'  = [string] '';
        'ConfigFile'  = [string] '';
        'ScriptDirectory'  = [string] '';
	'Form'  = [System.Windows.Forms.Form] $null ;
	'NotifyIcon' = [System.Windows.Controls.ToolTip] $null ;

        # http://msdn.microsoft.com/en-us/library/system.windows.forms.contextmenu(v=vs.110).aspx
# OnPopup System.EventArgs
# OnCollapse System.EventArgs
# Show System.Windows.Forms.Control System.Drawing.Point
# MergeMenu System.Windows.Forms.MenuItem
	'ContextMenu' = [System.Windows.Forms.ContextMenu] $null ;
	'NeedData' = [bool] $false ;
	'HaveData' = [bool] $false ;

	})
$so.ScriptDirectory = Get-ScriptDirectory
$so.Result = ''
$rs =[runspacefactory]::CreateRunspace()
$rs.ApartmentState = 'STA'
$rs.ThreadOptions = 'ReuseThread'
$rs.Open()
$rs.SessionStateProxy.SetVariable('so', $so)          

$run_script = [PowerShell]::Create().AddScript({    

[void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')

$f = New-Object System.Windows.Forms.Form
$so.Form  = $f
$notify_icon = New-Object System.Windows.Forms.NotifyIcon
$so.NotifyIcon = $notify_icon
$context_menu = New-Object System.Windows.Forms.ContextMenu
$exit_menu_item = New-Object System.Windows.Forms.MenuItem
$AddContentMenuItem = New-Object System.Windows.Forms.MenuItem

$build_log = ('{0}\{1}' -f $so.ScriptDirectory, 'build.log' )

function Read-Config {
  $context_menu.MenuItems.Clear()
  if(Test-Path $build_log){
    $ConfigData = Get-Content $build_log
    $i = 0
    foreach($line in $ConfigData){
      if($line.Length -gt 0){
        $line = $line.Split(",")
        $Name = $line[0]
        $FilePath = $line[1]
        # Powershell style function invocation syntax 
        $context_menu | Build-ContextMenu -index $i -text $Name -Action $FilePath
        $i++
      }
    }
  }


# Create an Exit Menu Item
$exit_menu_item.Index = $i+1
$exit_menu_item.Text = 'E&xit'
$exit_menu_item.add_Click({
$f.Close()
$notify_icon.visible = $false
})

# Add the Exit Menu Item to the Context Menu
$context_menu.MenuItems.Add($exit_menu_item) | Out-Null
}

function new-scriptblock([string]$textofscriptblock)
# Function that converts string to ScriptBlock
{
$executioncontext.InvokeCommand.NewScriptBlock($textofscriptblock)
}

# construct objects from the build log file and fill the context Menu
function Build-ContextMenu {
  param ( 
        [int]$index = 0,
        [string]$Text,
        [string] $Action
  )
begin
{
$menu_item = New-Object System.Windows.Forms.MenuItem
}
process
{
# Assign the Contex Menu Object from the pipeline to the ContexMenu var
$ContextMenu = $_
}
end
{
# Create the Menu Item$menu_item.Index = $index
$menu_item.Text = $Text
$scriptAction = $(new-scriptblock "Invoke-Item $Action")
$menu_item.add_Click($scriptAction)
$ContextMenu.MenuItems.Add($menu_item) | Out-Null
}
}
# http://bytecookie.wordpress.com/2011/12/28/gui-creation-with-powershell-part-2-the-notify-icon-or-how-to-make-your-own-hdd-health-monitor/

$notify_icon.Icon = ('{0}\{1}' -f $so.ScriptDirectory, 'sample.ico' )
# 
$notify_icon.Text = 'Context Menu Test'
# Assign the Context Menu
$notify_icon.ContextMenu = $context_menu
$f.ContextMenu = $context_menu

# Control Visibilaty and state of things
$notify_icon.Visible = $true
$f.Visible = $false
$f.WindowState = 'minimized'
$f.ShowInTaskbar = $false
$f.add_Closing({ $f.ShowInTaskBar = $False })
$context_menu.Add_Popup({Read-Config})
$f.ShowDialog()
})

function send_text { 
    Param (
        [String] $title = 'script',
        [String] $message,
        [int]    $timeout = 10 ,
        [switch] $append
    )

    $so.NotifyIcon.ShowBalloonTip($timeout, $title , $message, [System.Windows.Forms.ToolTipIcon]::Info)
    write-output  -InputObject  ( '{0}:{1}' -f $title,  $message)
}



# -- main program -- 
clear-host
$run_script.Runspace = $rs

$cnt = 0
$total = 4
$handle = $run_script.BeginInvoke()

start-sleep 1

send_text -title 'script' -message 'Starting...' -timeout 10 
$so.ConfigFile = $build_log = ('{0}\{1}' -f $so.ScriptDirectory, 'build.log' )
set-Content -path $build_log -value ''

While (-Not $handle.IsCompleted -and $cnt -lt $total) {
  start-sleep -Milliseconds 10000
  $cnt ++
  send_text -title 'script' -message ("Finished {0} of {1} items..."  -f $cnt, $total  )  -timeout 10 
  write-output ("Subtask {0} ..." -f $cnt ) | out-file -FilePath $build_log -Append -encoding ascii
}

# TODO - collapse, close,  displose 
$so.Form.Close()

$run_script.EndInvoke($handle) | out-null 


$rs.Close()
write-output 'All finished' 

