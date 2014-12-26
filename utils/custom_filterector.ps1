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
    'DOMAIN' = 'CARNIVAL';
  };
  'UAT2' = @{
    'SCRIPT' = $EXAMPLE;
    'EXPRESSION' = '^ccluat.*n2\.';
    'DOMAIN' = 'CARNIVAL';
  };
  'UAT3' = @{
    'SCRIPT' = $EXAMPLE;
    'EXPRESSION' = '^ccluat.*n3\.';
    'DOMAIN' = 'CARNIVAL';
  };
  'UAT4' = @{
    'SCRIPT' = $EXAMPLE;
    'EXPRESSION' = '^ccluat.*n4\.';
    'DOMAIN' = 'CARNIVAL';
  };
  'UAT5' = @{
    'SCRIPT' = $EXAMPLE;
    'EXPRESSION' = '^ccluat.*n5\.';
    'DOMAIN' = 'CARNIVAL';
  };





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

  'UAT INSIDE' = @{
    'COMMENT' = 'UAT Servers';
    'DOMAIN' = 'CARNIVAL';
    'SERVERS' =
    @(
      # 1dbd91d1d66b6eaa67b387c2ffb0dc910c45dde4      #   , 

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

$DebugPreference = 'Continue'
$object_ref = ([ref]$ENVIRONMENTS_STRUCTURED)
$caller_ref = ([ref]$ENVIRONMENTS_CUSTOM)
$ENVIRONMENTS_CUSTOM.Keys | ForEach-Object {


  $k = $_
  # $v = $ENVIRONMENTS_CUSTOM[$k] 
  # todo nesting 
  [scriptblock]$s = $ENVIRONMENTS_CUSTOM[$k]['SCRIPT']
  if ($s -ne $null) {
    $local:result = $null
    $result_ref = ([ref]$local:result)
    Invoke-Command $s -ArgumentList $object_ref,$result_ref,$caller_ref,$k
    Write-Host ('{0}  = {1}' -f $k,$result_ref.Value)
    $result_ref.Value | Format-Table
  } else {
    Write-Host ('extract function not defined for {0}' -f $k)
    # TODO: throw
  }
}
