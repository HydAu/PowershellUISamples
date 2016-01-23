# origin: https://github.com/scottmuc/PowerYaml
# https://github.com/aaubry/YamlDotNet

$shared_assemblies_path = 'C:\developer\sergueik\csharp\SharedAssemblies'
[string[]]$shared_assemblies = @(
  # very old version of assembly copied from PowerYaml
  'YamlDotNet.Configuration.dll',
  'YamlDotNet.Converters.dll',
  'YamlDotNet.RepresentationModel.dll',
  'YamlDotNet.Core.dll',
  'nunit.core.dll' # http://www.nuget.org/api/v2/package/NUnit.Core.Engine/3.0.0-beta-4
  'nunit.framework.dll' # TODO - check if still needed when 3.0 
)

function Add-CastingFunctions ($value) {
  if ($PSVersionTable.PSVersion -ge '3.0') { return $value }
  return Add-CastingFunctionsForPosh2 ($value)
}

function Add-CastingFunctionsForPosh2 ($value) {
  return Add-Member -InputObject $value -Name ToInt -MemberType ScriptMethod -PassThru -Value `
     { [int]$this } |
  Add-Member -Name ToLong -MemberType ScriptMethod -PassThru -Value `
     { [long]$this } |
  Add-Member -Name ToDouble -MemberType ScriptMethod -PassThru -Value `
     { [double]$this } |
  Add-Member -Name ToDecimal -MemberType ScriptMethod -PassThru -Value `
     { [decimal]$this } |
  Add-Member -Name ToByte -MemberType ScriptMethod -PassThru -Value `
     { [byte]$this } |
  Add-Member -Name ToBoolean -MemberType ScriptMethod -PassThru -Value `
     { [System.Boolean]::Parse($this) }
}

function Get-YamlDocumentFromString {
  param([string]$raw_data)
  $s = New-Object System.IO.StringReader ($raw_data)
  $o = New-Object YamlDotNet.RepresentationModel.YamlStream
  $o.Load([System.IO.TextReader]$s)
  return $o.Documents[0]
}

function Get-YamlStream {
  param([string]$file_path)
  $r = [System.IO.File]::OpenText($file_path)
  $o = New-Object YamlDotNet.RepresentationModel.YamlStream
  $o.Load([System.IO.TextReader]$r)
  $r.Close()
  return $o
}

function Get-YamlDocument {
  param([string]$file_path)
  $o = Get-YamlStream $file_path
  # BUG ? : 
  # $yamlStream.RootNode 
  return $o.Documents[0].RootNode
}

function Explode-Node {
  param($node)
  $node_type = $node.GetType().Name
  if ($node_type -eq 'YamlScalarNode') {
    return Convert-YamlScalarNodeToValue $node
  } elseif ($node_type -eq 'YamlMappingNode') {
    return Convert-YamlMappingNodeToHash $node
  } elseif ($node_type -eq 'YamlSequenceNode') {
    return Convert-YamlSequenceNodeToList $node
  }
}

function Convert-YamlScalarNodeToValue ($node) {
  return Add-CastingFunctions ($node.Value)
}

function Convert-YamlMappingNodeToHash ($node) {
  $h = @{}
  $y = $node.Children
  foreach ($k in $y.Keys) {
    $h[$k.Value] = Explode-Node $y[$k]
  }
  return $h
}

function Convert-YamlSequenceNodeToList {
  param($node)
  $list = @()
  foreach ($y in $node.Children) {
    $list += Explode-Node $y
  }
  return $list
}

# NOTE: does not work well with secondary Powershell shell instances
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

# http://stackoverflow.com/questions/14894864/how-to-download-a-nuget-package-without-nuget-exe-or-visual-studio-extension
# http://www.nuget.org/api/v2/package/<assembly>/<version>
$versions = @{
  'YamlDotNet.Configuration' = $null; # 'YamlDotNet.Configuration' is no longer available through nuget
  'YamlDotNet.dll' = '3.7.0'; # currently unused - all functionality is probably in this assembly
  'YamlDotNet.Converters' = '2.2.0';
  'YamlDotNet.RepresentationModel' = '2.2.0';
  'YamlDotNet.Core' = '2.2.0';
}

pushd $shared_assemblies_path

$shared_assemblies | ForEach-Object {
  Unblock-File -Path $_
  Write-Output $_
  Add-Type -Path $_
}
popd

$filename = 'previous_run_report.yaml'
$filepath = [System.IO.Path]::Combine((Get-ScriptDirectory),$filename)
$data = (Get-Content -Path $filepath) -join "`n"
$yaml = Get-YamlDocumentFromString $data

$puppet_agent_state_log = Explode-Node $yaml.RootNode


Write-Host -ForegroundColor 'yellow' 'Logs:'
$puppet_agent_state_log['logs'] |
ForEach-Object {
  $log = $_
  Write-Host -ForegroundColor 'green' $log['message']
}

Write-Host -ForegroundColor 'yellow' 'Resource:'

$data = $puppet_agent_state_log['resource_statuses']
$data.Keys | Where-Object { $_ -match '^(?:\w+)\[(?:\w+)\]$' } |
ForEach-Object {
  $resource = $_

  if ($resource -match '^(\w+)\[(\w+)\]$') {
    $resource_type = $matches[1]
    $resource_title = $matches[2]

    if ($resource_type -eq 'Reboot' -and $resource_title -eq 'testrun') {
      @( 'resource_type',
        'title') | ForEach-Object {
        $key = $_
        Write-Host -ForegroundColor 'green' ('{0}: {1}' -f $key,$data[$resource][$key])
      }

      @(
        'skipped',
        'failed',
        'changed'
      ) | ForEach-Object {
        $key = $_
        Write-Host -ForegroundColor 'green' ('{0}: {1}' -f $key,($data[$resource][$key] -eq 'true'))
      }

      Write-Host -ForegroundColor 'blue' ('message: {0}' -f $data[$resource]['events']['message'])

    }
  }
}
