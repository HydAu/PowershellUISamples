# Update certain elements within the web.config of prod-preview (web.config)
# 16 entries or so .

param([switch]$preview)

$attributes_prod = @{
  'core' = "user id=sitecore;password=St104z4U!;Data Source=cclprdecodb1\cclprdecodb1;Database=CarnivalSitecore_Core";
  'master' = "user id=sitecore;password=St104z4U!;Data Source=cclprdecodb1\cclprdecodb1;Database=CarnivalSitecore_Master";
  'web' = "user id=sitecore;password=St104z4U!;Data Source=cclprdecodb1\cclprdecodb1;Database=CarnivalSitecore_Web";
  'pub' = "user id=sitecore;password=St104z4U!;Data Source=cclprdecodb2\cclprdecodb2;Database=CarnivalSitecore_Pub";

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


[scriptblock]$CONFIGURATION_EXTRACT = {
  param(
    [System.Management.Automation.PSReference]$object_ref,
    [System.Management.Automation.PSReference]$result_ref)

  $result_ref.Value = $object_ref.Value.Configuration.JACombinerAndOptimizerGroup.combinerSettings.Getattribute("imagesCdnHostToPrepend")
}


[scriptblock]$CONFIGURATION_EXTRACT4 = {
  param(
    [System.Management.Automation.PSReference]$object_ref,
    [System.Management.Automation.PSReference]$result_ref,
    [string]$key = 'PersonalizationDomain'
  )
  [scriptblock]$s = $CONFIGURATION_EXTRACT2
  $local:result = $null
  Invoke-Command $s -ArgumentList $object_ref,([ref]$local:result),$key
  $debug = $false
  if ($debug) {
    Write-Host ('returning {0}' -f $local:result)
  }
  $result_ref.Value = $local:result
}

[scriptblock]$CONFIGURATION_EXTRACT5 = {
  param(
    [System.Management.Automation.PSReference]$object_ref,
    [System.Management.Automation.PSReference]$result_ref,
    [string]$key = 'SecureLoginUrl'
  )
  [scriptblock]$s = $CONFIGURATION_EXTRACT2
  $local:result = $null
  Invoke-Command $s -ArgumentList $object_ref,([ref]$local:result),$key
  $result_ref.Value = $local:result
}



[scriptblock]$CONFIGURATION_EXTRACT6 = {
  param(
    [System.Management.Automation.PSReference]$object_ref,
    [System.Management.Automation.PSReference]$result_ref,
    [string]$key = 'CarnivalHeaderHtmlUrl'
  )
  [scriptblock]$s = $CONFIGURATION_EXTRACT2
  $local:result = $null
  Invoke-Command $s -ArgumentList $object_ref,([ref]$local:result),$key
  $result_ref.Value = $local:result
}

[scriptblock]$CONFIGURATION_EXTRACT7 = {
  param(
    [System.Management.Automation.PSReference]$object_ref,
    [System.Management.Automation.PSReference]$result_ref,
    [string]$key = 'CarnivalFooterHtmlUrl'
  )
  [scriptblock]$s = $CONFIGURATION_EXTRACT2
  $local:result = $null
  Invoke-Command $s -ArgumentList $object_ref,([ref]$local:result),$key
  $result_ref.Value = $local:result
}


[scriptblock]$CONFIGURATION_EXTRACT3 = {
  param(
    [System.Management.Automation.PSReference]$object_ref,
    [System.Management.Automation.PSReference]$result_ref,
    [string]$key = 'RESTProxyDomain'
  )
  [scriptblock]$s = $CONFIGURATION_EXTRACT2
  # temporary extra variables /  reference  for debugging  
  $local:result2 = $null
  $result_ref2 = ([ref]$local:result2)
  Invoke-Command $s -ArgumentList $object_ref,$result_ref2,$key


  if ($debug) {
    Write-Host ('returning {0}' -f $result_ref2.Value)
  }
  $result_ref.Value = $result_ref2.Value
}


[scriptblock]$CONFIGURATION_EXTRACT2 = {
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

$attributes_extraction_code = @{
  'imagesCdnHostToPrepend' = $CONFIGURATION_EXTRACT;
  'RESTProxyDomain' = $CONFIGURATION_EXTRACT3;
  'PersonalizationDomain' = $CONFIGURATION_EXTRACT4;
  'SecureLoginUrl' = $CONFIGURATION_EXTRACT5;
  'CarnivalHeaderHtmlUrl' = $CONFIGURATION_EXTRACT6;

  'CarnivalFooterHtmlUrl' = $CONFIGURATION_EXTRACT7;

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
  }
}


# http://blogs.msdn.com/b/sonam_rastogi_blogs/archive/2014/05/14/update-xml-file-using-powershell.aspx
# $new_config_file_path = 'C:\Users\sergueik\code\powershell\example\ConnectionStrings.config.back'
# Write-Output ('Saving to {0} ' -f $new_config_file_path)
# 
#  $object.Save($new_config_file_path)
