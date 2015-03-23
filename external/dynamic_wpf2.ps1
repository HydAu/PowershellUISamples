#Copyright (c) 2015 Serguei Kouzmine
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


# http://poshcode.org/5730
# Plik: 4_Demo_v3_Reflection.ps1
#requires -version 3

# this script uses type accelerators to shorten the progam
# http://blogs.technet.com/b/heyscriptingguy/archive/2013/07/08/use-powershell-to-find-powershell-type-accelerators.aspx
# connect.microsoft.com/PowerShell/feedback/details/721443/system-management-automation-typeaccelerators-broken-in-v3-ctp2
$ta = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')

Add-Type -AssemblyName 'PresentationCore','PresentationFramework' -Passthru |
Where-Object IsPublic |
ForEach-Object {
  $_class = $_
  try {
    $ta::Add($_class.Name,$_class)
  } catch {
    ('Failed to add {0} accelerator resolving to {1}' -f $_class.Name,$_class.FullName)
  }
}

[window]@{
  Width = 310
  Height = 110
  WindowStyle = 'SingleBorderWindow'
  AllowsTransparency = $false
  TopMost = $true
  Content = & {
    $c1 = [stackpanel]@{
      Margin = '5'
      VerticalAlignment = 'Center'
      HorizontalAlignment = 'Center'
      Orientation = 'Horizontal'
    }



    $t = [textblock]@{}
    $t.AddChild([label]@{
        Margin = '5'
        VerticalAlignment = 'Center'
        HorizontalAlignment = 'Center'
        FontSize = '11'
        FontFamily = 'Calibri'
        Foreground = 'Black'
        Content = 'Enter Password:'
      }
    )

    $c1.AddChild($t)

    $c1.AddChild(
      [passwordbox]@{
        Name = 'passwordBox'
        PasswordChar = '*'
        VerticalAlignment = 'Center'
        Width = '120'
      }
    )

    $c1.AddChild(
      [button]@{
        Content = 'OK'
        IsDefault = 'True'
        Margin = '5'
        Name = 'button1'
        Width = '50'
        VerticalAlignment = 'Center'
      }
    )
    ,$c1
  }
} | ForEach-Object {
  $_.Add_MouseLeftButtonDown({
      $this.DragMove()
    })
  $_.Add_MouseRightButtonDown({
      $this.Close()
    })
  $_.ShowDialog() | Out-Null
}


<#


#requires -version 2

param(
  [switch]$debug
)

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


$verificationErrors = New-Object System.Text.StringBuilder
Add-Type -AssemblyName 'PresentationFramework'
Add-Type -AssemblyName 'PresentationCore'
#Add-Type -AssemblyName 'WindowsBase'


# requires -version 2
# origin: http://www.codeproject.com/Articles/68748/TreeTabControl-A-Tree-of-Tab-Items

[xml]$xaml =
@"
<?xml version="1.0"?>
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="Window1" Margin="5,5,5,5" Height="110" Width="310">
<ScrollViewer>
    <WrapPanel>
  <Grid x:Name="LayoutRoot">
  </Grid>
     </WrapPanel>
  </ScrollViewer>
</Window>
"@


Clear-Host


$shared_assemblies = @(
  'nunit.framework.dll'
)
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')

$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}
pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object {

  if ($host.Version.Major -gt 2) {
    Unblock-File -Path $_;
  }
  Write-Debug $_
  Add-Type -Path $_
}
popd

# TODO: http://www.java2s.com/Code/CSharp/Windows-Presentation-Foundation/GetsthecurrentlyselectedComboBoxItemwhentheuserclickstheButton.htm
# does not work 

# http://learn-powershell.net/2015/02/15/dealing-with-variables-in-a-winform-event-handler-an-alternative-to-script-scope/
# http://www.java2s.com/Code/CSharp/Windows-Presentation-Foundation/DisplayaPasswordEntryBoxandgettheinput.htm
# https://msdn.microsoft.com/en-us/library/system.windows.controls.passwordbox_events%28v=vs.110%29.aspx
[xml]$example = @"
<?xml version="1.0"?>
<StackPanel xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Orientation="Horizontal"  VerticalAlignment="Center" HorizontalAlignment = "Center">
  <TextBlock Margin="5" FontSize = "11" FontFamily = "Calibri">
            Enter Password:
        </TextBlock>
  <PasswordBox Name="passwordBox" PasswordChar="*" VerticalAlignment="Center" Width="120"/>
  <Button Content="OK" IsDefault="True" Margin="5" Name="button1"  Width="50" VerticalAlignment="Center"/>
</StackPanel>
"@
Clear-Host

$check_for_apartment = $true
if ($check_for_apartment -and [System.Management.Automation.Runspaces.Runspace]::DefaultRunspace.apartmentstate -ne 'STA'){
  throw "This script must be run in a single threaded apartment.`r`nStart PowerShell with the -STA flag and rerun the script."

  exit

}

$nsmgr = New-Object system.xml.xmlnamespacemanager ($xaml.nametable)
$nsmgr.AddNamespace("x",$xaml.DocumentElement.x)
$xaml.window.RemoveAttribute('x:Class')

$layout_reader = (New-Object System.Xml.XmlNodeReader $xaml)
$target = [Windows.Markup.XamlReader]::Load($layout_reader)
$LayoutRoot = $target.FindName("LayoutRoot")
$LayoutRoot.add_Loaded.Invoke({

    $example_reader = (New-Object System.Xml.XmlNodeReader $example)
    $example_target = [Windows.Markup.XamlReader]::Load($example_reader)
    $LayoutRoot.Children.Add($example_target)
  })
$target.ShowDialog() | Out-Null


#>
