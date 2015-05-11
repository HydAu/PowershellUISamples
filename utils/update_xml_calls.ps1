# Update certain elements within the web.config of prod-preview (web.config)
# 16 entries or so .

param([switch]$preview)

$attributes_prod = @{
  'core' = "user id=USER;password=PASSWORD;Data Source=DB_SERVER;Database=CORE";
  'master' = "user id=USER;password=PASSWORD;Data Source=DB_SERVER;Database=MASTER";
  'web' = "user id=USER;password=PASSWORD;Data Source=DB_SERVER;Database=WEB";
  'pub' = "user id=USER;password=PASSWORD;Data Source=DB_SERVER;Database=PUB";

}

$attributes_preview = @{
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

[scriptblock]$Extract_appSettings = {
  param(
    [System.Management.Automation.PSReference]$object_ref,
    [System.Management.Automation.PSReference]$result_ref,
    # Position must be last
    [string]$key = $null
  )


  $data = @{}
  $debug = $false
  if ($false -and $debug) {
    Write-Host $object_ref.Value
    Write-Host $object_ref.Value.Configuration
    Write-Host $object_ref.Value.Configuration.location.appSettings.add
  }
  $nodes = $object_ref.Value.Configuration.location.appSettings.add
  if ($debug) {
    Write-Host $nodes.count
  }
  for ($cnt = 0; $cnt -ne $nodes.count; $cnt++) {
    # $data += $Value.configuration.location.appSettings.add[$cnt].value
    # extract and  keep the data source  throw away the rest

    $k = $object_ref.Value.Configuration.location.appSettings.add[$cnt].Getattribute('key')
    $v = $object_ref.Value.Configuration.location.appSettings.add[$cnt].Getattribute('value')


    if ($k -match $key) {

      if ($debug) {
        Write-Host $k
        Write-Host $key

        Write-Output '!'
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
    [System.Management.Automation.PSReference]$result_ref)
  $result_ref.Value = $object_ref.Value.Configuration.JACombinerAndOptimizerGroup.combinerSettings.Getattribute("imagesCdnHostToPrepend")
}


[scriptblock]$Extract_PersonalizationDomain = {
  param(
    [System.Management.Automation.PSReference]$object_ref,
    [System.Management.Automation.PSReference]$result_ref,
    [string]$key = 'PersonalizationDomain'
  )
  [scriptblock]$s = $Extract_appSettings
  $local:result = $null
  Invoke-Command $s -ArgumentList $object_ref,([ref]$local:result),$key
  $debug = $false
  if ($debug) {
    Write-Host ('returning {0}' -f $local:result)
  }
  $result_ref.Value = $local:result
}

[scriptblock]$Extract_SecureLoginUrl = {
  param(
    [System.Management.Automation.PSReference]$object_ref,
    [System.Management.Automation.PSReference]$result_ref,
    [string]$key = 'SecureLoginUrl'
  )
  [scriptblock]$s = $Extract_appSettings
  $local:result = $null
  Invoke-Command $s -ArgumentList $object_ref,([ref]$local:result),$key
  $result_ref.Value = $local:result
}


[scriptblock]$Extract_CarnivalHeaderHtmlUrl = {
  param(
    [System.Management.Automation.PSReference]$object_ref,
    [System.Management.Automation.PSReference]$result_ref,
    [string]$key = 'CarnivalHeaderHtmlUrl'
  )
  [scriptblock]$s = $Extract_appSettings
  $local:result = $null
  Invoke-Command $s -ArgumentList $object_ref,([ref]$local:result),$key
  $result_ref.Value = $local:result
}

[scriptblock]$Extract_CarnivalFooterHtmlUrl = {
  param(
    [System.Management.Automation.PSReference]$object_ref,
    [System.Management.Automation.PSReference]$result_ref,
    [string]$key = 'CarnivalFooterHtmlUrl'
  )
  [scriptblock]$s = $Extract_appSettings
  $local:result = $null
  Invoke-Command $s -ArgumentList $object_ref,([ref]$local:result),$key
  $result_ref.Value = $local:result
}


[scriptblock]$Extract_RESTProxyDomain = {
  param(
    [System.Management.Automation.PSReference]$object_ref,
    [System.Management.Automation.PSReference]$result_ref,
    [string]$key = 'RESTProxyDomain'
  )
  [scriptblock]$s = $Extract_appSettings
  # temporary extra variables /  reference  for debugging  
  $local:result2 = $null
  $result_ref2 = ([ref]$local:result2)
  Invoke-Command $s -ArgumentList $object_ref,$result_ref2,$key


  if ($debug) {
    Write-Host ('returning {0}' -f $result_ref2.Value)
  }
  $result_ref.Value = $result_ref2.Value
}


[scriptblock]$Extract_SecureLoginUrl = {
  param(
    [System.Management.Automation.PSReference]$object_ref,
    [System.Management.Automation.PSReference]$result_ref,
    [string]$key = 'SecureLoginUrl'
  )
  [scriptblock]$s = $Extract_appSettings
  $local:result = $null
  Invoke-Command $s -ArgumentList $object_ref,([ref]$local:result),$key
  $result_ref.Value = $local:result
}

[scriptblock]$Extract_SecureUrl = {
  param(
    [System.Management.Automation.PSReference]$object_ref,
    [System.Management.Automation.PSReference]$result_ref,
    [string]$key = 'SecureUrl'
  )
  [scriptblock]$s = $Extract_appSettings
  $local:result = $null
  Invoke-Command $s -ArgumentList $object_ref,([ref]$local:result),$key
  $result_ref.Value = $local:result
}

[scriptblock]$Extract_DefaultRobotsDomain = {
  param(
    [System.Management.Automation.PSReference]$object_ref,
    [System.Management.Automation.PSReference]$result_ref,
    [string]$key = 'DefaultRobotsDomain'
  )
  [scriptblock]$s = $Extract_appSettings
  $local:result = $null
  Invoke-Command $s -ArgumentList $object_ref,([ref]$local:result),$key
  $result_ref.Value = $local:result
}


[scriptblock]$Extract_DeckPlanServiceDomain = {
  param(
    [System.Management.Automation.PSReference]$object_ref,
    [System.Management.Automation.PSReference]$result_ref,
    [string]$key = 'DeckPlanServiceDomain'
  )
  [scriptblock]$s = $Extract_appSettings
  $local:result = $null
  Invoke-Command $s -ArgumentList $object_ref,([ref]$local:result),$key
  $result_ref.Value = $local:result
}


[scriptblock]$Extract_USDomain = {
  param(
    [System.Management.Automation.PSReference]$object_ref,
    [System.Management.Automation.PSReference]$result_ref,
    [string]$key = 'USDomain'
  )
  [scriptblock]$s = $Extract_appSettings
  $local:result = $null
  Invoke-Command $s -ArgumentList $object_ref,([ref]$local:result),$key
  $result_ref.Value = $local:result
}


[scriptblock]$Extract_USDomain = {
  param(
    [System.Management.Automation.PSReference]$object_ref,
    [System.Management.Automation.PSReference]$result_ref,
    [string]$key = 'USDomain'
  )
  [scriptblock]$s = $Extract_appSettings
  $local:result = $null
  Invoke-Command $s -ArgumentList $object_ref,([ref]$local:result),$key
  $result_ref.Value = $local:result
}

[scriptblock]$Extract_UKDomain = {
  param(
    [System.Management.Automation.PSReference]$object_ref,
    [System.Management.Automation.PSReference]$result_ref,
    [string]$key = 'UKDomain'
  )
  [scriptblock]$s = $Extract_appSettings
  $local:result = $null
  Invoke-Command $s -ArgumentList $object_ref,([ref]$local:result),$key
  $result_ref.Value = $local:result
}


[scriptblock]$Extract_UKDomains = {
  param(
    [System.Management.Automation.PSReference]$object_ref,
    [System.Management.Automation.PSReference]$result_ref,
    [string]$key = 'UKDomains'
  )
  [scriptblock]$s = $Extract_appSettings
  $local:result = $null
  Invoke-Command $s -ArgumentList $object_ref,([ref]$local:result),$key
  $result_ref.Value = $local:result
}

[scriptblock]$Extract_FullSiteURL = {
  param(
    [System.Management.Automation.PSReference]$object_ref,
    [System.Management.Automation.PSReference]$result_ref,
    [string]$key = 'FullSiteURL'
  )
  [scriptblock]$s = $Extract_appSettings
  $local:result = $null
  Invoke-Command $s -ArgumentList $object_ref,([ref]$local:result),$key
  $result_ref.Value = $local:result
}


$attributes_extraction_code = @{
  'imagesCdnHostToPrepend' = $Extract_imagesCdnHostToPrepend;
  'SecureLoginUrl' = $Extract_SecureLoginUrl;
  'CarnivalHeaderHtmlUrl' = $Extract_CarnivalHeaderHtmlUrl;
  'CarnivalFooterHtmlUrl' = $Extract_CarnivalFooterHtmlUrl;
  'SecureUrl' = $Extract_SecureUrl;
  'DefaultRobotsDomain' = $Extract_DefaultRobotsDomain;
  'DeckPlanServiceDomain' = $Extract_DeckPlanServiceDomain;
  'USDomain' = $Extract_USDomain;
  'UKDomain' = $Extract_UKDomain;
  'UKDomains' = $Extract_UKDomains;
  'FullSiteURL' = $Extract_FullSiteURL;
  'RESTProxyDomain' = $Extract_RESTProxyDomain
  'PersonalizationDomain' = $Extract_PersonalizationDomain;


}



[scriptblock]$Update_appSettings = {
  param(
    [System.Management.Automation.PSReference]$object_ref,
    # Position must be last
    [string]$key = $null,
    [string]$value = $null
  )


  $data = @{}
  $debug = $false
  if ($false -and $debug) {
    Write-Host $object_ref.Value
    Write-Host $object_ref.Value.Configuration
    Write-Host $object_ref.Value.Configuration.location.appSettings.add
  }
  $nodes = $object_ref.Value.Configuration.location.appSettings.add
  if ($debug) {
    Write-Host $nodes.count
  }
  for ($cnt = 0; $cnt -ne $nodes.count; $cnt++) {

    $k = $object_ref.Value.Configuration.location.appSettings.add[$cnt].Getattribute('key')

    if ($k -match $key) {
       write-output  ('Updating {0} with {1}' -f  $k, $value )
       $object_ref.Value.Configuration.location.appSettings.add[$cnt].Setattribute('value', $value )
    }

  }

}


[scriptblock]$Update_SecureLoginUrl = {
  param(
    [System.Management.Automation.PSReference]$object_ref,
    [string]$key = 'SecureLoginUrl'
  )
  $local:value = $attributes_modified[$key]
  [scriptblock]$s = $Update_appSettings
  Invoke-Command $s -ArgumentList $object_ref,$key,$local:value
}


$attributes_setter_code = @{
'SecureLoginUrl'  = $Update_SecureLoginUrl ; 
}

$attributes_modified = @{
'SecureLoginUrl'  = 'https://xxx';

}

# $attributes_prod | Get-Member

$attributes_prod.Keys | ForEach-Object {
  $k = $_
  $v = $attributes_prod[$k]
  $n = $attributes_preview[$k]
  # TODO: assert 
}


$attributes_preview.Keys | ForEach-Object {
  $k = $_
  $v = $attributes_preview[$k]
  $n = $attributes_prod[$k]
  # TODO: assert 
}



$config_file_path = '.\prod-preview.web.config'

[xml]$object = Get-Content -Path $config_file_path
$object_ref = ([ref]$object)


$attributes_preview.Keys | ForEach-Object {
  $k = $_
  $v = $attributes_preview[$k]
  [scriptblock]$s = $attributes_extraction_code[$k]
  if ($s -ne $null) {
    # [scriptblock]$script_block = $attributes_extraction_code['imagesCdnHostToPrepend']
    $local:result = $null
    $result_ref = ([ref]$local:result)
    Invoke-Command $s -ArgumentList $object_ref,$result_ref

    Write-Output ('{0}  = {1}' -f $k,$result_ref.Value)

  } else {
    Write-Output ('extract function not defined for {0}' -f $k )
  }
}


$attributes_setter_code.Keys | ForEach-Object {
  $k = $_
  $v = $attributes_preview[$k]
  [scriptblock]$s = $attributes_setter_code[$k]
  if ($s -ne $null) {
    $local:result = $null
    $result_ref = ([ref]$local:result)
    Invoke-Command $s -ArgumentList $object_ref

  } else {
  }
}

 $new_config_file_path = 'C:\Users\sergueik\code\powershell\example\prod-preview.web.NEW.config'
 Write-Output ('Saving to {0} ' -f $new_config_file_path)
# 
  $object.Save($new_config_file_path)


$config_file_path = '.\prod-preview.web.NEW.config'

[xml]$object = Get-Content -Path $config_file_path
$object_ref = ([ref]$object)


$attributes_preview.Keys | ForEach-Object {
  $k = $_
  $v = $attributes_preview[$k]
  [scriptblock]$s = $attributes_extraction_code[$k]
  if ($s -ne $null) {
    # [scriptblock]$script_block = $attributes_extraction_code['imagesCdnHostToPrepend']
    $local:result = $null
    $result_ref = ([ref]$local:result)
    Invoke-Command $s -ArgumentList $object_ref,$result_ref

    Write-Output ('{0}  = {1}' -f $k,$result_ref.Value)

  } else {
    Write-Output ('extract function not defined for {0}' -f $k )
  }
}


# http://blogs.msdn.com/b/sonam_rastogi_blogs/archive/2014/05/14/update-xml-file-using-powershell.aspx
