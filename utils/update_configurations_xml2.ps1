#  Update connectionStrings config to point to original dbs on prod-preview (ConnectionStrings.config)
#  Update connectionStrings config to point to original dbs on Sitecore authoring web servers (ConnectionStrings.config)

param(
  [Parameter(Position = 0)]
  [switch]$parallel,
  [string]$domain = $env:USERDOMAIN
)


  # TODO : Assert 
  # need $host.Version.major ~> 3
  # e.g. run from cclprdwebops1.carnival.com


$global:timestamp = (Get-Date).ToString("yy_MM_dd_HH_MM")

function backup_file {
  param([string]$filename,[bool]$whatif = $true)

  # This is not really a basename
  if ($filename -match '(.+)\.([^\.]+)$') {
    $extension = $matches[2]
    $basename = $matches[1]
  }
  if ($whatif) {
    Copy-Item $filename -Destination ('{0}-{1}.{2}' -f $basename,$global:timestamp,$extension) -WhatIf
  } else {
    Copy-Item $filename -Destination ('{0}-{1}.{2}' -f $basename,$global:timestamp,$extension) -WhatIf
  }
  return
}

function convert_to_unc2 {
  param(
    [string]$mixed_path
  )
  $unc_file_path = $mixed_path -replace ':','$'
  return $unc_file_path
}


function collect_config_data {

  param(
    [ValidateNotNull()]
    [string]$target_domain,
    [string]$target_unc_path,
    [scriptblock]$script_block,
    [bool]$to_parallel = $false, 
    [bool]$powerless,
    [bool]$verbose,
    [bool]$debug


  )

  $local:result = @()
  $verbose = $true
  if (($target_domain -eq $null) -or ($target_domain -eq '')) {
    # Write-Output 'unspecified DOMAIN'
    if ($powerless) {
      return $local:result
    } else {
      throw
    }
  }
  if (-not ($target_domain -match $env:USERDOMAIN)) {
    # mock up can be passed the domain. 

    # gets into the result...
    # Write-Output 'Unreachable DOMAIN'
    # real run swill about
    if ($powerless) {
      return $local:result
    } else {
      throw
    }
  }
  if ($verbose) {
    Write-output ('Probing "{0}"' -f $target_unc_path) | out-file 'data.log' -append -encoding ascii
  }

  backup_file -file $target_unc_path

  [xml]$xml_config = Get-Content -Path $target_unc_path
  $object_ref = ([ref]$xml_config)

  $result_ref = ([ref]$local:result)

  Invoke-Command $script_block -ArgumentList $object_ref,$result_ref,$to_parallel

  if ($verbose) {
    Write-output ("Result:`r`n---`r`n{0}`r`n---`r`n" -f ($local:result -join "`r`n")) | out-file 'data.log' -append -encoding ascii
  }



  # OPTIONAL -  write to alt name, read alt. name 
  # TODO: save

  $filename = $target_unc_path
  # This is not really a basename
  if ($filename -match '(.+)\.([^\.]+)$') {
    $extension = $matches[2]
    $basename = $matches[1]
  }

  $tempname = ('{0}-{1}.{2}' -f $basename,$global:timestamp,$extension)
  $new_config_file_path = $tempname

  Write-Host ('Saving to "{0}" ' -f $new_config_file_path)
  $object_ref.Value.Save($new_config_file_path)
#
#  Start-Sleep 3

  # B {Write-Host 2; &$block}.GetNewClosure()
  return $local:result


}

# this scriptblock action  is shared between all role / node configurations 
[scriptblock]$CONFIGURATION_DISCOVERY = {
  param(
    [System.Management.Automation.PSReference]$object_ref,
    [System.Management.Automation.PSReference]$result_ref,
    [bool]$to_parallel
)

write-host '1'
$nodes = $object_ref.Value.connectionStrings.add
for ($cnt = 0; $cnt -ne $nodes.count; $cnt++) {


  $attribute_old_value = $object_ref.Value.connectionStrings.add[$cnt].Getattribute("connectionString")
  # to sckip certain properties from updating use the match

  # Need to leave alone "Sitecore_EnterpriseCommerce" and "Sitecore_WebForms"
  if ($attribute_old_value  -match 'CarnivalSitecore_') {

  if ($to_parallel) {
   $attribute_new_value = ('{0}{1}' -f  $attribute_old_value ,'_PARALLEL')
 }  else {
  $attribute_new_value = $attribute_old_value -replace '_PARALLEL$',''
}
  Write-Host ("Replacing`n{0}`nwith`n{1}" -f  $attribute_old_value ,  $attribute_new_value  )

  $object_ref.Value.connectionStrings.add[$cnt].SetAttribute("connectionString",$attribute_new_value )
  }


}
  $result_ref.Value = $data
}

# TODO  - add more configurations ?

$configuration_paths = @{
  'Sitecore' =
  @{
    'COMMENT' = 'Sitecore Authoring Servers ConnectionStrings.config';
    'PATH' = 'E:\SitecoreCMS\Carnival\Website\App_Config\ConnectionStrings.config';
    'DOMAIN' = 'CARNIVAL';
    'SERVERS' = @(
      'cclprdecocms1.carnival.com',
      'cclprdecocms2.carnival.com',
      'cclprdecocms3.carnival.com',
      $null
    );
  };
  'Preview' =
  @{
    'COMMENT' = 'Production Preview Servers ConnectionStrings.config';
    'PATH' = 'E:\projects\prod.carnival.com\Carnival\app_config\ConnectionStrings.config';
    'DOMAIN' = 'CARNIVAL';
    'SERVERS' = @(
      'cclprdecopv1.carnival.com',
      $null
    );
  };

};

[bool]$to_parallel = $false 

  if ($PSBoundParameters["parallel"]) {
$to_parallel = $true
} else 
{
$to_parallel = $false
}


foreach ($role in $configuration_paths.Keys) {
  $configuration = $configuration_paths.Item($role)
  Write-Output ('Starting {0}' -f $configuration['COMMENT'])
  # check if we can skip unreachable domain results , 
  # by returning the status from collect_config_data
  # for simplicity skip if not current domain  
  if ($configuration['DOMAIN'] -eq $domain) {
    if ($configuration.Containskey('SERVERS')) {
      $servers = $configuration['SERVERS']
      $unc_paths = @()
      $configuration['RESULTS'] = @{} # keyed by server
      $configuration_results = @{}
      $servers | ForEach-Object { $server = $_; if ($server -eq $null) { return } $unc_paths += convert_to_unc2 (('\\{0}\{1}' -f $server,$configuration['PATH']))
      }
    }
    elseif ($configuration.Containskey('UNC_PATHS')) {
      $unc_paths = $configuration['UNC_PATHS']

    } else {
      # TODO handle malformed configurations 
    }
    [scriptblock]$script_block = $CONFIGURATION_DISCOVERY
    Write-Output ("Inspecting nodes in the domain {0}" -f $configuration['DOMAIN'])
    $unc_paths | ForEach-Object { $target_unc_path = $_; if ($target_unc_path -eq $null) { return }
      $configuration_results[$target_unc_path] = @()
      $configuration_results[$target_unc_path] = collect_config_data -target_domain $configuration['DOMAIN'] `
         -target_unc_path $target_unc_path `
         -to_parallel $to_parallel `
         -powerless $true `
         -script_block $script_block
    }

    $configuration['RESULTS'] = $configuration_results
  }
}
