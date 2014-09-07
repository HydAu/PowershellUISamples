$env:SHARED_ASSEMBLIES_PATH = "c:\developer\sergueik\csharp\SharedAssemblies"


$shared_assemblies = @(
  'Interop.SHDocVw.dll',
  'Microsoft.mshtml.dll',
  'WatiN.Core.dll',
  'nunit.framework.dll',
  'nunit.core.dll'
)

$shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd

# TODO : detect if jssh.xpi plugin was installed 
# one need to fix install.rdf - the plugin says it is not compatible with Firefox 32
# $browser = New-Object WatiN.Core.Firefox('http://www.wikipedia.org/')

$browser = New-Object WatiN.Core.IE ('http://www.wikipedia.org/')
<#

Settings.Instance.MakeNewIeInstanceVisible = false;

#>
try {
  $browser.ShowWindow([WatiN.Core.Native.Windows.NativeMethods.WindowShowStyle]::Maximize)
} catch [exception]{

}
try {
[WatiN.Core.Element]$text_field = $browser.Element([WatiN.Core.Find]::ByName('search'))
} catch [Exception] {
write-output $_.Exception.Message
}
[NUnit.Framework.Assert]::IsTrue($text_field.Exists)
write-host ("--->" + $text_field.OuterHtml)
write-host ("--->" + $text_field.getType())


<#
# WatiN doesn't support HTML5 tags yet
try {
[WatiN.Core.TextFieldExtended]$text_field = $browser.ElementOfType<TextFieldExtended>([WatiN.Core.Find]::ByName('search'))
# The '<' operator is reserved for future use.
} catch [Exception] {
write-output $_.Exception.Message
}
[NUnit.Framework.Assert]::IsTrue($text_field.Exists)

#>

# WatiN doesn't support HTML5 tags yet
try {
[WatiN.Core.TextField]$text_field = $browser.TextField([WatiN.Core.Find]::ByName('search'))
} catch [Exception] {
write-output $_.Exception.Message
}
[NUnit.Framework.Assert]::IsTrue($text_field.Exists)

$text_field.NativeElement | Get-Member
$x = $text_field.NativeElement
$x.Children | Get-Member
$x.Children | format-list
#$text_field.TextFields | get-Member
# ([WatiN.Core.TextField]$text_field).TypeText('selenium')
# $text_field.Value = 'selenium'


[WatiN.Core.Button]$button = $browser.Button([WatiN.Core.Find]::ByName('go'))
Write-Host $button.OuterHtml
$button.Focus()
$button.Click()

[NUnit.Framework.Assert]::IsTrue($browser.ContainsText('selenium'))
Start-Sleep 10
$browser.Close()
