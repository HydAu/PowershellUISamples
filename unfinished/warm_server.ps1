param ([String] $hostname, [String] $host_ip)    

#Primed URLs	
$webpagelist = (
	"http://$host_ip", 
	"http://$host_ip/#q=selenium,&spell=1", 
	"http://$host_ip/#q=Selenium+-+Google+Code",
	"http://$host_ip/#q=Selenium+-+wikipedia"
	)

# introduced one short and one long response delay 
# if ($debug -eq $true){
  $mockup_delays  = @{"web30" = 100; "web23" = 30 }
#}

  $WebpageList | ForEach-Object {
  $url =  $_ ;
  write-output $url
  <#
  if ( $url -like 'specials') {
    if ($mockup_delays.containskey($hostname) ) {
      $delay = $mockup_delays[$hostname]
      write-output ("Sleeping {0} seconds" -f $delay)
      start-sleep -seconds $delay;
    }
  }
  Write-output ("Opening page: {0}" -f $url)
  $warmup_response_time = [System.Math]::Round((Measure-Command {(new-object net.webclient).DownloadString( $url  )}).totalmilliseconds)
  Write-output ("Opening page: {0} took {1} ms" -f $url, $warmup_response_time )
#>
};
