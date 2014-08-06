# https://sites.google.com/site/assafmiron/MiscScripts/exchangebackupsummery2

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
#requires -version 2
Add-Type -AssemblyName PresentationFramework

# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
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
        'ScriptDirectory'  = [string] '';
	'Window'  = [System.Windows.Window] $null ;
	'Control' = [System.Windows.Controls.ToolTip] $null ;
	'Contents' = [System.Windows.Controls.TextBox] $null ;
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

 # uncomment the below at final stage
 $run_script = [PowerShell]::Create().AddScript({    

# Load Assemblies
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

# Create new Objects
$objForm = New-Object System.Windows.Forms.Form
$objNotifyIcon = New-Object System.Windows.Forms.NotifyIcon
$objContextMenu = New-Object System.Windows.Forms.ContextMenu
$ExitMenuItem = New-Object System.Windows.Forms.MenuItem
$AddContentMenuItem = New-Object System.Windows.Forms.MenuItem

$ConfigFile = "NotifyApp.config"

function Read-Config
{
$objContextMenu.MenuItems.Clear()
If(Test-Path $ConfigFile)
{
$ConfigData = Get-Content $ConfigFile
$i = 0
Foreach($line in $ConfigData)
{
If($line.Length -gt 0)
{
$line = $line.Split(",")
$Name = $line[0]
$FilePath = $line[1]
# Add object from the Config file to the Context Menu with the Build-ContextMenu Function
$objContextMenu | Build-ContextMenu -index $i -text $Name -Action $FilePath
$i++
}
}
}
else
{
Add-ConfigContent
}

# Create the Add Config content Menu Item
$AddContentMenuItem.index = $i+1
$AddContentMenuItem.Text = "Add Shurtcuts"
$AddContentMenuItem.add_Click( {Add-ConfigContent} )

# Create an Exit Menu Item
$ExitMenuItem.Index = $i+2
$ExitMenuItem.Text = "E&xit"
$ExitMenuItem.add_Click({
$objForm.Close()
$objNotifyIcon.visible = $false
})

# Add the Exit and Add Content Menu Items to the Context Menu
$objContextMenu.MenuItems.Add($AddContentMenuItem) | Out-Null
$objContextMenu.MenuItems.Add($ExitMenuItem) | Out-Null
}

function new-scriptblock([string]$textofscriptblock)
# Function that converts string to ScriptBlock
{
$executioncontext.InvokeCommand.NewScriptBlock($textofscriptblock)
}

Function Build-ContextMenu
# Function That Creates a ContexMenuItem and adds it to the Contex Menu
{
param ( $index = 0,
$Text,
$Action
)
begin
{
$MyMenuItem = New-Object System.Windows.Forms.MenuItem
}
process
{
# Assign the Contex Menu Object from the pipeline to the ContexMenu var
$ContextMenu = $_
}
end
{
# Create the Menu Item
$MyMenuItem.Index = $index
$MyMenuItem.Text = $Text
$scriptAction = $(new-scriptblock "Invoke-Item $Action")
$MyMenuItem.add_Click($scriptAction)
$ContextMenu.MenuItems.Add($MyMenuItem) | Out-Null
}
}
# http://bytecookie.wordpress.com/2011/12/28/gui-creation-with-powershell-part-2-the-notify-icon-or-how-to-make-your-own-hdd-health-monitor/

Function Add-ConfigContent
{
$objOpen = New-Object System.Windows.Forms.OpenFileDialog
$objOpen.Title = "Choose files to add"
$objOpen.Multiselect = $true
$objOpen.RestoreDirectory = $true
$objOpen.ShowDialog()
$addFiles = $objOpen.FileNames
foreach($File in $addFiles)
{
$FileName = (Split-Path $file -Leaf).Split(".")[0]
"$FileName,"+[char]34+$File+[char]34 | out-File -FilePath $ConfigFile -Append
}
Read-Config
}

Read-Config

# Assign an Icon to the Notify Icon object
$objNotifyIcon.Icon = ('{0}\{1}' -f $so.ScriptDirectory, 'sample.ico' )
$objNotifyIcon.Text = "Context Menu Test"
# Assign the Context Menu
$objNotifyIcon.ContextMenu = $objContextMenu
$objForm.ContextMenu = $objContextMenu

# Control Visibilaty and state of things
$objNotifyIcon.Visible = $true
$objForm.Visible = $false
$objForm.WindowState = "minimized"
$objForm.ShowInTaskbar = $false
$objForm.add_Closing({ $objForm.ShowInTaskBar = $False })
# Show the Form - Keep it open
# This Line must be Last
$objForm.ShowDialog()
 # uncomment the below at final stage

})

$run_script.Runspace = $rs
 Clear-Host

$handle = $run_script.BeginInvoke()
write-output 'started...'
While (-Not $handle.IsCompleted) {
write-output 'continue...'
    Start-Sleep -Milliseconds 100
}
$run_script.EndInvoke($handle)

$rs.Close()



