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

$shared_assemblies = @(
  'TreeTab.dll',
  'nunit.framework.dll'
)
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')

$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}

pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd

$verificationErrors = New-Object System.Text.StringBuilder

Add-Type -AssemblyName PresentationFramework


# origin: http://www.codeproject.com/Articles/68748/TreeTabControl-A-Tree-of-Tab-Items
# requires -version 2
<#
Exception calling "Load" with "1" argument(s): "Specified class name
'TreeTabTest.Window1' doesn't match actual root instance type
'System.Windows.Window'. Remove the Class directive or provide an instance via
XamlObjectWriterSettings.RootObjectInstance."

Exception calling "Load" with "1" argument(s): "Cannot create unknown type
'{clr-namespace:TreeTab;assembly=TreeTab}TreeTabControl'."
#>
Add-Type -AssemblyName PresentationFramework
[xml]$xaml =
@"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    xmlns:custom="clr-namespace:TreeTab;assembly=TreeTab"
    Title="Window1" Margin="0,0,0,0">
    <Grid x:Name="Container">
        <Grid.RowDefinitions>
            <RowDefinition Height="50"></RowDefinition>
            <RowDefinition Height="*"></RowDefinition>
        </Grid.RowDefinitions>
        <Grid>
            <Grid.ColumnDefinitions>
                <ColumnDefinition></ColumnDefinition>
                <ColumnDefinition></ColumnDefinition>
                <ColumnDefinition></ColumnDefinition>
                <ColumnDefinition></ColumnDefinition>
                <ColumnDefinition></ColumnDefinition>
                <ColumnDefinition></ColumnDefinition>
                <ColumnDefinition></ColumnDefinition>                
            </Grid.ColumnDefinitions>
            <Button x:Name="btnAddTab1" Grid.Column="0">Add Main Tab</Button>
            <Button x:Name="btnAddTab2" Grid.Column="1">Add Closable Group Tab</Button>
            <Button x:Name="btnAddTab3" Grid.Column="2">Add Children to Tab Group</Button>
            <Button x:Name="btnAddTab4" Grid.Column="3">Add Group Tab</Button>
            <Button x:Name="btnAddTab5" Grid.Column="4">Add Children to Tab Group</Button>
            <Button x:Name="btnCollapseTree" Grid.Column="5">Collapse Tree</Button>
            <Button x:Name="btnExpandTree" Grid.Column="6">Expand Tree</Button>
        </Grid>


        <Grid x:Name="Container2" Grid.Row="1" Margin="5,5,5,5">

    <StackPanel Height="100" x:Name="TreeTabContainer" >

  </StackPanel>
<!--
            <custom:TreeTabControl Name="treeTab" IsTreeExpanded="True">
                
            </custom:TreeTabControl>
-->
        </Grid>

    </Grid>
</Window>
"@

Clear-Host
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$target = [Windows.Markup.XamlReader]::Load($reader)
$control = $target.FindName("btnAddTab1")
$eventMethod = $control.add_click
$eventMethod.Invoke({ $target.Title = "Hello $((Get-Date).ToString('G'))" })

$o = new-Object -type 'TreeTab.TreeTabControl' 


    $control = $target.FindName("TreeTabContainer")
# $control | get-member
$o.IsTreeExpanded = $true
$o.Name="treeTab"
$control.AddChild($o)

$target.ShowDialog() | Out-Null
<#
    $so.Indicator = $target.FindName("hourglass")
    $contents = $target.FindName("tooltip_textbox")
    $so.Control = $control
    $so.Contents = $contents
    $handler_opened = {
      param(
        [object]$sender,
        [System.Windows.RoutedEventArgs]$eventargs
      )
      $so.Contents.Text = 'please wait...'
      $so.Indicator.Visibility = 'Visible'
      $so.NeedData = $true
      $so.Result = ''
    }
    $handler_closed = {
      param(
        [object]$sender,
        [System.Windows.RoutedEventArgs]$eventargs
      )
      $so.HaveData = $false
      $so.NeedData = $false
    }
#>
<#
Execution of the script frequently leads  to
Exception calling "ShowDialog" with "0" argument(s): "Not enough quota is available to process this command"

#>
