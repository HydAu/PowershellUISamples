# TODO: remove post 2008 'WebAdministration' Powershell module dependency

# Installl from http://www.iis.net/downloads/microsoft/powershell
# http://stackoverflow.com/questions/1924217/powershell-load-webadministration-in-ps1-script-on-both-iis-7-and-iis-7-5/4325963#4325963
# https://technet.microsoft.com/en-us/library/ee790599.aspx
# install  different based on the Application version
$iisVersion = Get-ItemProperty 'HKLM:\software\microsoft\InetStp'
if ($iisVersion.MajorVersion -eq 7)
{
  if ($iisVersion.MinorVersion -ge 5)
  {
    Import-Module WebAdministration
  }
  else
  {
    if (-not (Get-PSSnapin | Where { $_.Name -eq "WebAdministration" })) {
      Add-PSSnapin WebAdministration

# NOTE : 
# will not work with Powershell $host 3.0
# is iis powershell snapin even installed ?
# Add-PSSnapin : No snap-ins have been registered for Windows PowerShell version 3.


    }
  }
}


Get-PSSnapin | Where-Object { $_.Name -eq 'WebAdministration' }


# http://blogs.msdn.com/b/carlosag/archive/2008/02/11/microsoftwebadministrationinpowershell.aspx
[void][Reflection.Assembly]::LoadWithPartialName("Microsoft.Web.Administration")

$iis = New-Object -TypeName 'Microsoft.Web.Administration.ServerManager'

$iisStatus = Get-Service -Name 'W3SVC'

$server = @()
$sites = @()

$iis.sites | ForEach-Object { $site = $_
  $applications = @()

  $site.Applications | ForEach-Object { $appPool = $_
    $appPoolName = $appPool.ApplicationPoolName
    $apppoolobject = $iis.ApplicationPools[$appPoolName]
    $applications += @{
      'applicationName' = $appPool.Path;
      'applicationPool' = $appPool.ApplicationPoolName;
      'dotNetVersion' = $apppoolobject.ManagedRuntimeVersion;
      'status' = $apppoolobject.State;
      'mode' = $apppoolobject.ManagedPipelineMode;

    }

  }
  $bindings = @()
  $site.Bindings | ForEach-Object { $binding = $_
    $bindings += @{
      'Host' = $binding.Host;
      'Protocol' = $binding.Protocol;
      #  do not collect EndPoint information  which one cannot use 
      'BindingInformation' = $binding.BindingInformation;

    }
  }

# use cmdlet
$site_obj = (Get-Website) | Where-Object { $_.Name -eq $site.Name }


  $sites += @{
    'Id' = $site.Id;
    'Name' = $site.Name;
    'State' = $site.State;
    'Path' = $site_obj.PhysicalPath;
    'Applications' = $applications;
    'Bindings' = $bindings;
  }
}

$server += @{

  'serverName' = $env:ComputerName;
  'iisStatus' = $iisStatus.State;
  'Sites' = $sites;

}

$server | ConvertTo-Json -Depth 10
