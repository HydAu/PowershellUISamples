# Update certain elements within the web.config of prod-preview (web.config)
# \\cclprdecopv1\Projects\prod.carnival.com\Carnival\web.config 
# replacing carnival with preview URLs

param(
  [Parameter(Position = 0)]
  [switch]$prod,# UNUSED 
  [string]$domain = $env:USERDOMAIN
  # need $host.Version.major ~> 3
  # e.g. run from cclprdwebops1.carnival.com
)

$global:timestamp = (Get-Date).ToString("yy_MM_dd_HH_MM")

[bool]$to_prod = $false

if ($PSBoundParameters["prod"]) {
  $to_prod = $true
} else
{
  $to_prod = $false
}


$global:debug = $false;

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



$attributes_prod = @{
  'Exit SSL cms targetted offers' = 'http://www.carnival.com/{R:1}';
  'Force Non Https for Home Page' = 'http://www.carnival.com';
  'To new deck plans page' = 'http://www.carnival.com/common/CCLUS/ships/ship/htmldeckplans.aspx';
  'imagesCdnHostToPrepend' = 'http://static.carnivalcloud.com';
  'SecureLoginUrl' = 'hhttps://secure.carnival.com/SignInTopSSL.aspx';
  'CarnivalHeaderHtmlUrl' = 'http://www.carnival.com/service/header.aspx';
  'CarnivalFooterHtmlUrl' = 'http://www.carnival.com/service/footer.aspx';
  'SecureUrl' = 'https://secure.carnival.com/';
  'DefaultRobotsDomain' = 'www.carnival.com';
  'DeckPlanServiceDomain' = 'www.carnival.com';
  'USDomain' = 'www.carnival.com, secure.carnival.com';
  'UKDomain' = 'www.carnival.co.uk, secure.carnival.co.uk';
  'UKDomains' = 'www.carnival.co.uk, secure.carnival.co.uk';
  'FullSiteURL' = 'http://www.carnival.com';
  'RESTProxyDomain' = 'http://www.carnival.com';
  'PersonalizationDomain' = 'services.carnival.com';
}


$attributes_preview = @{
  'Exit SSL cms targetted offers' = 'http://prodpreview.carnival.com/{R:1}';
  'Force Non Https for Home Page' = 'http://prodpreview.carnival.com';
  'To new deck plans page' = 'http://prodpreview.carnival.com/common/CCLUS/ships/ship/htmldeckplans.aspx';
  'imagesCdnHostToPrepend' = 'http://prodpreview.carnival.com';
  'SecureLoginUrl' = 'https://prodpreview.carnival.com/SignInTopSSL.aspx';
  'CarnivalHeaderHtmlUrl' = 'http://prodpreview.carnival.com/service/header.aspx';
  'CarnivalFooterHtmlUrl' = 'http://prodpreview.carnival.com/service/footer.aspx';
  'SecureUrl' = 'https://prodpreview.carnival.com/';
  'DefaultRobotsDomain' = 'prodpreview.carnival.com';
  'DeckPlanServiceDomain' = 'prodpreview.carnival.com';
  'USDomain' = 'prodpreview.carnival.com, prodpreview.carnival.com';
  'UKDomain' = 'prodpreviewuk.carnival.com, prodpreviewuk.carnival.com';
  'UKDomains' = 'prodpreviewuk.carnival.com, prodpreviewuk.carnival.com';
  'FullSiteURL' = 'http://prodpreview.carnival.com';
  'RESTProxyDomain' = 'http://prodpreview.carnival.com';
  'PersonalizationDomain' = 'prodpreview.carnival.com';
}

[scriptblock]$Extract_appSetting = {
  param(
    [System.Management.Automation.PSReference]$object_ref,
    [System.Management.Automation.PSReference]$result_ref,
    [string]$key = $null
  )

  if ($key -eq $null -or $key -eq '') {
    throw 'Key cannot be null'

  }

  $data = @{}
  $nodes = $object_ref.Value.Configuration.location.appSettings.add
  for ($cnt = 0; $cnt -ne $nodes.count; $cnt++) {
    # FIXME
    $k = $nodes[$cnt].Getattribute('key')
    $v = $nodes[$cnt].Getattribute('value')


    if ($k -match $key) {

      if ($global:debug) {
        Write-Host $k
        Write-Host $key
        Write-Host $v
      }
      $data[$k] += $v

    }

  }

  $result_ref.Value = $data[$key]
}


[scriptblock]$Extract_imagesCdnHostToPrepend = {
  param(
    [System.Management.Automation.PSReference]$object_ref,
    [System.Management.Automation.PSReference]$result_ref,
    [string]$key = $null # ignored
  )
  $result_ref.Value = $object_ref.Value.Configuration.JACombinerAndOptimizerGroup.combinerSettings.Getattribute("imagesCdnHostToPrepend")
}



[scriptblock]$Extract_RuleActionurl = {
  param(
    [System.Management.Automation.PSReference]$object_ref,
    [System.Management.Automation.PSReference]$result_ref,
    [string]$key = $null
  )

  if ($key -eq $null -or $key -eq '') {
    throw 'Key cannot be null'

  }

  $data = @{}
  $nodes = $object_ref.Value.Configuration.location.'system.webServer'.rewrite.rules.rule
  if ($global:debug) {
    Write-Host $nodes.count
  }
  for ($cnt = 0; $cnt -ne $nodes.count; $cnt++) {

    $k = $nodes[$cnt].Getattribute('name')
    $v = $nodes[$cnt].action.Getattribute('url')
    if ($k -match $key) {
      $data[$k] += $v
      if ($global:debug) {
        # write-output $k; write-output $v
      }
    }

  }

  $result_ref.Value = $data[$key]
}



$attributes_extraction_code = @{
  'Exit SSL cms targetted offers' = $Extract_RuleActionurl;
  'Force Non Https for Home Page' = $Extract_RuleActionurl;
  'To new deck plans page' = $Extract_RuleActionurl;
  'imagesCdnHostToPrepend' = $Extract_imagesCdnHostToPrepend;
  'SecureLoginUrl' = $Extract_AppSetting;
  'CarnivalHeaderHtmlUrl' = $Extract_AppSetting;
  'CarnivalFooterHtmlUrl' = $Extract_AppSetting;
  'SecureUrl' = $Extract_AppSetting;
  'DefaultRobotsDomain' = $Extract_AppSetting;
  'DeckPlanServiceDomain' = $Extract_AppSetting;
  'USDomain' = $Extract_AppSetting;
  'UKDomain' = $Extract_AppSetting;
  'UKDomains' = $Extract_AppSetting;
  'FullSiteURL' = $Extract_AppSetting;
  'RESTProxyDomain' = $Extract_AppSetting;
  'PersonalizationDomain' = $Extract_AppSetting;
}


[scriptblock]$Update_appSetting = {
  param(
    [System.Management.Automation.PSReference]$object_ref,
    [string]$key = $null,
    [string]$value = $null
  )

  if ($key -eq $null -or $key -eq '') {
    throw 'Key cannot be null'
  }
  $local:value = $attributes_modified[$key]
  if ($local:value -eq $null) {
    [string]$error_msg = ('Key not fully specified. Need to know $attributes_modified[{0}]' -f $key)
    throw $error_msg
  }


  $data = @{}

  $nodes = $object_ref.Value.Configuration.location.appSettings.add
  for ($cnt = 0; $cnt -ne $nodes.count; $cnt++) {

    $k = $object_ref.Value.Configuration.location.appSettings.add[$cnt].Getattribute('key')

    if ($k -match $key) {
      Write-Host ('Updating [{0}] with [{1}]' -f $k,$value)
      $object_ref.Value.Configuration.location.appSettings.add[$cnt].Setattribute('value',$value)
    }

  }

}

[scriptblock]$Update_imagesCdnHostToPrepend = {
  param(
    [System.Management.Automation.PSReference]$object_ref,
    [string]$key = 'imagesCdnHostToPrepend'
  )
  $local:value = $attributes_modified[$key]
  if ($local:value -eq $null) {
    [string]$error_msg = ('Key not fully specified. Need to know $attributes_modified[{0}]' -f $key)
    throw $error_msg
  }

  $k = $object_ref.Value.Configuration.JACombinerAndOptimizerGroup.combinerSettings.Getattribute($key)
  if ($k -ne $null) {
    Write-Host ('Updating [{0}] with [{1}]' -f $k,$value)
    $object_ref.Value.Configuration.JACombinerAndOptimizerGroup.combinerSettings.Setattribute($key,$value)
  }
}


[scriptblock]$Update_RuleActionurl = {
  param(
    [System.Management.Automation.PSReference]$object_ref,
    [string]$key = $null,
    [string]$value = $null
  )



  if ($key -eq $null -or $key -eq '') {
    throw 'Key cannot be null'
  }
  $local:value = $attributes_modified[$key]
  if ($local:value -eq $null) {
    [string]$error_msg = ('Key not fully specified. Need to know $attributes_modified[{0}]' -f $key)
    throw $error_msg
  }

  $data = @{}

  $nodes = $object_ref.Value.Configuration.location.'system.webServer'.rewrite.rules.rule

  for ($cnt = 0; $cnt -ne $nodes.count; $cnt++) {

    $k = $nodes[$cnt].Getattribute('name')
    $v = $nodes[$cnt].action.Getattribute('url')

    if ($k -match $key) {
      Write-Host ('Updating {0}[{1}] with [{2}]' -f $k,$v,$value)

      # only one  
      $object_ref.Value.Configuration.location.'system.webServer'.rewrite.rules.rule[$cnt].action.Setattribute('url',$value)

    }

  }

}


$attributes_setter_code = @{
  'Exit SSL cms targetted offers' = $Update_RuleActionurl;
  'Force Non Https for Home Page' = $Update_RuleActionurl;
  'To new deck plans page' = $Update_RuleActionurl;
  'imagesCdnHostToPrepend' = $Update_imagesCdnHostToPrepend;
  'USDomain' = $Update_appSetting;
  'UKDomains' = $Update_appSetting;
  'UKDomain' = $Update_appSetting;
  'RESTProxyDomain' = $Update_appSetting;
  'PersonalizationDomain' = $Update_appSetting;
  'CarnivalHeaderHtmlUrl' = $Update_appSetting;
  'DeckPlanServiceDomain' = $Update_appSetting;
  'SecureUrl' = $Update_appSetting;
  'FullSiteURL' = $Update_appSetting;
  'CarnivalFooterHtmlUrl' = $Update_appSetting;
  'DefaultRobotsDomain' = $Update_appSetting;
  'SecureLoginUrl' = $Update_appSetting;
}

function collect_config_data {

  param(
    [ValidateNotNull()]
    [string]$target_domain,
    [string]$target_unc_path,
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

  backup_file -File $target_unc_path
  if ($verbose) {
    Write-Output ('Probing "{0}"' -f $target_unc_path) | Out-File 'data.log' -Append -Encoding ascii
  }

  [xml]$xml_config = Get-Content -Path $target_unc_path
  $object_ref = ([ref]$xml_config)

  #----------- print the 

  Write-Host 'Current settings'

  $attributes_preview.Keys | ForEach-Object {
    $k = $_
    $v = $attributes_preview[$k]
    [scriptblock]$s = $attributes_extraction_code[$k]
    if ($s -ne $null) {
      $local:result = $null
      $result_ref = ([ref]$local:result)
      Invoke-Command $s -ArgumentList $object_ref,$result_ref,$k
      Write-Host ('{0}  = {1}' -f $k,$result_ref.Value)
    } else {
      Write-Host ('extract function not defined for {0}' -f $k)
      # TODO: throw
    }
  }

  #----------- update w/o saving 
  Write-Host 'Update settings'

  if ($to_prod) {
    $attributes_modified = $attributes_prod;
  } else {
    $attributes_modified = $attributes_preview;
  }
  $attributes_setter_code.Keys | ForEach-Object {
    $k = $_
    $v = $attributes_preview[$k]
    [scriptblock]$s = $attributes_setter_code[$k]
    if ($s -ne $null) {
      $local:result = $null
      $result_ref = ([ref]$local:result)
      Invoke-Command $s -ArgumentList $object_ref,$k

    } else {
      # FIXME  
    }
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

  Start-Sleep 3

  [xml]$xml_config = Get-Content -Path $new_config_file_path
  $object_ref = ([ref]$xml_config)
  # ---

  #----------- print the modified  settings
  Write-Host 'Modified  settings'
  $attributes_preview.Keys | ForEach-Object {
    $k = $_
    $v = $attributes_preview[$k]
    [scriptblock]$s = $attributes_extraction_code[$k]
    if ($s -ne $null) {
      $local:result = $null
      $result_ref = ([ref]$local:result)
      Invoke-Command $s -ArgumentList $object_ref,$result_ref,$k
      Write-Host ('{0}  = {1}' -f $k,$result_ref.Value)

    } else {
      Write-Host ('extract function not defined for {0}' -f $k)
    }
  }



  # FIXME 
  #-----------
  $result_ref = ([ref]$local:result)

  return $local:result


}

$configuration_paths = @{
  'Preview' =
  @{
    'COMMENT' = 'Production Preview Servers ConnectionStrings.config';
    'PATH' = 'E:\Projects\prod.carnival.com\Carnival\Web.config';
    'DOMAIN' = 'CARNIVAL';
    'SERVERS' = @(
      'cclprdecopv1.carnival.com',
      $null
    );
  };

};

foreach ($role in $configuration_paths.Keys) {
  $configuration = $configuration_paths.Item($role)
  Write-Host ('Starting {0}' -f $configuration['COMMENT'])
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
    Write-Output ("Inspecfing nodes in the domain {0}" -f $configuration['DOMAIN'])
    $unc_paths | ForEach-Object { $target_unc_path = $_; if ($target_unc_path -eq $null) { return }
      $configuration_results[$target_unc_path] = @()
      $configuration_results[$target_unc_path] = collect_config_data -target_domain $configuration['DOMAIN'] `
         -target_unc_path $target_unc_path `
         -powerless $true

      # 'powerless'  is currently unused 
    }

  }
}



