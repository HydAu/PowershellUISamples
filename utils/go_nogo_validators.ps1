param(
  [Parameter(Position = 0)]
  [string]$environment

)

function convert_to_unc2 {
  param(
    [string]$mixed_path
  )
  $unc_file_path = $mixed_path -replace ':','$'
  return $unc_file_path
}




#######
function assert_config_data {
  param(
    [ValidateNotNull()]
    [string]$target_domain,
    [string]$target_unc_path,
    [scriptblock]$script_block,
    [bool]$powerless,
    [bool]$debug

  )

  if (($target_domain -eq $null) -or ($target_domain -eq '')) {
    Write-Output 'unspecified DOMAIN'
    if ($powerless) {
      return
    } else {
      throw
    }
  }
  if (-not ($target_domain -match $env:USERDOMAIN)) {
    # mock up can be passed the domain. 
    Write-Output 'Unreachable DOMAIN'
    # real run swill about
    if ($powerless) {
      return
    } else {
      throw
    }
  }

  Write-Output ('Probing {0}' -f $target_unc_path)
  [xml]$xml_config = Get-Content -Path $target_unc_path
  $object_ref = ([ref]$xml_config)
  $result = ''
  $result_ref = ([ref]$result)

  Invoke-Command $script_block -ArgumentList $object_ref,$result_ref

  Write-Host ('result = {0} ' -f $result)
  # B {Write-Host 2; &$block}.GetNewClosure()
}
<#
# 2.	On the webservers (web21, ... web31) should point to NON _parallel databases
[xml]$xml_config = Get-Content -Path '\\cclprdecoweb21\e$\Projects\prod.carnival.com\Carnival\App_Config\ConnectionStrings.config'
$xml_config.connectionStrings.add.connectionString | Format-Table -AutoSize

# 1.	Look at connection strings config file on cclprdecocms1, cms2, cms3.
# proceed or skip based on domain
#>


$configuration_paths = @{
  'Sitecore' =
  @{
    'COMMENT' = 'Sitecore Authoring Servers';
    'PATH' = 'E:\SitecoreCMS\Carnival\Website\App_Config\ConnectionStrings.config';
    'DOMAIN' = 'CARNIVAL';
    'SERVERS' = @(
      'cclprdecocms1.carnival.com',
      'cclprdecocms2.carnival.com',
      'cclprdecocms3.carnival.com',
      $null
    );
  };

  'Staging' = @{
    'COMMENT' = 'staging Web Servers';
    'DOMAIN' = 'CARNIVAL';
    'UNC_PATHS' = @(
      '\\cclprdecostg1.carnival.com\e$\SitecoreCMS\Carnival\Website\App_Config\ConnectionStrings.config',
      '\\cclprdecostg1.carnival.com\e$\Projects\prod.carnival.com\Carnival\App_Config\ConnectionStrings.config',
      $null
    );
  };
  'Web' = @{
    'COMMENT' = 'DMZ Web Servers';
    'DOMAIN' = 'CCLINTERNET';
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
};


$configuration_paths.GetType()
foreach ($role in $configuration_paths.Keys) {
  $configuration = $configuration_paths.Item($role)
  Write-Output ('Starting {0}' -f $configuration['COMMENT'])
  if ($configuration.Containskey('SERVERS')) {

    $servers = $configuration['SERVERS']
    $unc_paths = @()
    $servers | ForEach-Object { $server = $_; if ($server -eq $null) { return } $unc_paths += convert_to_unc2 (('\\{0}\{1}' -f $server,$configuration['PATH'])) }
  }
  elseif ($configuration.Containskey('UNC_PATHS')) {
    $unc_paths = $configuration['UNC_PATHS']

  }
  Write-Output $configuration['DOMAIN']
  [scriptblock]$script_block = {
    param(
      [System.Management.Automation.PSReference]$object_ref,
      [System.Management.Automation.PSReference]$result_ref)
    $data = @()
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
      $data += $object_ref.Value.connectionStrings.add[$cnt].connectionString
    }
    if ($debug) {
    Write-Host 'Data:'
    Write-Host $data
}
    $result_ref.Value = $data
  }

  $unc_paths | ForEach-Object { $target_unc_path = $_; if ($target_unc_path -eq $null) { return } assert_config_data -target_domain $configuration['DOMAIN'] -target_unc_path $target_unc_path -powerless $true  -script_block $script_block}

}
