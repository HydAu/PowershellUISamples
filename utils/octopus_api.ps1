param(
  [string]$shared_assemblies_path,
  [string]$apikey = 'API-YXJXYDPBB1SQC4DDETXVVDFFBOU',
  [string]$OctopusURI = 'http://octopus.carnival.com:81/',
  [switch]$pause
)

function extract_match {

  param(
    [string]$source,
    [string]$capturing_match_expression,
    [string]$label,
    [System.Management.Automation.PSReference]$result_ref = ([ref]$null)

  )
  Write-Debug ('Extracting from {0}' -f $source)
  $local:results = {}
  $local:results = $source | where { $_ -match $capturing_match_expression } |
  ForEach-Object { New-Object PSObject -prop @{ Media = $matches[$label]; } }
  Write-Debug 'extract_match:'
  Write-Debug $local:results
  $result_ref.Value = $local:results.Media
}


function custom_pause {

  param([bool]$fullstop)
  # Do not close Browser / Selenium when run from Powershell ISE

  if ($fullstop) {
    try {
      Write-Output 'pause'
      [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    } catch [exception]{}
  } else {
    Start-Sleep -Millisecond 1000
  }

}

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

<#
The folloging articles (available via google cache only) cover communicaing with octopus REST API by linking to Octopus and third party .net libraries

https://dalmirogranias.wordpress.com/2014/09/19/using-octopus-client-library-with-powershell/
https://dalmirogranias.wordpress.com/2014/09/19/octopus-api-and-powershell-getting-the-libraries-and-connecting-to-octopus/
https://dalmirogranias.wordpress.com/2014/09/23/octopus-api-and-powershell-getting-octopus-data-with-powershell/
https://dalmirogranias.wordpress.com/2014/09/27/octopus-api-and-powershell-creating-and-configuring-environments/
https://dalmirogranias.wordpress.com/2014/09/27/octopus-api-and-powershell-adding-external-nuget-feeds-to-the-octopus-library/


Phase 1 -  create sample API as described
Phase 2  - 
we may eventually want to have a groovy client to control deployment from a unix machine (e.g  from a Jenkins workflow 

#>



$shared_assemblies = @(
  'Octopus.Client.dll',
  'Octopus.Platform.dll',
  'Newtonsoft.Json.dll',
  'nunit.framework.dll'
)
if (-not $shared_assemblies_path) {
  if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
    $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
  }
}
if (-not $shared_assemblies_path) {
  $shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'
}
pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd

$verificationErrors = New-Object System.Text.StringBuilder

#Creating a connection
$endpoint = New-Object Octopus.Client.OctopusServerEndpoint $OctopusURI,$apikey
$repository = New-Object Octopus.Client.OctopusRepository $endpoint
$status = $repository.ServerStatus.GetServerStatus()
[NUnit.Framework.StringAssert]::AreEqualIgnoringCase($status.GetType().ToString(),'Octopus.Client.Model.ServerStatusResource')
# TODO timeouts 
return

<#
Powerhsell style 
$repository.DeploymentProcesses.FindAll()
$repository.Deployments.FindAll()
$repository.Environments.FindAll()
$repository.Machines.FindAll()
$repository.ProjectGroups.FindAll()
$repository.Projects.FindAll()
$repository.Releases.FindAll()
$machines | Where-Object {$_.IsDisabled -eq $false} | Select Name,Uri
#>

<#
http://www.nudoq.org/#!/Packages/Octopus.Client/Octopus.Client/OctopusClient
#>
