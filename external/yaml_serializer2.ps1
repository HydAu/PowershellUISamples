function Add-CastingFunctions ($value) {
  if ($PSVersionTable.PSVersion -ge "3.0") { return $value }
  return Add-CastingFunctionsForPosh2 ($value)
}

function Add-CastingFunctionsForPosh2 ($value) {
  return Add-Member -InputObject $value -Name ToInt `
     -MemberType ScriptMethod -PassThru -Value `
     { [int]$this } |
  Add-Member -Name ToLong `
     -MemberType ScriptMethod -PassThru -Value `
     { [long]$this } |
  Add-Member -Name ToDouble `
     -MemberType ScriptMethod -PassThru -Value `
     { [double]$this } |
  Add-Member -Name ToDecimal `
     -MemberType ScriptMethod -PassThru -Value `
     { [decimal]$this } |
  Add-Member -Name ToByte `
     -MemberType ScriptMethod -PassThru -Value `
     { [byte]$this } |
  Add-Member -Name ToBoolean `
     -MemberType ScriptMethod -PassThru -Value `
     { [System.Boolean]::Parse($this) }
}

function get-YamlData ([string]$data) {
  $stringReader = New-Object System.IO.StringReader ($data)
  $yamlStream = New-Object YamlDotNet.RepresentationModel.YamlStream
  $yamlStream.Load([System.IO.TextReader]$stringReader)

  return $yamlStream
}

function Get-YamlStream ([string]$file) {
  $streamReader = [System.IO.File]::OpenText($file)
  $yamlStream = New-Object YamlDotNet.RepresentationModel.YamlStream
  $yamlStream.Load([System.IO.TextReader]$streamReader)
  $streamReader.Close()
  return $yamlStream
}

function Get-YamlDocument ([string]$file) {
  $yamlStream = Get-YamlStream $file
  # Cannot index into a null array.
  $document = $yamlStream.Documents[0].RootNode
  # BUG: occationally the $yamlStream does not 
  # $document = $yamlStream.RootNode

  return $document
}

function Get-YamlDocumentFromString ([string]$yamlString) {
  $stringReader = New-Object System.IO.StringReader ($yamlString)
  $yamlStream = New-Object YamlDotNet.RepresentationModel.YamlStream
  $yamlStream.Load([System.IO.TextReader]$stringReader)
  $document = $yamlStream.Documents[0]
  return $document
}

function Explode-Node ($node) {
  if ($node.GetType().Name -eq "YamlScalarNode") {
    return Convert-YamlScalarNodeToValue $node
  } elseif ($node.GetType().Name -eq "YamlMappingNode") {
    return Convert-YamlMappingNodeToHash $node
  } elseif ($node.GetType().Name -eq "YamlSequenceNode") {
    return Convert-YamlSequenceNodeToList $node
  }
}

function Convert-YamlScalarNodeToValue ($node) {
  return Add-CastingFunctions ($node.Value)
}

function Convert-YamlMappingNodeToHash ($node) {
  $hash = @{}
  $yamlNodes = $node.Children
  foreach ($key in $yamlNodes.Keys) {
    $hash[$key.Value] = Explode-Node $yamlNodes[$key]
  }
  return $hash
}
function Convert-YamlSequenceNodeToList ($node) {
  $list = @()
  $yamlNodes = $node.Children
  foreach ($yamlNode in $yamlNodes) {
    $list += Explode-Node $yamlNode
  }
  return $list
}

# does not work well with secondary Powershell shell instances
function Get-ScriptDirectory

{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  if ($Invocation.PSScriptRoot) {
    $Invocation.PSScriptRoot
  }
  elseif ($Invocation.MyCommand.Path) {
    Split-Path $Invocation.MyCommand.Path
  } else {
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf(''))
  }
}

$shared_assemblies_path = 'C:\developer\sergueik\csharp\SharedAssemblies'
# http://stackoverflow.com/questions/14894864/how-to-download-a-nuget-package-without-nuget-exe-or-visual-studio-extension
[string[]]$shared_assemblies = @(
  'YamlDotNet.Configuration.dll',
  'YamlDotNet.Converters.dll',
  'YamlDotNet.RepresentationModel.dll',
  'YamlDotNet.dll' # http://www.nuget.org/api/v2/package/YamlDotNet/3.7.0
  # 'nunit.core.dll' # http://www.nuget.org/api/v2/package/NUnit.Core.Engine/3.0.0-beta-4
  # 'nunit.framework.dll' # TODO - check if still needed when 3.0 
)
pushd $shared_assemblies_path

$shared_assemblies | ForEach-Object {
  Unblock-File -Path $_
  # Write-Debug $_
  Add-Type -Path $_
}
popd
# https://raw.githubusercontent.com/puppetlabs/mcollective-puppet-agent/master/spec/fixtures/last_run_report.yaml
$filename = 'previous_run_report.yaml'
$filepath = [System.IO.Path]::Combine((Get-ScriptDirectory),$filename)
$data = (Get-Content -Path $filepath ) -join "`n"
$yaml = Get-YamlData $data

$x = Explode-Node  $yaml.Documents.RootNode 

