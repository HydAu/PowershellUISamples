param(
  [Parameter(Position = 0)]
  [string]$environment

)

function squash_json {
  param(
    [Parameter(Position = 0)]
    [object]$results,
    [string]$filename

  )

  $row_data = @()
  # temporary solutuon 
  $results.Keys | ForEach-Object { $k = $_

    $hosts_array = @()

    $v = $results[$k]['hosts']
    $v.Keys | ForEach-Object {

      $k2 = $_
      if ($k2 -ne $null) {
        $hosts_array += ('{0}|{1}' -f $k2,$v[$k2])
      }
    }

    $col_data = @{
      'name' = $k;

      'hosts' = $hosts_array
      'addresses' = $results[$k]['addresses'];
    }

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

      'hosts' = $hosts_array;
      'IIS_INFORMATION' = $additional_data_array;
      'addresses' = $results[$k]['addresses'];
    }

    $row_data += $col_data
  }

  $raw_rowset_data = ConvertTo-Json -InputObject $row_data
  Out-File -FilePath $filename -Encoding ASCII -InputObject $raw_rowset_data
}

function get_remote_nic_data {
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
  $command_outputs = Invoke-Command -computer $remotecomputer -ScriptBlock ${function:get_nic_data}
  $data_ref.Value = $addresses;

  $data_ref.Value = $command_outputs
}

function get_nic_data {
  $addresses = @()
  $command_output = Invoke-Expression -Command 'C:\Windows\System32\ipconfig.exe'
  $nic_addresses_found = @{}
  if ($command_output -ne $null) {
    ($command_output -split "`n") | ForEach-Object {
      $line = $_
      if ($line -match 'IPv4 Address') {
        if ($DebugPreference -eq 'Continue') {
          Write-Host -ForegroundColor 'yellow' Write-Host $line
        }
        if ($line -match ":\s*(\d+\.\d+\.\d+\.\d+)\s*$") {
          $ipaddress = $matches[1]
          if ($DebugPreference -eq 'Continue') {

            Write-Host -ForegroundColor 'yellow' ("--> {0} " -f $ipaddress)
          }
          $addresses += $ipaddress
        }
      }

    }
  }
  return $addresses
}



function get_hosts_data {
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

  $has_data = $true
  # note the order is opposite to what is written in hosts file
  $hostnames_known = @{

    'cclsecman3.carnival.com' = $null;
  }


  $server_data = @"

  au.carnival.com  
  cclsecman3.carnival.com  
  ddapi.carnival.com  
  dms.carnival.com  
  erswebservice.carnival.com  
  erswebservicevip.carnival.com  
  funville.carnival.com  
  gsa1.carnival.com  
  m.carnival.com  
  mobile.carnival.com  
  notif.carnival.com  
  origin-www.carnival.com  
  prdbookapp.carnival.com  
  prodadmin.carnival.com  
  prodsearch.carnival.com  
  search.carnival.com  
  secure.carnival.com  
  services.carnival.com  
  sitecore.carnival.com
  gocclsitecore.carnival.com
  sitecore-au.carnival.com
  static.carnivalcloud.com  
  www.carnival.co.uk  
  www.carnival.com  
  www.carnival.com.au  
  www.carnivalentertainment.com  
  www.goccl.com
  www.goccl.co.uk  
  www2.carnival.com.au  


  admin1.syscarnival.com  
  admin2.syscarnival.com  
  admin3.syscarnival.com  
  admin4.syscarnival.com  
  admin5.syscarnival.com  
  au1.syscarnival.com  
  au2.syscarnival.com  
  au3.syscarnival.com  
  au4.syscarnival.com  
  au5.syscarnival.com  
  bookccl1.syscarnival.com  
  bookeng1.syscarnival.com  
  bookeng2.syscarnival.com  
  bookeng3.syscarnival.com  
  bookeng4.syscarnival.com  
  bookeng5.syscarnival.com  
  cms-au4.syscarnival.com  
  ddapi2.syscarnival.com  
  ddapi3.syscarnival.com  
  funhub1.syscarnival.com  
  funpass1.syscarnival.com  
  funpass2.syscarnival.com  
  funpass3.syscarnival.com  
  funpass4.syscarnival.com  
  funpass4.syscarnival.com  
  funpass5.syscarnival.com  
  gmp2.syscarnival.com  
  goccl1.syscarnival.com  
  goccl2.syscarnival.com  
  goccl3.syscarnival.com  
  goccl4.syscarnival.com  
  goccl5.syscarnival.com  
  GoCCLSitecore1.syscarnival.com  
  gocclsitecore2-staging.syscarnival.com  
  GoCCLSitecore2.syscarnival.com  
  gocclsitecore3-staging.syscarnival.com  
  GoCCLSitecore3.syscarnival.com  
  GoCCLSitecore4.syscarnival.com  
  GoCCLSitecore5.syscarnival.com  
  goccluk1.syscarnival.com  
  goccluk2.syscarnival.com  
  goccluk3.syscarnival.com  
  goccluk4.syscarnival.com  
  goccluk5.syscarnival.com  
  images.syscarnival.com  
  integration3.syscarnival.com  
  m1.syscarnival.com  
  m2.syscarnival.com  
  m2staging.syscarnival.com  
  m3.syscarnival.com  
  m4.syscarnival.com  
  m5.syscarnival.com  
  mydocuments2.syscarnival.com  
  sc1.syscarnival.com  
  secure1.syscarnival.com  
  secure2.syscarnival.com  
  secure3.syscarnival.com  
  secure4.syscarnival.com  
  secure5.syscarnival.com  
  secureuk1.syscarnival.com  
  secureuk2.syscarnival.com  
  secureuk3.syscarnival.com  
  secureuk4.syscarnival.com  
  secureuk5.syscarnival.com  
  services1.syscarnival.com  
  services2.syscarnival.com  
  services3.syscarnival.com  
  services4.syscarnival.com  
  services5.syscarnival.com  

  servicesuk1.syscarnival.com  
  servicesuk2.syscarnival.com  
  servicesuk3.syscarnival.com  
  servicesuk4.syscarnival.com  
  servicesuk5.syscarnival.com  
  sitecore1.syscarnival.com  
  sitecore2-staging.syscarnival.com  
  sitecore2.syscarnival.com  
  sitecore3.syscarnival.com  

  sitecore4.syscarnival.com  
  sitecore5.syscarnival.com  

 sitecore1.uatcarnival.com
 sitecore2.uatcarnival.com
 sitecore3.uatcarnival.com
 sitecore4.uatcarnival.com
 sitecore5.uatcarnival.com

 sitecoregoccl2.uatcarnival.com
 sitecoregoccl1.uatcarnival.com
 sitecoregoccl3.uatcarnival.com
 sitecoregoccl4.uatcarnival.com
 sitecoregoccl5.uatcarnival.com


  static1.syscarnivalcloud.com  
  stg2.syscarnival.com  
  syscarnivalcloud.com  
  sysp.princess.com  
  uk1.syscarnival.com  
  uk2.syscarnival.com  
  uk3.syscarnival.com  
  uk4.syscarnival.com  
  uk5.syscarnival.com  

  www1.syscarnival.com  
  www1.syscarnivalcloud.com  
  www2.syscarnival.com  
  www3.syscarnival.com  
  www4.syscarnival.com  
  www5.syscarnival.com  

  sitecoreau-staging.carnival.com
  gocclpv.carnival.com
  gmp.carnival.com 
  dmz-smtp.carnival.com
  stager.carnival.com

  admin1.uatcarnival.com  
  admin2.uatcarnival.com  
  admin3.uatcarnival.com  
  admin4.uatcarnival.com  
  admin5.uatcarnival.com  

  au.uatcarnival.com  
  bookeng1.uatcarnival.com  
  bookeng2.uatcarnival.com  
  bookeng3.uatcarnival.com  
  bookeng4.uatcarnival.com  
  bookeng5.uatcarnival.com  

  ccluatwmapi2.carnival.com  
  ddapi1.uatcarnival.com  
  ddapi4.uatcarnival.com  
  dms4.uatcarnival.com  
  gmp4.uatcarnival.com  
  goccl1.uatcarnival.com  
  goccl2.uatcarnival.com  
  goccl3.uatcarnival.com  
  goccl4.uatcarnival.com  
  goccl5.uatcarnival.com  

  gocclpv4.uatcarnival.com  
  gocclsitecore1-staging.uatcarnival.com  
  gocclsitecore2-staging.uatcarnival.com  
  gocclsitecore3-staging.uatcarnival.com  
  gocclsitecore4-staging.uatcarnival.com  
  goccluk1.uatcarnival.com  
  goccluk2.uatcarnival.com  
  goccluk3.uatcarnival.com  
  goccluk4.uatcarnival.com  
  goccluk5.uatcarnival.com  

  m4.uatcarnival.com  
  m4staging.uatcarnival.com  
  notif1.uatcarnival.com  
  notif2.uatcarnival.com  
  notif3.uatcarnival.com  
  notif4.uatcarnival.com  
  notif5.uatcarnival.com  

  pastguest1.uatcarnival.com  
  pastguest2.uatcarnival.com  
  pastguest3.uatcarnival.com  
  pastguest4.uatcarnival.com  
  secure1.uatcarnival.com  
  secure2.uatcarnival.com 
  secure3.uatcarnival.com 
  secure4.uatcarnival.com  
  secure5.uatcarnival.com  

  secureuk1.uatcarnival.com 
  secureuk1.uatcarnival.com  
  secureuk2.uatcarnival.com  
  secureuk3.uatcarnival.com  
  secureuk4.uatcarnival.com  
  secureuk5.uatcarnival.com  

  sitecore1-staging.uatcarnival.com  
  sitecore3-staging.uatcarnival.com  
  sitecore4-staging.uatcarnival.com  
  sitecore5-staging.uatcarnival.com  

  uk1.uatcarnival.com  
  uk4-staging.uatcarnival.com  
  whatsup4.uatcarnival.com  
  www1.uatcarnival.com  
  www2.uatcarnival.com  
  www4.uatcarnival.com  
  www3.uatcarnival.com  
  www5.uatcarnival.com  
  www4.uatcarnival.com  


"@

  $server_data -split "`r?`n" | ForEach-Object {
    $raw = $_
    $final = $raw -replace "\s",""
    if (-not $final) {
      return
    }
    if (-not $hostnames_known.ContainsKey($final)) {
      $hostnames_known.Add($final,$null)
    }
  }

  $hostname_keys = @()
  $hostnames_found = @{}

  $hostname_keys = @()
  $hostnames_found = @{}
  # subset  
  $hostnames_known.Keys | ForEach-Object { $hostname_keys += $_ }

  $current_file_content = ''
  try {
    $current_file_content = Get-Content -Path "\\${remotecomputer}\c$\Windows\system32\drivers\etc\hosts"
  } catch [exception]{
    $has_data = $false
    Write-Host $_.Exception.GetType().FullName;
    Write-Host $_.Exception.Message;
  }
  if ($has_data) {
    ($current_file_content -split "`n") | ForEach-Object {
      $line = $_
      $keep = $true
      $hostname_keys | ForEach-Object {
        $host_name = $_;

        if ($line -match $host_name) {
          if ($DebugPreference -eq 'Continue') {
            Write-Host -ForegroundColor 'yellow' ("Collecting {0}" -f $line)
          }
          # capture 
          if ($line -match "^\s*(\d+\.\d+\.\d+\.\d+)\s+${host_name}\s*$") {
            $ip_address = $matches[1]
            if ($DebugPreference -eq 'Continue') {
              Write-Host -ForegroundColor 'Gray' ("Match: '{0}'" -f $ip_address)
            }
            $hostnames_found[$host_name] = $ip_address
          }
        }
      }

    }

  }

  $data_ref.Value = $hostnames_found

}

<# $disk = Get-WmiObject Win32_LogicalDisk -ComputerName remotecomputer -Filter "DeviceID='C:'" |
Select-Object Size,FreeSpace

$disk.Size
$disk.FreeSpace

#>

# need to be embedded in the caller function which itsels is called  remotely 
function extract_bound_ip_address {
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

function get_remote_appcmd_data {
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

  $command_outputs = Invoke-Command -computer $remotecomputer -ScriptBlock ${function:get_appcmd_data}

  $data_ref.Value = $command_outputs
}

function get_appcmd_data {

  # need to be embedded in the caller function which itsels is called  remotely 
  function extract_bound_ip_address {
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


  $iis_bound_addresses = @{}
  $command_output = Invoke-Expression -Command 'C:\Windows\System32\inetsrv\appcmd.exe list site'
  $nic_addresses_found = @{}

  if ($command_output -ne $null) {
    ($command_output -split "`n") | ForEach-Object {
      $line = $_
      # $DebugPreference = 'Continue'
      if ($line -match 'SITE\s+"(\w+)"\s+\((.+)\)$') {
        $site_alias = $matches[1]
        $site_configuration = $matches[2]
        $site_bound_ip_address = extract_bound_ip_address -Line $line

        $iis_bound_addresses[$site_alias] = $site_bound_ip_address
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
      Write-Debug $node
      $local:hosts_data = @{}
      $local:data2 = @()
      $local:data3 = @()
      $hosts_data_ref = ([ref]$local:hosts_data)
      $data2_ref = ([ref]$local:data2)
      $data3_ref = ([ref]$local:data3)
      get_hosts_data -remotecomputer $node -data_ref $hosts_data_ref
      get_remote_nic_data -remotecomputer $node -data_ref $data2_ref

      get_remote_appcmd_data -remotecomputer $node -data_ref $data3_ref
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

      ($_ -match $caller_ref.Value[$key]['PATTERN']) -and ($_ -match $caller_ref.Value[$key]['DOMAIN'])
    }
    $data[$key] += $servers
  }


  $result_ref.Value = $data[$key]
}

$ENVIRONMENTS_CUSTOM = @{
  'UAT1' = @{
    'SCRIPT' = $EXAMPLE;
    'PATTERN'= 'n1\';
    'DOMAIN' = 'CARNIVAL';
    'LOGONSERVER' = 'CCLPRDDMZDC4';
  }
};
$ENVIRONMENTS_STRUCTURED = @{

  'PROD_HQ' = @{
    'COMMENT' = 'PROD HQ Web Servers';
    'DOMAIN' = 'CCLINTERNET';
    'LOGONSERVER' = 'CCLPRDDMZDC4';
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
    'LOGONSERVER' = 'CCLBCPDMZINFDC2';
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
  'UAT_INSIDE' = @{
    'COMMENT' = 'Staging Servers';
    'DOMAIN' = 'CARNIVAL';
    'SERVERS' =
    @(
    );
  };
  'UAT_DMZ' = @{
    'COMMENT' = 'UAT DMZ Web Servers';
    'DOMAIN' = 'CCLINTERNET';
    'LOGONSERVER' = 'CCLPRDDMZDC4';
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
      'ccluatecoweb2n5.cclinternet.com',
      'ccluatcache1n5.cclinternet.com'
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
      'ccltstecoweb1n6.carnival.com'
      #   , 
      #    'ccltstecoweb2n6.carnival.com'
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

  # TODO - reenable
  $DebugPreference = 'Continue';
  Write-Debug $scope
  $results = collect_inventory $environments[$scope]
  squash_json -results $results -FileName ('{0}.json' -f $role)
  $row_data = @()
}
# Out-File -FilePath 'result2.json' -Encoding ASCII -InputObject $raw_rowset_data
# 
return

