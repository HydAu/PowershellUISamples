#Copyright (c) 2015 Serguei Kouzmine
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.



# https://www.simple-talk.com/sysadmin/powershell/getting-data-into-and-out-of--powershell-objects/
# ConvertTo-YAML, ConvertTo-PSON in Powershell
# https://yaml.svn.codeplex.com/svn 
# parser
# http://www.codeproject.com/Articles/28720/YAML-Parser-in-C 


function load_shared_assemblies {

  param(
    [string]$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies',

    [string[]]$shared_assemblies = @(
      'YamlDotNet.dll', # https://github.com/aaubry/YamlDotNet
      'YamlSerializer.dll', # https://www.nuget.org/packages/YAML-Serializer/
      'nunit.core.dll',
      'nunit.framework.dll'
    )
  )
  pushd $shared_assemblies_path

  $shared_assemblies | ForEach-Object {
    Unblock-File -Path $_
    # Write-Debug $_
    Add-Type -Path $_
  }
  popd
}

load_shared_assemblies

# Get a sample object
$events_object = @()
$last_hour = (Get-Date) - (New-TimeSpan -Hour 1)
$events = Get-WinEvent -FilterHashtable @{ logname = "Microsoft-Windows-TaskScheduler/Operational"; level = "4"; StartTime = $last_hour }
$events | ForEach-Object {
  $events_object += $_
}
$sample_event_object = $events_object[0]

$sample_event_object | ConvertTo-Json -Depth 10


Write-Output 'Serializing to YAML:'

$serializer = New-Object -TypeName System.Yaml.Serialization.YamlSerializer
Write-Output ('Provider: {0}.{1}' -f $serializer.getType().Namespace,$serializer.getType().Name)
$serializer.Serialize($sample_event_object)


Write-Output 'Serializing to YAML:'

# cannot rely on optional arguments in Powershell:
# new-object : A constructor was not found. Cannot find an appropriate constructor for type YamlDotNet.Serialization.Serializer.
# https://dotnetfiddle.net/QlqGDV
$serializer = New-Object YamlDotNet.Serialization.Serializer ([YamlDotNet.Serialization.SerializationOptions]::EmitDefaults,$null)
Write-Output ('Provider: {0}.{1}' -f $serializer.getType().Namespace,$serializer.getType().Name)
$serializer.Serialize([System.Console]::Out,$sample_event_object)



# May want to use https://github.com/scottmuc/PowerYaml/blob/master/Functions/YamlDotNet-Integration.ps1
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
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf(''))
  }
}

# https://github.com/sergueik/powershell_ui_samples/blob/3813d0932fc902195fe34ad56652eb7afadbc5b3/external/yaml_serializer.ps1
$shared_assemblies_path = Get-ScriptDirectory
# http://stackoverflow.com/questions/14894864/how-to-download-a-nuget-package-without-nuget-exe-or-visual-studio-extension
[string[]]$shared_assemblies = @(
  'YamlDotNet.dll',# http://www.nuget.org/api/v2/package/YamlDotNet/3.7.0 -> rename yamldotnet.3.7.0.nupkg
  'YamlSerializer.dll' # http://www.nuget.org/api/v2/package/YAML-Serializer/1.2.0-beta
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


$filename = 'previous_run_report.yaml'
$data = (Get-Content -Path ([System.IO.Path]::Combine((Get-ScriptDirectory),$filename))) -join "`n"

$stringReader = New-Object System.IO.StringReader ($data)
$yamlStream = New-Object YamlDotNet.RepresentationModel.YamlStream
$yamlStream.Load([System.IO.TextReader]$stringReader)

# need custom 
$rootNode = $yamlStream.RootNode
$item_values = $rootNode.Value
0..($item_values.count - 1) | ForEach-Object {
  $cnt = $_;
  $data1 = $item_values[$cnt].Key.Value
  if ($data1 -match '^(\w+)\[(\w+)\]$') {
    # write-output $cnt 
    $type1 = $matches[1]
    $title1 = $matches[2]
    if ($type1 -eq 'Reboot') {
      Write-Output (("{0}{{ '{1}' : ... }} ({2})") -f $type1,$title1,$cnt)
      # write-output  $item_values[$cnt].Value
      $data2 = $item_values[$cnt].Value
      # $data2 | get-member
      $data2.Value.count
      $data3 = $data2.Value
      $count2 = $data2.Value.count
      0..$count2 | ForEach-Object {
        $count3 = $_
        $data4 = $data3[$count3].Key.Value
        if ($data4 -eq 'message') {
          Write-Output $count3
          Write-Output ('->' + $data4 + '|')
          Write-Output $data3[$count3].Value.Value
        }
      }
      # $data2.Value[11]
      # write-output  $item_values[$cnt].Value['changed']
      <#

@(

changed

out_of_sync

skipped)

#>
    }
  }

}

