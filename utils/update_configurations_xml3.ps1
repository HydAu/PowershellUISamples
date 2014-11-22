#       Report connectionStrings config to point to original dbs on Sitecore authoring web servers (ConnectionStrings.config)
<#
1.	Look at connection strings config file on cclprdecocms1, cms2, cms3.
1.	All connections should point to NON _parallel databases
2.	Check connection strings file on production staging
1.	All connections on \\cclprdecostg1\SitecoreCMS\Carnival\website\app_config\ should point to NON _parallel databases
3.	Look at the connectionStrings.config in \\cclprdecostg1\projects\prod.carnival.com\carnival\app_config
1.	All connections should NOT point to NON _parallel databases
2.	On the webservers (web21, ... web31) should point to NON _parallel databases

#>
# former go_nogo_validators.ps1

param(
  [Parameter(Position = 0)]
  [string]$environment,
  [string]$domain = $env:USERDOMAIN
  # need $host.Version.major ~> 3
  # e.g. run from cclprdwebops1.carnival.com
)

function match_data_source {
  param([string]$connection_string,
    [System.Management.Automation.PSReference]$result_ref,
    [bool]$debug
  )

  if ($debug) {
    Write-Host $connection_string
  }


  # NOTE: global names?
  $local:result = New-Object PSObject

  if ($connection_string -match 'Data Source=(.+);Database=(.+)') {
    $local:result | Add-Member -NotePropertyName 'datasource' -NotePropertyValue $matches[1]
    $local:result | Add-Member -NotePropertyName 'database' -NotePropertyValue $matches[2]
    if ($debug) {
      Write-Host 'match found'
    }

  }
  if ($debug) {
    Write-Host $local:result
  }

  $result_ref.Value = $local:result

}



function convert_to_unc2 {
  param(
    [string]$mixed_path
  )
  $unc_file_path = $mixed_path -replace ':','$'
  return $unc_file_path
}


function assert_config_data {
  param(
    [System.Management.Automation.PSReference]$object_ref,
    [bool]$debug
  )
  $debug = $true
  if ($debug) {
    Write-Host 'assert_config_data'
  }
  $local:data = $object_ref.Value

  $local:data.Keys | ForEach-Object {
    $unc_path = $_
    if ($debug) {

      Write-Host ('Probing configurations from: "{0}"' -f $unc_path)
    }
    $local:data[$unc_path] | ForEach-Object {
      $global:item_position = $global:item_position + 1
      if ($debug) {
        Write-Host $_
      }
      if ($_ -match '_parallel') {
        # NOP 
      } else {
        # NOP 
      }
<#
      if ($global:item_position -eq $global:bad_item_position) {
        Write-Output 'bad item found!'
        Write-Output $unc_path
        # write infor where it comes from. 
      }
#>
    }
  }
}


function collect_config_data {

  param(
    [ValidateNotNull()]
    [string]$target_domain,
    [string]$target_unc_path,
    [scriptblock]$script_block,
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

  [xml]$xml_config = Get-Content -Path $target_unc_path
  $object_ref = ([ref]$xml_config)

  $result_ref = ([ref]$local:result)

  Invoke-Command $script_block -ArgumentList $object_ref,$result_ref

  if ($verbose) {
    Write-output ("Result:`r`n---`r`n{0}`r`n---`r`n" -f ($local:result -join "`r`n")) | out-file 'data.log' -append -encoding ascii
  }
  # B {Write-Host 2; &$block}.GetNewClosure()
  return $local:result


}


[scriptblock]$CONFIGURATION_DISCOVERY = {
  param(
    [System.Management.Automation.PSReference]$object_ref,
    [System.Management.Automation.PSReference]$result_ref)
  $data = @()
  # $debug =  $true
  if ($debug) {
    Write-Host $object_ref.Value
    Write-Host $object_ref.Value.connectionStrings
    Write-Host $object_ref.Value.connectionStrings.add
  }
  $nodes = $object_ref.Value.connectionStrings.add
  if ($debug) {
    Write-Host $nodes.count
  }
  for ($cnt = 0; $cnt -ne $nodes.count; $cnt++) {
    # $data += $object_ref.Value.connectionStrings.add[$cnt].connectionString
    # extract and  keep the data source  throw away the rest
    $result2 = @{}
    $connection_string = $object_ref.Value.connectionStrings.add[$cnt].connectionString
    [void](match_data_source -connection_string $connection_string -result_ref ([ref]$result2))
    # write-host $result2

    if ($result2.database -ne $null) {

      $data += $result2.database
      if ($debug) {
        Write-Host $result2.database
      }
    }

  }
  if ($debug) {
    Write-Host 'Data:'
    Write-Host $data
  }
  $result_ref.Value = $data
}


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
  'Staging' = @{
    'COMMENT' = 'Staging Web Servers ConnectionStrings.config';
    'DOMAIN' = 'CARNIVAL';
    'UNC_PATHS' = @(
      '\\cclprdecostg1.carnival.com\e$\SitecoreCMS\Carnival\Website\App_Config\ConnectionStrings.config',
      '\\cclprdecostg1.carnival.com\e$\Projects\prod.carnival.com\Carnival\App_Config\ConnectionStrings.config',
      $null
    );
  };

  'HQ_UK' = @{
    'COMMENT' = 'DMZ HQ UK Web Servers ConnectionStrings.config';
    'DOMAIN' = 'CCLINTERNET';
    'LOGONSERVER' = 'CCLPRDDMZDC4';
    'PATH' = 'E:\Portals\CarnivalUK\Core\App_Config\ConnectionStrings.config';
    'SERVERS' =
    @(
      'CCLPRDECOWEB21.cclinternet.com',
      'CCLPRDECOWEB22.cclinternet.com',
      'CCLPRDECOWEB23.cclinternet.com',
      'CCLPRDECOWEB24.cclinternet.com',
      'CCLPRDECOWEB25.cclinternet.com',
      'CCLPRDECOWEB26.cclinternet.com',
      'CCLPRDECOWEB27.cclinternet.com',
      'CCLPRDECOWEB28.cclinternet.com',
      'CCLPRDECOWEB29.cclinternet.com',
      'CCLPRDECOWEB30.cclinternet.com',
      'CCLPRDECOWEB31.cclinternet.com',
      $null
    );
  };
  'HQ' = @{
    'COMMENT' = 'DMZ HQ Web Servers ConnectionStrings.config';
    'DOMAIN' = 'CCLINTERNET';
    'LOGONSERVER' = 'CCLPRDDMZDC4';
    'PATH' = 'E:\Projects\prod.carnival.com\Carnival\App_Config\ConnectionStrings.config';
    'SERVERS' =
    @(
      'CCLPRDECOWEB21.cclinternet.com',
      'CCLPRDECOWEB22.cclinternet.com',
      'CCLPRDECOWEB23.cclinternet.com',
      'CCLPRDECOWEB24.cclinternet.com',
      'CCLPRDECOWEB25.cclinternet.com',
      'CCLPRDECOWEB26.cclinternet.com',
      'CCLPRDECOWEB27.cclinternet.com',
      'CCLPRDECOWEB28.cclinternet.com',
      'CCLPRDECOWEB29.cclinternet.com',
      'CCLPRDECOWEB30.cclinternet.com',
      'CCLPRDECOWEB31.cclinternet.com',
      $null
    );
  };

  'BCP_UK' = @{
    'COMMENT' = 'DMZ HQ UK Web Servers ConnectionStrings.config';
    'DOMAIN' = 'CCLINTERNET';
    'LOGONSERVER' = '\\CCLBCPDMZINFDC2';
    'PATH' = 'E:\Portals\CarnivalUK\Core\App_Config\ConnectionStrings.config';
    'SERVERS' =
    @(
      'CCLBCPECOWEB21.cclinternet.com',
      'CCLBCPECOWEB22.cclinternet.com',
      'CCLBCPECOWEB23.cclinternet.com',
      'CCLBCPECOWEB24.cclinternet.com',
      'CCLBCPECOWEB25.cclinternet.com',
      'CCLBCPECOWEB26.cclinternet.com',
      'CCLBCPECOWEB27.cclinternet.com',
      'CCLBCPECOWEB28.cclinternet.com',
      'CCLBCPECOWEB29.cclinternet.com',
      'CCLBCPECOWEB30.cclinternet.com',

      $null
    );
  };

  'BCP' = @{
    'COMMENT' = 'DMZ BCP Web Servers ConnectionStrings.config';
    'DOMAIN' = 'CCLINTERNET';
    'LOGONSERVER' = '\\CCLBCPDMZINFDC2';
    'PATH' = 'E:\Projects\prod.carnival.com\Carnival\App_Config\ConnectionStrings.config';
    'SERVERS' =
    @(
      'CCLBCPECOWEB21.cclinternet.com',
      'CCLBCPECOWEB22.cclinternet.com',
      'CCLBCPECOWEB23.cclinternet.com',
      'CCLBCPECOWEB24.cclinternet.com',
      'CCLBCPECOWEB25.cclinternet.com',
      'CCLBCPECOWEB26.cclinternet.com',
      'CCLBCPECOWEB27.cclinternet.com',
      'CCLBCPECOWEB28.cclinternet.com',
      'CCLBCPECOWEB29.cclinternet.com',
      'CCLBCPECOWEB30.cclinternet.com',

      $null
    );
  };


};


foreach ($role in $configuration_paths.Keys) {
  $configuration = $configuration_paths.Item($role)
  Write-Output ('Starting {0}' -f $configuration['COMMENT'])
  # check if we can skip unreachable domain results , 
  # by returning the status from collect_config_data
  # for simplicity skip if not current domain  
  if (($configuration['DOMAIN'] -eq $domain ) -and ( ($configuration['LOGONSERVER']  -eq $null ) -or ($env:LOGONSERVER  -match  $configuration['LOGONSERVER'] ) )) {
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
         -powerless $true `
         -script_block $script_block
      # $configuration_results | format-list 
      # $configuration_results.Keys 
    }

    $configuration['RESULTS'] = $configuration_results
    # in this  scope it is better con collapse the results - nesting is too deep
    # don't care that many settings are redundant: about to offer interactive 
    # Print the miss(es) to console 
    assert_config_data -object_ref ([ref]$configuration_results)
  }
}

