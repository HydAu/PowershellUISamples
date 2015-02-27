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

Add-Type -AssemblyName PresentationFramework


# requires -version 2
# origin: http://www.codeproject.com/Articles/68748/TreeTabControl-A-Tree-of-Tab-Items

[xml]$xaml =
@"
<?xml version="1.0"?>
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:custom="clr-namespace:TreeTab;assembly=TreeTab" Title="Window1" Margin="0,0,0,0" Height="244" Width="633">
  <Grid x:Name="Container">
    <Grid.RowDefinitions>
      <RowDefinition Height="30"/>
      <RowDefinition Height="*"/>
    </Grid.RowDefinitions>
    <Grid>
      <Grid.ColumnDefinitions>
        <ColumnDefinition/>
        <ColumnDefinition/>
      </Grid.ColumnDefinitions>
      <Button x:Name="Hide_Tree" Grid.Column="1">Hide Tree</Button>
      <Button x:Name="Show_Tree" Grid.Column="0">Show Tree</Button>
    </Grid>
    <Grid x:Name="Container2" Grid.Row="1" Margin="5,5,5,5">
      <StackPanel x:Name="TreeTabContainer"></StackPanel>
    </Grid>
  </Grid>
</Window>
"@




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


Clear-Host


$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$target = [Windows.Markup.XamlReader]::Load($reader)

$t = New-Object -TypeName 'TreeTab.TreeTabControl'

$c = $target.FindName('TreeTabContainer')
$t.IsTreeExpanded = $true
$t.Name = 'treeTab'
[void]$t.HideTree()
[void]$t.AddTabItem('Global','Global',$false,$t.ConvertType('MAIN'),'')
[void]$t.AddTabItem('Staging_Environment','Staging Environment',$false,$t.ConvertType('GROUP'),'')
[void]$t.AddTabItem('Test_Environment','Test Environment',$false,$t.ConvertType($t.ConvertType('GROUP')),'')

[TreeTab.TreeTabItemGroup]$tp0 = [TreeTab.TreeTabItemGroup]$t.GetTabItemById('Staging_Environment')
[TreeTab.TreeTabItem]$tItem = $t.AddTabItem('Certificates','Certificates',$false,$t.ConvertType('MAIN'),$tp0)
[void]$t.AddTabItem('IIS_Web_Sites','IIS Web Sites',$false,$t.ConvertType('GROUP'),$tp0)
[void]$t.AddTabItem('Databases','Databases',$false,$t.ConvertType('GROUP'),$tp0)

[TreeTab.TreeTabItemGroup]$tp02 = [TreeTab.TreeTabItemGroup]$t.GetTabItemById('Databases')
[void]$t.AddTabItem('DB_1','DB 1',$true,$t.ConvertType('MAIN'),$tp02)
[void]$t.AddTabItem('DB_2','DB 2',$true,$t.ConvertType('MAIN'),$tp02)

[TreeTab.TreeTabItemGroup]$tp03 = [TreeTab.TreeTabItemGroup]$t.GetTabItemById('IIS_Web_Sites')
[void]$t.AddTabItem('Site_1','Site 1',$true,$t.ConvertType('MAIN'),$tp03)
[void]$t.AddTabItem('Site_2','Site 2',$true,$t.ConvertType('MAIN'),$tp03)
[void]$t.AddTabItem('Site_3','Site 3',$true,$t.ConvertType('MAIN'),$tp03)
[void]$t.AddTabItem('Site_4','Site 4',$true,$t.ConvertType('MAIN'),$tp03)


[TreeTab.TreeTabItemGroup]$tp01 = [TreeTab.TreeTabItemGroup]$t.GetTabItemById('Test_Environment')
[TreeTab.TreeTabItem]$t23 = $t.AddTabItem('Certificates1','Certificates',$false,$t.ConvertType('MAIN'),$tp01)
[void]$t.AddTabItem('IIS_Web_Sites2','IIS Web Sites',$false,$t.ConvertType('GROUP'),$tp01)
[void]$t.AddTabItem('Databases2','Databases',$false,$t.ConvertType('GROUP'),$tp01)


[TreeTab.TreeTabItemGroup]$tp12 = [TreeTab.TreeTabItemGroup]$t.GetTabItemById('Databases2')
[void]$t.AddTabItem('DB_11','DB 1',$true,$t.ConvertType('MAIN'),$tp12)
[void]$t.AddTabItem('DB_12','DB 2',$true,$t.ConvertType('MAIN'),$tp12)

[TreeTab.TreeTabItemGroup]$tp13 = [TreeTab.TreeTabItemGroup]$t.GetTabItemById('IIS_Web_Sites2')
[void]$t.AddTabItem('Site_11','Site 1',$true,$t.ConvertType('MAIN'),$tp13)
[void]$t.AddTabItem('Site_12','Site 2',$true,$t.ConvertType('MAIN'),$tp13)
[void]$t.AddTabItem('Site_13','Site 3',$true,$t.ConvertType('MAIN'),$tp13)
[void]$t.AddTabItem('Site_14','Site 4',$true,$t.ConvertType('MAIN'),$tp13)


[void]$t.ShowTree()
[void]$c.AddChild($t)

$target.FindName("Hide_Tree").add_click.Invoke({
    [void]$t.HideTree()
  })
$target.FindName("Show_Tree").add_click.Invoke({
    [void]$t.ShowTree()
  })

$target.ShowDialog() | Out-Null
<#
TODO: handle 
Execution of the script frequently leads  to
Exception calling "ShowDialog" with "0" argument(s): "Not enough quota is available to process this command"
#>
