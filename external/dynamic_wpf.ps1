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
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="Window1" Margin="0,0,0,0">
  <Grid x:Name="LayoutRoot">
  </Grid>
</Window>
"@


Add-Type -TypeDefinition @"
using System;
using System.ComponentModel;

namespace dynamicWPF
{
    public class Person 

    {
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public bool isDefault { get; set; }
        public string EmailId { get; set; }
        public string EmployeeNo { get; set; }
        public string Age { get; set; }
        public string EmailId2 { get; set; }
        public bool isMale { get; set; }
        public string MobileNo { get; set; }
        public string TelephoneNo { get; set; }
    }

}
"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll','System.Data.dll'

Clear-Host


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

[xml]$example = @"
<?xml version="1.0"?>
<UserControl xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Height="244" Width="533">
  <Grid>
    <Label Height="28" HorizontalAlignment="Left" Margin="12,14,0,0" Name="label1" VerticalAlignment="Top" Width="92">First Name</Label>
    <TextBox Height="23" Margin="122,14,258,0" Name="textBox1" VerticalAlignment="Top"/>
    <Label Height="28" HorizontalAlignment="Left" Margin="12,38,0,0" Name="label2" VerticalAlignment="Top" Width="92">Sur Name</Label>
    <TextBox Height="23" Margin="122,43,258,0" Name="textBox2" VerticalAlignment="Top"/>
    <RadioButton Height="16" HorizontalAlignment="Left" Margin="129,88,0,0" Name="radioButton1" VerticalAlignment="Top" Width="120">Male</RadioButton>
    <RadioButton Height="16" Margin="0,88,213,0" Name="radioButton2" VerticalAlignment="Top" HorizontalAlignment="Right" Width="120">Famele</RadioButton>
    <TextBox Margin="12,110,65,50" Name="textBox3"/>
  </Grid>
</UserControl>
"@

# Clear-Host

$layout_reader = (New-Object System.Xml.XmlNodeReader $xaml)
$target = [Windows.Markup.XamlReader]::Load($layout_reader)
$LayoutRoot = $target.FindName("LayoutRoot")
$LayoutRoot.add_Loaded.Invoke({
    $obj = New-Object -TypeName 'dynamicWPF.Person'
    $obj.FirstName = "sujeet"
    $example_reader = (New-Object System.Xml.XmlNodeReader $example)
    $example_target = [Windows.Markup.XamlReader]::Load($example_reader)
    $LayoutRoot.Children.Add($example_target)
  })
$target.ShowDialog() | Out-Null


