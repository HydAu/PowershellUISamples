<#

SPLUNK expression syntax;
index=iis_carnival |rex field=cs_User_Agent_ "^(?<cs_User_Agent_>.+)$"| rex "^(?:[\S]* ){4}(?<ua>.*)\s\w+$" | 
eval device = case( ua LIKE "%Chrome%", "Chrome", ua LIKE "%Trident/7.0;+rv:11.0%","Internet Explorer 11", ua LIKE "%iPhone;+CPU+iPhone+OS%","Apple iPhone (Safarai Mobile)" , ua like "%compatible;+MSIE+9.0%","Internet Explorer 9" , ua like "%MSIE+10.0%","Internet Explorer 10" , ua like "%MSIE+8.0%","Internet Explorer 8" , ua like "%Firefox%","FireFox", ua like "%Macintosh;+Intel+Mac+OS%","MAC OS X (Safari)", ua LIKE "%iPad;+CPU+OS%","Apple iPad", ua like "%Linux;+Android%","Android", ua like "%Trident/7.0;+Touch;+rv:11.0%","Windows Phone") | top 20 device
#>
# desired breakdown ?
# http://www.useragentstring.com/pages/Browserlist/
# Real SPLUNK data extract
$user_agent_stats = @{
  "Mozilla/5.0+(Windows+NT+6.1;+WOW64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/42.0.2311.135+Safari/537.36" = 717120;
  "Mozilla/5.0+(iPhone;+CPU+iPhone+OS+8_3+like+Mac+OS+X)+AppleWebKit/600.1.4+(KHTML,+like+Gecko)+Version/8.0+Mobile/12F70+Safari/600.1.4" = 315192;
  "Mozilla/5.0+(Windows+NT+6.1;+WOW64;+rv:37.0)+Gecko/20100101+Firefox/37.0" = 272816;
  "Mozilla/5.0+(compatible;+MSIE+9.0;+Windows+NT+6.1;+WOW64;+Trident/5.0)" = 272744;
  "Mozilla/5.0+(Windows+NT+6.1)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/42.0.2311.135+Safari/537.36" = 263093;
  "Mozilla/5.0+(Windows+NT+6.1;+Trident/7.0;+rv:11.0)+like+Gecko" = 218477;
  "Mozilla/5.0+(Windows+NT+6.1;+WOW64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/42.0.2311.90+Safari/537.36" = 198134;
  "Mozilla/5.0+(Windows+NT+6.3;+WOW64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/42.0.2311.135+Safari/537.36" = 197896;
  "Mozilla/4.0+(compatible;+MSIE+8.0;+Windows+NT+5.1;+Trident/4.0;+.NET+CLR+2.0.50727;+.NET+CLR+3.0.4506.2152;+.NET+CLR+3.5.30729;+.NET4.0C;+.NET4.0E)" = 177662;
  "Mozilla/5.0+(compatible;+MSIE+9.0;+Windows+NT+6.1;+Trident/5.0)" = 167908;
  "Mozilla/5.0+(iPad;+CPU+OS+8_3+like+Mac+OS+X)+AppleWebKit/600.1.4+(KHTML,+like+Gecko)+Version/8.0+Mobile/12F69+Safari/600.1.4" = 166785;
  "Mozilla/5.0+(Windows+NT+6.3;+WOW64;+Trident/7.0;+rv:11.0)+like+Gecko" = 165294;
  "Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_10_3)+AppleWebKit/600.5.17+(KHTML,+like+Gecko)+Version/8.0.5+Safari/600.5.17" = 142407;
  "Mozilla/5.0+(compatible;+MSIE+10.0;+Windows+NT+6.1;+WOW64;+Trident/6.0)" = 94165;
  "Mozilla/5.0+(compatible;+MSIE+9.0;+Windows+NT+6.1;+WOW64;+Trident/6.0)" = 85009;
  "Mozilla/5.0+(Windows+NT+6.3;+WOW64;+rv:37.0)+Gecko/20100101+Firefox/37.0" = 82726;
  "Mozilla/5.0+(Windows+NT+6.3;+WOW64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/42.0.2311.90+Safari/537.36" = 80491;
  "Mozilla/5.0+(Windows+NT+5.1)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/42.0.2311.135+Safari/537.36" = 78439;
  "Mozilla/5.0+(Windows+NT+6.1;+rv:37.0)+Gecko/20100101+Firefox/37.0" = 74326;
  "Mozilla/5.0+(Windows+NT+6.3;+WOW64;+Trident/7.0;+Touch;+rv:11.0)+like+Gecko" = 64661;
  "Mozilla/5.0+(Windows+NT+6.1)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/42.0.2311.90+Safari/537.36" = 58079;
  "Mozilla/5.0+(compatible;+MSIE+10.0;+Windows+NT+6.1;+Trident/6.0)" = 54829;
  "Mozilla/5.0+(iPhone;+CPU+iPhone+OS+8_2+like+Mac+OS+X)+AppleWebKit/600.1.4+(KHTML,+like+Gecko)+Version/8.0+Mobile/12D508+Safari/600.1.4" = 48476;
  "Mozilla/5.0+(Windows+NT+5.1;+rv:37.0)+Gecko/20100101+Firefox/37.0" = 46094;
  "Mozilla/5.0+(iPad;+CPU+OS+8_2+like+Mac+OS+X)+AppleWebKit/600.1.4+(KHTML,+like+Gecko)+Version/8.0+Mobile/12D508+Safari/600.1.4" = 44374;
  "Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_10_2)+AppleWebKit/600.4.10+(KHTML,+like+Gecko)+Version/8.0.4+Safari/600.4.10" = 43224;
  "Mozilla/5.0+(compatible;+MSIE+9.0;+Windows+NT+6.1;+Trident/6.0)" = 42106;
  "Mozilla/5.0+(iPhone;+CPU+iPhone+OS+8_1_3+like+Mac+OS+X)+AppleWebKit/600.1.4+(KHTML,+like+Gecko)+Version/8.0+Mobile/12B466+Safari/600.1.4" = 40628;
  "Mozilla/5.0+(iPad;+CPU+OS+7_1_2+like+Mac+OS+X)+AppleWebKit/537.51.2+(KHTML,+like+Gecko)+Version/7.0+Mobile/11D257+Safari/9537.53" = 39712;
  "Mozilla/4.0+(compatible;+MSIE+7.0;+Windows+NT+6.1;+Trident/4.0;+SLCC2;+.NET+CLR+2.0.50727;+.NET+CLR+3.5.30729;+.NET+CLR+3.0.30729;+Media+Center+PC+6.0;+.NET4.0C;+.NET4.0E;+InfoPath.3)" = 39417;
  "Mozilla/5.0+(iPhone;+CPU+iPhone+OS+7_1_2+like+Mac+OS+X)+AppleWebKit/537.51.2+(KHTML,+like+Gecko)+Version/7.0+Mobile/11D257+Safari/9537.53" = 39207; #" = 0.422221
  "Mozilla/5.0+(iPhone;+CPU+iPhone+OS+8_1_2+like+Mac+OS+X)+AppleWebKit/600.1.4+(KHTML,+like+Gecko)+Version/8.0+Mobile/12B440+Safari/600.1.4" = 37600; #" = 0.404915
  "Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_9_5)+AppleWebKit/600.5.17+(KHTML,+like+Gecko)+Version/7.1.5+Safari/537.85.14" = 34979; #" = 0.376690
  "Screaming+Frog+SEO+Spider/3.1" = 34683; #" = 0.373502
  "Mozilla/5.0+(iPad;+CPU+OS+8_1_3+like+Mac+OS+X)+AppleWebKit/600.1.4+(KHTML,+like+Gecko)+Version/8.0+Mobile/12B466+Safari/600.1.4" = 33996; #" = 0.366104
  "Mozilla/5.0+(Windows+NT+6.0)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/42.0.2311.135+Safari/537.36" = 32044; #" = 0.345083
  "Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_10_2)+AppleWebKit/600.3.18+(KHTML,+like+Gecko)+Version/8.0.3+Safari/600.3.18" = 30909; #" = 0.332860
  "Mozilla/5.0+(compatible;+MSIE+9.0;+Windows+NT+6.0;+Trident/5.0)" = 29279; #" = 0.315306
  "Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_6_8)+AppleWebKit/534.59.10+(KHTML,+like+Gecko)+Version/5.1.9+Safari/534.59.10" = 24928; #" = 0.268450
  "Mozilla/5.0+(iPad;+CPU+OS+8_1_2+like+Mac+OS+X)+AppleWebKit/600.1.4+(KHTML,+like+Gecko)+Version/8.0+Mobile/12B440+Safari/600.1.4" = 24836; #" = 0.267459
  "Mozilla/5.0+(Windows+NT+6.1;+WOW64;+rv:31.0)+Gecko/20100101+Firefox/31.0" = 23873; #" = 0.257089
  "Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_7_5)+AppleWebKit/537.78.2+(KHTML,+like+Gecko)+Version/6.1.6+Safari/537.78.2" = 22975; #" = 0.247418
  "Mozilla/5.0+(Windows+NT+6.0;+rv:37.0)+Gecko/20100101+Firefox/37.0" = 21988; #" = 0.236789
  "Mozilla/5.0+(Windows+NT+5.1)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/42.0.2311.90+Safari/537.36" = 21068; #" = 0.226882
  "Mozilla/5.0+(iPad;+CPU+OS+7_1_1+like+Mac+OS+X)+AppleWebKit/537.51.2+(KHTML,+like+Gecko)+Version/7.0+Mobile/11D201+Safari/9537.53" = 20777; #" = 0.223748
  "Mozilla/5.0+(Windows+NT+6.3;+Win64;+x64;+Trident/7.0;+rv:11.0)+like+Gecko" = 20447; #" = 0.220194
  "Mozilla/5.0+(compatible;+MSIE+9.0;+Windows+NT+6.1;+Win64;+x64;+Trident/5.0)" = 20200; #" = 0.217534
  "Mozilla/5.0+(Linux;+Android+5.0;+SM-G900V+Build/LRX21T)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/42.0.2311.111+Mobile+Safari/537.36" = 20011; #" = 0.215499
  "Mozilla/4.0+(compatible;+MSIE+8.0;+Windows+NT+6.1;+Trident/4.0;+SLCC2;+.NET+CLR+2.0.50727;+.NET+CLR+3.5.30729;+.NET+CLR+3.0.30729;+Media+Center+PC+6.0;+.NET4.0C;+.NET4.0E;+InfoPath.3)" = 18427; #" = 0.198441
  "Mozilla/4.0+(compatible;+MSIE+8.0;+Windows+NT+6.1;+WOW64;+Trident/4.0;+SLCC2;+.NET+CLR+2.0.50727;+.NET+CLR+3.5.30729;+.NET+CLR+3.0.30729;+Media+Center+PC+6.0;+.NET4.0C;+.NET4.0E;+InfoPath.3)" = 17727; #" = 0.190902
  "Mozilla/5.0+(Windows+NT+6.1;+Win64;+x64;+Trident/7.0;+rv:11.0)+like+Gecko" = 17477; #" = 0.188210
  "Mozilla/5.0+(iPhone;+CPU+iPhone+OS+7_1_1+like+Mac+OS+X)+AppleWebKit/537.51.2+(KHTML,+like+Gecko)+Version/7.0+Mobile/11D201+Safari/9537.53" = 17312; #" = 0.186433
  "Mozilla/5.0+(iPhone;+CPU+iPhone+OS+8_3+like+Mac+OS+X)+AppleWebKit/600.1.4+(KHTML,+like+Gecko)+GSA/5.2.43972+Mobile/12F70+Safari/600.1.4" = 16952; #" = 0.182556
  "AppManager+RPT-HTTPClient/0.3-3E" = 16664; #" = 0.179455
  "Mozilla/5.0+(Windows+NT+6.1;+WOW64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/41.0.2272.118+Safari/537.36" = 16237; #" = 0.174857
  "Mozilla/5.0+(Windows+NT+6.1;+WOW64;+rv:24.0;+GomezAgent+3.0)+Gecko/20100101+Firefox/24.0" = 15416; #" = 0.166015
  "Mozilla/5.0+(iPad;+CPU+OS+8_1+like+Mac+OS+X)+AppleWebKit/600.1.4+(KHTML,+like+Gecko)+Version/8.0+Mobile/12B410+Safari/600.1.4" = 15268; #" = 0.164421
  "Mozilla/5.0+(Windows+NT+6.0;+WOW64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/42.0.2311.135+Safari/537.36" = 15189; #" = 0.163571
  "Mozilla/5.0+(iPhone;+CPU+iPhone+OS+8_1+like+Mac+OS+X)+AppleWebKit/600.1.4+(KHTML,+like+Gecko)+Version/8.0+Mobile/12B411+Safari/600.1.4" = 14946; #" = 0.160954
  "Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10.10;+rv:37.0)+Gecko/20100101+Firefox/37.0" = 14878; #" = 0.160222
  "Mozilla/5.0+(Windows+NT+6.2;+WOW64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/42.0.2311.135+Safari/537.36" = 14785; #" = 0.159220
  "Mozilla/5.0+(Windows+NT+5.1;+rv:11.0)+Gecko+Firefox/11.0+(via+ggpht.com+GoogleImageProxy)" = 14628; #" = 0.157529
  "Mozilla/5.0+(iPhone;+CPU+iPhone+OS+8_3+like+Mac+OS+X)+AppleWebKit/600.1.4+(KHTML,+like+Gecko)+Mobile/12F70" = 14607; #" = 0.157303
  "Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_10_3)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/42.0.2311.135+Safari/537.36" = 14408; #" = 0.155160
  "Mozilla/5.0+(Linux;+Android+4.4.2;+en-us;+SAMSUNG+SCH-I545+Build/KOT49H)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Version/1.5+Chrome/28.0.1500.94+Mobile+Safari/537.36" = 14186; #" = 0.152769
  "Mozilla/5.0+(Windows+NT+6.3;+WOW64;+Trident/7.0;+TNJB;+rv:11.0)+like+Gecko" = 13952; #" = 0.150249
  "Mozilla/5.0+(Windows+NT+6.3;+Win64;+x64;+Trident/7.0;+Touch;+rv:11.0)+like+Gecko" = 13701; #" = 0.147546
  "Mozilla/5.0+(Linux;+Android+4.4.2;+en-us;+SAMSUNG+SM-G900T+Build/KOT49H)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Version/1.6+Chrome/28.0.1500.94+Mobile+Safari/537.36" = 12778; #" = 0.137607
  "Mozilla/5.0+(Windows+NT+6.1;+WOW64;+Trident/7.0;+MDDRJS;+rv:11.0)+like+Gecko" = 12653; #" = 0.136260
  "Mozilla/5.0+(compatible;+bingbot/2.0;++http://www.bing.com/bingbot.htm)" = 12455; #" = 0.134128
  "Mozilla/5.0+(Windows+NT+6.3;+WOW64;+Trident/7.0;+MDDCJS;+rv:11.0)+like+Gecko" = 12409; #" = 0.133633
  "Mozilla/5.0+(iPad;+CPU+OS+8_3+like+Mac+OS+X)+AppleWebKit/600.1.4+(KHTML,+like+Gecko)+GSA/5.2.43972+Mobile/12F69+Safari/600.1.4" = 12077; #" = 0.130057
  "Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_10_1)+AppleWebKit/600.2.5+(KHTML,+like+Gecko)+Version/8.0.2+Safari/600.2.5" = 11910; #" = 0.128259
  "Mozilla/5.0+(Windows+NT+6.1;+WOW64)+AppleWebKit/534.34+(KHTML,+like+Gecko)+PhantomJS/1.9.7+Safari/534.34" = 11889; #" = 0.128033
  "Mozilla/5.0+(iPhone;+CPU+iPhone+OS+8_0_2+like+Mac+OS+X)+AppleWebKit/600.1.4+(KHTML,+like+Gecko)+Version/8.0+Mobile/12A405+Safari/600.1.4" = 11777; #" = 0.126827
  "Mozilla/4.0+(compatible;+MSIE+7.0;+Windows+NT+6.1;+WOW64;+Trident/4.0;+SLCC2;+.NET+CLR+2.0.50727;+.NET4.0C;+.NET4.0E;+.NET+CLR+3.5.30729;+.NET+CLR+3.0.30729;+InfoPath.3)" = 11582; #" = 0.124727
  "Mozilla/4.0+(compatible;+MSIE+8.0;+Windows+NT+6.1;+Trident/4.0;+SLCC2;+.NET+CLR+2.0.50727;+.NET+CLR+3.5.30729;+.NET+CLR+3.0.30729;+Media+Center+PC+6.0;+.NET4.0C;+.NET4.0E)" = 11465; #" = 0.123467
  "Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_10_3)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/42.0.2311.90+Safari/537.36" = 10961; #" = 0.118039
  "Mozilla/5.0+(iPad;+CPU+OS+7_0_4+like+Mac+OS+X)+AppleWebKit/537.51.1+(KHTML,+like+Gecko)+Version/7.0+Mobile/11B554a+Safari/9537.53" = 10895; #" = 0.117328
  "Mozilla/5.0+(Windows+NT+6.3;+ARM;+Trident/7.0;+Touch;+rv:11.0)+like+Gecko" = 10862; #" = 0.116973
  "Mozilla/4.0+(compatible;+MSIE+8.0;+Windows+NT+6.1;+WOW64;+Trident/4.0;+SLCC2;+.NET+CLR+2.0.50727;+.NET+CLR+3.5.30729;+.NET+CLR+3.0.30729;+Media+Center+PC+6.0;+.NET4.0C;+.NET4.0E)" = 10807; #" = 0.116381
  "Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_9_5)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/42.0.2311.135+Safari/537.36" = 10801; #" = 0.116316
  "Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_9_5)+AppleWebKit/600.4.10+(KHTML,+like+Gecko)+Version/7.1.4+Safari/537.85.13" = 10631; #" = 0.114485
  "Mozilla/5.0+(iPad;+CPU+OS+7_1+like+Mac+OS+X)+AppleWebKit/537.51.2+(KHTML,+like+Gecko)+Version/7.0+Mobile/11D167+Safari/9537.53" = 10577; #" = 0.113904
  "Mozilla/5.0+(compatible;+MSIE+10.0;+Windows+NT+6.1;+Win64;+x64;+Trident/6.0)" = 10553; #" = 0.113645
  "Mozilla/5.0+(Windows+NT+6.3;+WOW64;+Trident/7.0;+MATBJS;+rv:11.0)+like+Gecko" = 10420; #" = 0.112213
  "Mozilla/5.0+(Linux;+Android+5.0;+SAMSUNG+SM-G900P+Build/LRX21T)+AppleWebKit/537.36+(KHTML,+like+Gecko)+SamsungBrowser/2.1+Chrome/34.0.1847.76+Mobile+Safari/537.36" = 10398; #" = 0.111976
  "Mozilla/5.0+(compatible;+MSIE+9.0;+Windows+NT+6.0;+WOW64;+Trident/5.0)" = 10381; #" = 0.111793
  "Mozilla/4.0+(compatible;+MSIE+7.0;+Windows+NT+6.1;+Trident/4.0;+SLCC2;+.NET+CLR+2.0.50727;+.NET+CLR+3.5.30729;+.NET+CLR+3.0.30729;+Media+Center+PC+6.0;+.NET4.0C;+.NET4.0E;+InfoPath.3;+Tablet+PC+2.0)" = 10352; #" = 0.111481
  "Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10.9;+rv:37.0)+Gecko/20100101+Firefox/37.0" = 10335; #" = 0.111298
  "Mozilla/5.0+(Windows+NT+6.1;+WOW64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/41.0.2272.101+Safari/537.36" = 9654; #" = 0.103964
  "Mozilla/5.0+(Windows+NT+6.0)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/42.0.2311.90+Safari/537.36" = 9641; #" = 0.103824
  "Mozilla/5.0+(iPad;+U;+CPU+OS+3_2+like+Mac+OS+X;+en-us)+AppleWebKit/531.21.10+(KHTML,+like+Gecko)+Version/4.0.4+Mobile/7B367+Safari/531.21.10" = 9590; #" = 0.103275
  "Mozilla/5.0+(compatible;+MSIE+9.0;+Windows+NT+6.2;+WOW64;+Trident/6.0)" = 9566; #" = 0.103016
  "Mozilla/5.0+(Windows+NT+6.3;+WOW64;+Trident/7.0;+MAGWJS;+rv:11.0)+like+Gecko" = 9509; #" = 0.102403
  "Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_9_5)+AppleWebKit/600.3.18+(KHTML,+like+Gecko)+Version/7.1.3+Safari/537.85.12" = 9431; #" = 0.101563
  "Mozilla/5.0+(iPad;+CPU+OS+8_1_1+like+Mac+OS+X)+AppleWebKit/600.1.4+(KHTML,+like+Gecko)+Version/8.0+Mobile/12B435+Safari/600.1.4" = 9348; #" = 0.100669
  "Mozilla/5.0+(Linux;+Android+4.4.4;+en-us;+SAMSUNG-SM-G900A+Build/KTU84P)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Version/1.6+Chrome/28.0.1500.94+Mobile+Safari/537.36" = 9067; #" = 0.097643
}


$browser_stats = @{
  'Internet Explorer 10' = 0;
  'Internet Explorer 11' = 0;
  'Internet Explorer 9' = 0;
  'Internet Explorer 8' = 0;
  'iPhone' = 0;
  'iPad' = 0;
  'Android' = 0;
  'Chrome' = 0;
  'Safari' = 0;
  'Fiefox' = 0;

}

$user_agent_stats.Keys | ForEach-Object {
  $ua = $_
  #  special signature of IE 11
  # "Mozilla/5.0+(Windows+NT+6.3;+WOW64;+Trident/7.0;+rv:11.0)+like+Gecko" = 165294;
  if ($ua -match 'Windows' -and $ua -match 'Trident' -and $ua -match 'rv:11.0' 
  ) {
    $browser = 'Internet Explorer 11'
    $browser_stats[$browser] += $user_agent_stats[$ua]
  }
  if ($ua -match 'MSIE[\s\+](\d+)'
  ) {
    $browser = ('Internet Explorer {0}' -f $matches[1] )
    $browser_stats[$browser] += $user_agent_stats[$ua]
  }

  if ($ua -match 'iPad'
  ) {
    $browser = 'iPad'
    $browser_stats[$browser] += $user_agent_stats[$ua]
  }
  if ($ua -match 'iPhone'
  ) {
    $browser = 'iPhone'
    $browser_stats[$browser] += $user_agent_stats[$ua]
  }
  if ($ua -match 'Android'
  ) {
    $browser = 'Android'
    $browser_stats[$browser] += $user_agent_stats[$ua]
  }

  if ($ua -match 'Macintosh'
  ) {
    $browser = 'Safari'
    $browser_stats[$browser] += $user_agent_stats[$ua]
  }


  if ($ua -match 'Chrome\/'
  ) {
    $browser = 'Chrome'
    $browser_stats[$browser] += $user_agent_stats[$ua]
  }

  if ($ua -match 'Fiefox\/'
  ) {
    $browser = 'Fiefox'
    $browser_stats[$browser] += $user_agent_stats[$ua]
  }

}
# http://blogs.technet.com/b/heyscriptingguy/archive/2014/09/28/weekend-scripter-sorting-powershell-hash-tables.aspx

$browser_stats.GetEnumerator()  |   Sort-Object -Property Value -Descending | format-table  -autosize 
