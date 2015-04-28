param(
  [switch]$configure,
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


$shared_assemblies = @{
  'nunit.core.dll' = $null;
  'nunit.framework.dll' = $null;
  'nlog.dll' = '3.2'; 
}


$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}

pushd $shared_assemblies_path
$shared_assemblies.Keys | ForEach-Object {
  # http://all-things-pure.blogspot.com/2009/09/assembly-version-file-version-product.html
  $assembly = $_
  $assembly_path = [System.IO.Path]::Combine($shared_assemblies_path,$assembly)
  $assembly_version = [Reflection.AssemblyName]::GetAssemblyName($assembly_path).Version
  $assembly_version_string = ('{0}.{1}' -f $assembly_version.Major,$assembly_version.Minor)
  if ($shared_assemblies[$assembly] -ne $null) {
    # http://stackoverflow.com/questions/26999510/selenium-webdriver-2-44-firefox-33
    if (-not ($shared_assemblies[$assembly] -match $assembly_version_string)) {
      Write-Output ('Need {0} {1}, got {2}' -f $assembly,$shared_assemblies[$assembly],$assembly_path)
      Write-Output $assembly_version
      throw ('invalid version :{0}' -f $assembly)
    }
  }

  if ($host.Version.Major -gt 2) {
    Unblock-File -Path $_;
  }
  Write-Debug $_
  Add-Type -Path $_
}
popd

$logger_name = 'Example' 

$logger  = [NLog.LogManager]::GetLogger($logger_name)
$i = [NLog.LogManager]::IsLoggingEnabled()
[NLog.LogManager]::EnableLogging()
# For full functionality use the Powershell Modules 
# origin https://pslog.codeplex.com/SourceControl/latest#trunk/examples/FileSimple.ps1
  if ($PSBoundParameters['configure']) {
$target = New-Object NLog.Targets.FileTarget
# NOTE precision limitation. 
$target.Layout       = '${date:format=HH\:mm\:ss}|${level}|${message}|${stacktrace}'
$target.FileName     = ('{0}\logfile.txt' -f (Get-ScriptDirectory))
$target.KeepFileOpen = $false
$target.Encoding     = [System.Text.Encoding]::ascii

[NLog.Config.SimpleConfigurator]::ConfigureForTargetLogging($target, [NLog.LogLevel]::Debug)
  } else {
# TODO: assert that the 'nlog.config' is present
}
<#

#>
$logger.Debug('Hello World!');
$logger.Trace('Hello World!');
$logger.Warn('Hello World!');
$logger.Fatal('Hello World!');
