param(
  [Parameter(Position = 0)]
  [string]$environment

)

function host_wmi_ping
{

  param(
    [string]$target_host = 'ccltstecoweb2n6.carnival.com',
    [bool]$debug
  )

  [bool]$status = $false
  [int]$timeout = 3000
  $filter = ("Address = '{0}' and Timeout = {1}" -f $target_host,$timeout)
  try {
    $result = Get-WmiObject -Class 'Win32_PingStatus' -Amended -DirectRead -Filter "${filter}" | Where-Object { $_.ResponseTime -ne $null }
  }
  catch [exception]{
    Write-Debug $_.Exception.Message

  }
  if ($result -ne $null) {
    $status = $true;

  }
  return $status
}


function squash_json {
  param(
    [Parameter(Position = 0)]
    [object]$results,
    [string]$filename

  )

  $row_data = @()
  # temporary solutuon 
  $results.Keys | ForEach-Object { $k = $_

    $additional_data_array = @()

    $v = $results[$k]['additional_data']


    $v.Keys | ForEach-Object {

      $k2 = $_
      if ($k2 -ne $null) {
        $additional_data_array += ('{0}|{1}' -f $k2,$v[$k2])
      }
    }

    $col_data = @{
      'name' = $k;
      'IIS_INFORMATION' = $additional_data_array;
     }

    $row_data += $col_data
  }

  $raw_rowset_data = ConvertTo-Json -InputObject $row_data
  Out-File -FilePath $filename -Encoding ASCII -InputObject $raw_rowset_data
}

# need to be embedded in the caller function which itsels is called  remotely 
function extract_site_internal_order {
  param([string]$line)

  $res = @()
  $ip_addresses_bound = @{}
  $site_alias = $null
  $site_configuration = $null
  if ($line -match 'SITE\s+"(\w+)"\s+\((.+)\)$') {

    $site_alias = $matches[1]
    $site_configuration = $matches[2]
    if ($DebugPreference -eq 'Continue') {
      Write-Host -ForegroundColor 'yellow' ('site configuration: {0}' -f $site_configuration)
    }
  }

  if ($site_configuration) {
    # somewhat poorly formatted. 
    # note the incoherent usage of colons and commas.,
    # id:6,bindings:http/10.244.160.64:80:,https/10.244.160.64:443:,state:Started

    if ($site_configuration -match 'bindings:(.+),state:') {

      $bound_to_ipaddress = $matches[1]
      if ($DebugPreference -eq 'Continue') {
        Write-Host -ForegroundColor 'yellow' ("bound_to_ipaddresses: {0} " -f $bound_to_ipaddress)

      }

      $items = $bound_to_ipaddress -split ','
      # note non-standard format  
      $items | ForEach-Object { $entry = $_
        if ($entry -match 'https?/([\d.]+):') {
          $res += $matches[1]

        }

      }
      if ($DebugPreference -eq 'Continue') {
        Write-Host -ForegroundColor 'yellow' $res

      }
    }
  }

  $res | ForEach-Object { $k = $_; if (-not $ip_addresses_bound.ContainsKey($k)) { $ip_addresses_bound.Add($k,$null) } }
  return $ip_addresses_bound.Keys

}

function get_remote_appcmd_order {
  param(
    [Parameter(Position = 0)]
    [string]$remotecomputer,
    [System.Management.Automation.PSReference]$data_ref
  )
  if (($remotecomputer -eq $null) -or ($remotecomputer -eq '')) {
    return
  }
  if (-not ($remotecomputer -match $env:USERDOMAIN)) {
    return
  }

  Write-Debug $remotecomputer
  $addresses = @()

  $command_outputs = Invoke-Command -computer $remotecomputer -ScriptBlock ${function:get_appcmd_order}

  $data_ref.Value = $command_outputs
}

function get_appcmd_order {

  # need to be embedded in the caller function which itsels is called  remotely 
  function extract_site_internal_order {
    param([string]$line)

    $res = @()
    $ip_addresses_bound = @{}
    $site_alias = $null
    $site_configuration = $null
    if ($line -match 'SITE\s+"(\w+)"\s+\((.+)\)$') { 
 
        #  e.g. 
        # SITE "Carnival"  (id:2,bindings:http/10.246.144.101:80:,https/10.246.144.101:443:,http/10.246.144.101:80:www.carnival.com,state:Started)

      $site_alias = $matches[1]
      $site_configuration = $matches[2]
      if ($DebugPreference -eq 'Continue') {
        Write-Host -ForegroundColor 'yellow' ('site configuration: {0}' -f $site_configuration)
      }
    }

    if ($site_configuration) {
      # somewhat poorly formatted. 
      # note the incoherent usage of colons and commas.,
      # id:6,bindings:http/10.244.160.64:80:,https/10.244.160.64:443:,state:Started

      if ($site_configuration -match 'id:([0-9]+),') {

        $site_id = $matches[1]
        if ($DebugPreference -eq 'Continue') {
          Write-Host -ForegroundColor 'yellow' ("Site ID: {0}" -f $site_id)

        }

      }

    }

    return $site_id

  }


  $iis_bound_addresses = @{}
  $command_output = Invoke-Expression -Command 'C:\Windows\System32\inetsrv\appcmd.exe list site'
  $nic_addresses_found = @{}
  if ($command_output -ne $null) {
    ($command_output -split "`n") | ForEach-Object {
      $line = $_
      $continue_flag = $false
      Write-Host ('Inspecting {0}' -f $line)
      # $DebugPreference = 'Continue'
      # possible result :
      # SITE "SITE_5" (id:5,bindings:,state:Unknown)
      # Stopped sites are OK  
      #   if ($line -match 'state:(?:Unknown|Stopped)') {

      if (($line -match 'state:Unknown') -or ($line -match 'Default Web Site')) {
        Write-Host ('About to Skip {0}' -f $line)
        $continue_flag = $true
        # TODO: debug
        # continue
      }

      if (-not $continue_flag) {
        if ($line -match 'SITE\s+"(\w+)"\s+\((.+)\)$') {
          Write-Host 'Extract Site ID information'
          $site_alias = $matches[1]
          $site_configuration = $matches[2]
          $site_bound_ip_address = extract_site_internal_order -Line $line

          $iis_bound_addresses[$site_alias] = $site_bound_ip_address
        }
      }
    }
  }
  return $iis_bound_addresses
}


function collect_inventory {
  param(
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
    #    [ValidateNotNull()]
    [string[]]$computerName
  )


  process {

    $local:result = @{
    }

    foreach ($node in $ComputerName) {
      if (-not $node) {
        continue
      }

      $ping_status_res = host_wmi_ping -target_host $node
      if (-not $ping_status_res) {
        continue
      }


      Write-Debug $node
      $local:hosts_data = @{}
      $local:data2 = @()
      $local:data3 = @()
      $data3_ref = ([ref]$local:data3)
      get_remote_appcmd_order -remotecomputer $node -data_ref $data3_ref
      # flatten the data
      <#

   {
   "value":  "172.26.216.70",
   "PSComputerName":  "ccluatecoadm1n4.carnival.com",
   "RunspaceId":  "868b942b-ab4f-40b3-b1cb-b71c35a0704f",                                                               
   "PSShowComputerName":  true
 },
                                                           },
#>
      $addresses = @()
      $data2 | ForEach-Object {
        $data2_row = $_;
        Write-Host -ForegroundColor 'green' $data2_row
        $addresses += ("{0}" -f $data2_row)
      }


      $local:result[$node] = @{ 'hosts' = $local:hosts_data;
        'addresses' = $addresses;
        'additional_data' = $data3;
      }
    }

    return $local:result
  }

}

<#
TODO - filter by FQDN in the runner 
#>


# custom_environment =
# label => code block 
[scriptblock]$EXAMPLE = {
  param(
    [System.Management.Automation.PSReference]$object_ref,
    [System.Management.Automation.PSReference]$result_ref,
    [System.Management.Automation.PSReference]$caller_ref,
    [string]$key = $null
  )


  $data = @{}
  $debug = $false
  if ($DebugPreference -eq 'Continue') {
    $debug = $true
  }

  if ($debug) {
    Write-Host 'Object keys'
    Write-Host $object_ref.Value.Keys
    Write-Host 'Caller  keys'
    $caller_ref.Value[$key].Keys

  }

  $nodes = $object_ref.Value.Keys
  $data = @{ $key = @(); }
  $nodes | ForEach-Object {
    $k = $_
    $servers = $object_ref.Value[$k]['SERVERS'] | Where-Object {
      ($_ -match $caller_ref.Value[$key]['EXPRESSION']) -and ($_ -match $caller_ref.Value[$key]['DOMAIN'])
    }
    $data[$key] += $servers
  }


  $result_ref.Value = $data[$key]
}

$ENVIRONMENTS_CUSTOM = @{
  'UAT1' = @{
    'SCRIPT' = $EXAMPLE;
    'EXPRESSION' = '^ccluat.*n1\.';
    'DOMAIN' = '(?:CARNIVAL|CCLINTERNET)';
  };
  'UAT2' = @{
    'SCRIPT' = $EXAMPLE;
    'EXPRESSION' = '^ccluat.*n2\.';
    'DOMAIN' = '(?:CARNIVAL|CCLINTERNET)';
  };
  'UAT3' = @{
    'SCRIPT' = $EXAMPLE;
    'EXPRESSION' = '^ccluat.*n3\.';
    'DOMAIN' = '(?:CARNIVAL|CCLINTERNET)';
  };
  'UAT4' = @{
    'SCRIPT' = $EXAMPLE;
    'EXPRESSION' = '^ccluat.*n4\.';
    'DOMAIN' = '(?:CARNIVAL|CCLINTERNET)';
  };
  'UAT5' = @{
    'SCRIPT' = $EXAMPLE;
    'EXPRESSION' = '^ccluat.*n5\.';
    'DOMAIN' = '(?:CARNIVAL|CCLINTERNET)';
  };


  'SYS1' = @{
    'SCRIPT' = $EXAMPLE;
    'EXPRESSION' = '^ccltst.*n1\.';
    'DOMAIN' = 'CARNIVAL';
  };
  'SYS2' = @{
    'SCRIPT' = $EXAMPLE;
    'EXPRESSION' = '^ccltst.*n2\.';
    'DOMAIN' = 'CARNIVAL';
  };
  'SYS3' = @{
    'SCRIPT' = $EXAMPLE;
    'EXPRESSION' = '^ccltst.*n3\.';
    'DOMAIN' = 'CARNIVAL';
  };
  'SYS4' = @{
    'SCRIPT' = $EXAMPLE;
    'EXPRESSION' = '^ccltst.*n4\.';
    'DOMAIN' = 'CARNIVAL';
  };
  'SYS5' = @{
    'SCRIPT' = $EXAMPLE;
    'EXPRESSION' = '^ccltst.*n5\.';
    'DOMAIN' = 'CARNIVAL';
  };
  'SYS6' = @{
    'SCRIPT' = $EXAMPLE;
    'EXPRESSION' = '^ccltst.*n6\.';
    'DOMAIN' = 'CARNIVAL';
  };

};

$ENVIRONMENTS_STRUCTURED = @{

  'PROD_HQ' = @{
    'COMMENT' = 'PROD HQ Web Servers';
    'DOMAIN' = 'CCLINTERNET';
    'LOGONSERVER' = '(?:CCLPRDDMZDC4|CCLPRDDMZDC3)';
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

      'CCLPRDECOBOOK1.cclinternet.com',
      'CCLPRDECOBOOK2.cclinternet.com',
      'CCLPRDECOBOOK3.cclinternet.com',
      'cclprdecocds1.cclinternet.com',
      'cclprdecocds2.cclinternet.com',
      'cclprdecodms1.cclinternet.com',
      'cclprdecodms3.cclinternet.com',
      'cclprdecodms2.cclinternet.com',
      'cclprdecofvl1.cclinternet.com',
      'cclprdecofvl2.cclinternet.com'
    );
  };


  'PROD_BCP' = @{
    'COMMENT' = 'Production BCP Servers';
    'DOMAIN' = 'CCLINTERNET';
    # same to indicate the format
    'LOGONSERVER' = '(?:CCLBCPDMZINFDC2|CCLBCPDMZINFDC2)';
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
      'CCLBCPECOBOOK1.cclinternet.com',
      'CCLBCPECOBOOK2.cclinternet.com',
      'CCLBCPECOBOOK3.cclinternet.com',
      "cclbcpecofvl1.cclinternet.com",
      "cclbcpecofvl2.cclinternet.com"

    );
  };
  'UAT_DMZ' = @{
    'COMMENT' = 'UAT DMZ Web Servers';
    'DOMAIN' = 'CCLINTERNET';
    'LOGONSERVER' = 'CCLPRDDMZDC2';
    'SERVERS' =
    @(
      'ccluatecoweb1n1.cclinternet.com',
      'ccluatecoweb2n1.cclinternet.com',
      'ccluatecoweb3n1.cclinternet.com',
      'ccluatecoweb4n1.cclinternet.com',
      'ccluatecoweb5n1.cclinternet.com',
      'ccluatecoweb1n2.cclinternet.com',
      'ccluatecoweb2n2.cclinternet.com',
      'ccluatecoweb3n2.cclinternet.com',
      'ccluatecoweb4n2.cclinternet.com',
      'ccluatecoweb5n2.cclinternet.com',
      'ccluatecoweb1n3.cclinternet.com',
      'ccluatecoweb2n3.cclinternet.com',
      'ccluatecoweb3n3.cclinternet.com',
      'ccluatecoweb4n3.cclinternet.com',
      'ccluatecoweb5n3.cclinternet.com',
      'ccluatecoweb1n4.cclinternet.com',
      'ccluatecoweb2n4.cclinternet.com',
      'ccluatecoweb3n4.cclinternet.com',
      'ccluatecoweb4n4.cclinternet.com',
      'ccluatecoweb5n4.cclinternet.com',
      'ccluatecobkg1n5.cclinternet.com',
      'ccluatecobkg2n5.cclinternet.com',
      'ccluatecoweb1n5.cclinternet.com',
      'ccluatecoweb2n5.cclinternet.com'
    );
  };
  'CMS' = @{
    'COMMENT' = 'CMS Servers';
    'DOMAIN' = 'CARNIVAL';
    'SERVERS' =
    @(
      'ccluatecocms1.carnival.com',
      'ccluatecocms2.carnival.com',
      'ccltstecocms1n1.carnival.com',
      'ccltstecocms2n1.carnival.com',
      'cclprdecocms1.carnival.com',
      'cclprdecocms2.carnival.com',
      'cclprdecocms3.carnival.com'
    );
  };

  'PRODPREVIEW' = @{
    'COMMENT' = 'Prod Preview Servers';
    'DOMAIN' = 'CARNIVAL';
    'SERVERS' =
    @(
      'cclprdecopv1.carnival.com'
    );
  };
  # TODO try ping. 
  # ccltstecoweb2n6.carnival.com
  'SYSTEST' = @{
    'COMMENT' = 'Staging Web Servers';
    'DOMAIN' = 'CARNIVAL';
    'SERVERS' =
    @(
      'ccltstecocms1n1.carnival.com',
      'ccltstecocms2n1.carnival.com',
      'ccltstecoadm1n1.carnival.com',
      'ccltstecostg1n1.carnival.com',
      'ccltstecoweb1n1.carnival.com',
      'ccltstecoweb2n1.carnival.com',
      'ccltstecoadm1n2.carnival.com',
      'ccltstecostg1n2.carnival.com',
      'ccltstecoweb1n2.carnival.com',
      'ccltstecoweb2n2.carnival.com',
      'ccltstecoadm1n3.carnival.com',
      'ccltstecostg1n3.carnival.com',
      'ccltstecoweb1n3.carnival.com',
      'ccltstecoweb2n3.carnival.com',
      'ccltstecoadm1n4.carnival.com',
      'ccltstecoapc1n4.carnival.com',
      'ccltstecoweb1n4.carnival.com',
      'ccltstecoweb2n4.carnival.com',
      'ccltstecoadm1n5.carnival.com',
      'ccltstecostg1n5.carnival.com',
      'ccltstecoweb1n5.carnival.com',
      'ccltstecoadm1n6.carnival.com',
      'ccltstecostg1n6.carnival.com',
      'ccltstecoweb1n6.carnival.com',
      'ccltstecoweb2n6.carnival.com'
    );
  };

  'UAT INSIDE' = @{
    'COMMENT' = 'UAT Servers';
    'DOMAIN' = 'CARNIVAL';
    'SERVERS' =
    @(
      'ccluatecoadm1n1.carnival.com',
      'ccluatecoadm2n1.carnival.com',
      'ccluatecostg1n1.carnival.com',
      'ccluatecoadm1n2.carnival.com',
      'ccluatecoadm2n2.carnival.com',
      'ccluatecostg1n2.carnival.com',
      'ccluatecoadm1n3.carnival.com',
      'ccluatecoadm2n3.carnival.com',
      'ccluatecostg1n3.carnival.com'
      'ccluatecoadm1n4.carnival.com',
      'ccluatecoadm2n4.carnival.com',
      'ccluatecoapc1n4.carnival.com',
      'ccluatecoadm1n5.carnival.com',
      'ccluatecoadm2n5.carnival.com',
      'ccluatecocms1n5.carnival.com',
      'ccluatecopv1n5.carnival.com',
      'ccluatecostg1n5.carnival.com'
      'ccluatecocms1.carnival.com',
      'ccluatecocms2.carnival.com'
    );
  };

  'STAGING' = @{
    'COMMENT' = 'Staging Web Servers';
    'DOMAIN' = 'CARNIVAL';
    'SERVERS' =
    @(
      'cclprdecostg1.carnival.com',
      'cclbcpecostg1.carnival.com'
    );
  };

}


$scope = $environment
if ($scope -eq '') {
  $scope = 'debug'
}
# CCLPRDECOWEB28.cclinternet.com
Write-Output $scope
if ($scope -eq '-') {
  Write-Output 'Processing all environment '
  foreach ($role in $ENVIRONMENTS_STRUCTURED.Keys) {
    Write-Host ('Probing {0}' -f $role)
    $configuration = $ENVIRONMENTS_STRUCTURED.Item($role)
    # skip unreachable domain results , 
    Write-Debug ('Logon Server "{0}"' -f $configuration['LOGONSERVER'])
    if (($configuration['DOMAIN'] -eq $env:USERDOMAIN) -and (($configuration['LOGONSERVER'] -eq $null) -or ($env:LOGONSERVER -match $configuration['LOGONSERVER']))) {
      Write-Output ('Starting {0}' -f $configuration['COMMENT'])
      if ($configuration.ContainsKey('SERVERS')) {
        $servers = $configuration['SERVERS']
        if ($servers.count -gt 0) {
          $configuration['RESULTS'] = collect_inventory $servers
          # $configuration['RESULTS'] | convertto-Json
          squash_json -results $configuration['RESULTS'] -FileName ('{0}.json' -f $role)
        }
      }
    }
  }
} else {

  $object_ref = ([ref]$ENVIRONMENTS_STRUCTURED)
  $caller_ref = ([ref]$ENVIRONMENTS_CUSTOM)
  $ENVIRONMENTS_CUSTOM.Keys | ForEach-Object {
    $role = $_

    ## TODO select 
    if ($scope -ne $null -and $scope -ne '' -and $role -ne $scope) {
     return 
    }

    # $v = $ENVIRONMENTS_CUSTOM[$role] 
    # todo nesting 
    [scriptblock]$s = $ENVIRONMENTS_CUSTOM[$role]['SCRIPT']
    if ($s -ne $null) {
      $local:result = $null
      $result_ref = ([ref]$local:result)
      Invoke-Command $s -ArgumentList $object_ref,$result_ref,$caller_ref,$role
      Write-Host ('{0}  = {1}' -f $role,$result_ref.Value)
      $result_ref.Value | Format-Table
    } else {
      Write-Host ('extract function not defined for {0}' -f $role)
      # TODO: throw
    }

    $nodes = $result_ref.Value

    # TODO - reenable
    $DebugPreference = 'Continue';
    Write-Debug $scope
    $results = collect_inventory $nodes
    squash_json -results $results -FileName ('{0}.json' -f $role)


  }
}
# Out-File -FilePath 'result2.json' -Encoding ASCII -InputObject $raw_rowset_data
# 
return

