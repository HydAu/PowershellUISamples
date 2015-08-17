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

