param(
  [switch]$whatif,
  [switch]$debug
)

# Powershell 4 Windows Management Framework 
$packages = @(
  'Windows6.0-KB968389-x64.msu',
  'Windows6.0-KB2506146-x64.msu' 
)


$packages | ForEach-Object { $package = $_;

  $command = ('{0} {1} /quiet /norestart' -f 'wusa.exe',(Resolve-Path $package))

  if ([bool]$PSBoundParameters['whatif'].IsPresent) {
    Write-Output $command
  } else {
    $status = Invoke-Expression -Command $command
  }

}
<#

Update for Windows Server 2008 x64 Edition (KB968389)  
https://www.microsoft.com/en-us/download/details.aspx?id=15109

Windows Management Framework 3.0 
https://www.microsoft.com/en-us/download/details.aspx?id=34595 
http://download.microsoft.com/download/E/7/6/E76850B8-DA6E-4FF5-8CCE-A24FC513FD16/Windows6.0-KB2506146-x64.msu

#>
