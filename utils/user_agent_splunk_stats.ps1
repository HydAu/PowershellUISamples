<#

SPLUNK expression syntax;
index=iis_carnival |rex field=cs_User_Agent_ "^(?<cs_User_Agent_>.+)$"| rex "^(?:[\S]* ){4}(?<ua>.*)\s\w+$" | 
eval device = case( ua LIKE "%Chrome%", "Chrome", ua LIKE "%Trident/7.0;+rv:11.0%","Internet Explorer 11", ua LIKE "%iPhone;+CPU+iPhone+OS%","Apple iPhone (Safarai Mobile)" , ua like "%compatible;+MSIE+9.0%","Internet Explorer 9" , ua like "%MSIE+10.0%","Internet Explorer 10" , ua like "%MSIE+8.0%","Internet Explorer 8" , ua like "%Firefox%","FireFox", ua like "%Macintosh;+Intel+Mac+OS%","MAC OS X (Safari)", ua LIKE "%iPad;+CPU+OS%","Apple iPad", ua like "%Linux;+Android%","Android", ua like "%Trident/7.0;+Touch;+rv:11.0%","Windows Phone") | top 20 device
#>
# desired breakdown ?
# http://www.useragentstring.com/pages/Browserlist/
# Real SPLUNK data extract
$user_agent_stats = @{
  'Mozilla/5.0+(Windows+NT+6.1;+WOW64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/42.0.2311.135+Safari/537.36' = 717120;
  'Mozilla/5.0+(iPhone;+CPU+iPhone+OS+8_3+like+Mac+OS+X)+AppleWebKit/600.1.4+(KHTML,+like+Gecko)+Version/8.0+Mobile/12F70+Safari/600.1.4' = 315192;
  'Mozilla/5.0+(Windows+NT+6.1;+WOW64;+rv:37.0)+Gecko/20100101+Firefox/37.0' = 272816;
  'Mozilla/5.0+(compatible;+MSIE+9.0;+Windows+NT+6.1;+WOW64;+Trident/5.0)' = 272744;
  'Mozilla/5.0+(Windows+NT+6.1)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/42.0.2311.135+Safari/537.36' = 263093;
  'Mozilla/5.0+(Windows+NT+6.1;+Trident/7.0;+rv:11.0)+like+Gecko' = 218477;
  'Mozilla/5.0+(Windows+NT+6.1;+WOW64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/42.0.2311.90+Safari/537.36' = 198134;
  'Mozilla/5.0+(Windows+NT+6.3;+WOW64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/42.0.2311.135+Safari/537.36' = 197896;
  'Mozilla/4.0+(compatible;+MSIE+8.0;+Windows+NT+5.1;+Trident/4.0;+.NET+CLR+2.0.50727;+.NET+CLR+3.0.4506.2152;+.NET+CLR+3.5.30729;+.NET4.0C;+.NET4.0E)' = 177662;
  'Mozilla/5.0+(compatible;+MSIE+9.0;+Windows+NT+6.1;+Trident/5.0)' = 167908;
  'Mozilla/5.0+(iPad;+CPU+OS+8_3+like+Mac+OS+X)+AppleWebKit/600.1.4+(KHTML,+like+Gecko)+Version/8.0+Mobile/12F69+Safari/600.1.4' = 166785;
  'Mozilla/5.0+(Windows+NT+6.3;+WOW64;+Trident/7.0;+rv:11.0)+like+Gecko' = 165294;
  'Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_10_3)+AppleWebKit/600.5.17+(KHTML,+like+Gecko)+Version/8.0.5+Safari/600.5.17' = 142407;
  'Mozilla/5.0+(compatible;+MSIE+10.0;+Windows+NT+6.1;+WOW64;+Trident/6.0)' = 94165;
  'Mozilla/5.0+(compatible;+MSIE+9.0;+Windows+NT+6.1;+WOW64;+Trident/6.0)' = 85009;
  'Mozilla/5.0+(Windows+NT+6.3;+WOW64;+rv:37.0)+Gecko/20100101+Firefox/37.0' = 82726;
  'Mozilla/5.0+(Windows+NT+6.3;+WOW64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/42.0.2311.90+Safari/537.36' = 80491;
  'Mozilla/5.0+(Windows+NT+5.1)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/42.0.2311.135+Safari/537.36' = 78439;
  'Mozilla/5.0+(Windows+NT+6.1;+rv:37.0)+Gecko/20100101+Firefox/37.0' = 74326;
  'Mozilla/5.0+(Windows+NT+6.3;+WOW64;+Trident/7.0;+Touch;+rv:11.0)+like+Gecko' = 64661;
  'Mozilla/5.0+(Windows+NT+6.1)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/42.0.2311.90+Safari/537.36' = 58079;
  'Mozilla/5.0+(compatible;+MSIE+10.0;+Windows+NT+6.1;+Trident/6.0)' = 54829;
  'Mozilla/5.0+(iPhone;+CPU+iPhone+OS+8_2+like+Mac+OS+X)+AppleWebKit/600.1.4+(KHTML,+like+Gecko)+Version/8.0+Mobile/12D508+Safari/600.1.4' = 48476;
  'Mozilla/5.0+(Windows+NT+5.1;+rv:37.0)+Gecko/20100101+Firefox/37.0' = 46094;
  'Mozilla/5.0+(iPad;+CPU+OS+8_2+like+Mac+OS+X)+AppleWebKit/600.1.4+(KHTML,+like+Gecko)+Version/8.0+Mobile/12D508+Safari/600.1.4' = 44374;
  'Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_10_2)+AppleWebKit/600.4.10+(KHTML,+like+Gecko)+Version/8.0.4+Safari/600.4.10' = 43224;
  'Mozilla/5.0+(compatible;+MSIE+9.0;+Windows+NT+6.1;+Trident/6.0)' = 42106;
  'Mozilla/5.0+(iPhone;+CPU+iPhone+OS+8_1_3+like+Mac+OS+X)+AppleWebKit/600.1.4+(KHTML,+like+Gecko)+Version/8.0+Mobile/12B466+Safari/600.1.4' = 40628;
  'Mozilla/5.0+(iPad;+CPU+OS+7_1_2+like+Mac+OS+X)+AppleWebKit/537.51.2+(KHTML,+like+Gecko)+Version/7.0+Mobile/11D257+Safari/9537.53' = 39712;
  'Mozilla/4.0+(compatible;+MSIE+7.0;+Windows+NT+6.1;+Trident/4.0;+SLCC2;+.NET+CLR+2.0.50727;+.NET+CLR+3.5.30729;+.NET+CLR+3.0.30729;+Media+Center+PC+6.0;+.NET4.0C;+.NET4.0E;+InfoPath.3)' = 39417;
  'Mozilla/5.0+(iPhone;+CPU+iPhone+OS+7_1_2+like+Mac+OS+X)+AppleWebKit/537.51.2+(KHTML,+like+Gecko)+Version/7.0+Mobile/11D257+Safari/9537.53' = 39207; 
  'Mozilla/5.0+(iPhone;+CPU+iPhone+OS+8_1_2+like+Mac+OS+X)+AppleWebKit/600.1.4+(KHTML,+like+Gecko)+Version/8.0+Mobile/12B440+Safari/600.1.4' = 37600; 
  'Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_9_5)+AppleWebKit/600.5.17+(KHTML,+like+Gecko)+Version/7.1.5+Safari/537.85.14' = 34979; 
  'Screaming+Frog+SEO+Spider/3.1' = 34683;
  'Mozilla/5.0+(iPad;+CPU+OS+8_1_3+like+Mac+OS+X)+AppleWebKit/600.1.4+(KHTML,+like+Gecko)+Version/8.0+Mobile/12B466+Safari/600.1.4' = 33996; 
  'Mozilla/5.0+(Windows+NT+6.0)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/42.0.2311.135+Safari/537.36' = 32044; 
  'Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_10_2)+AppleWebKit/600.3.18+(KHTML,+like+Gecko)+Version/8.0.3+Safari/600.3.18' = 30909;
  'Mozilla/5.0+(compatible;+MSIE+9.0;+Windows+NT+6.0;+Trident/5.0)' = 29279; 
  'Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_6_8)+AppleWebKit/534.59.10+(KHTML,+like+Gecko)+Version/5.1.9+Safari/534.59.10' = 24928; 
  'Mozilla/5.0+(iPad;+CPU+OS+8_1_2+like+Mac+OS+X)+AppleWebKit/600.1.4+(KHTML,+like+Gecko)+Version/8.0+Mobile/12B440+Safari/600.1.4' = 24836; 
  'Mozilla/5.0+(Windows+NT+6.1;+WOW64;+rv:31.0)+Gecko/20100101+Firefox/31.0' = 23873; 
  'Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_7_5)+AppleWebKit/537.78.2+(KHTML,+like+Gecko)+Version/6.1.6+Safari/537.78.2' = 22975; 
  'Mozilla/5.0+(Windows+NT+6.0;+rv:37.0)+Gecko/20100101+Firefox/37.0' = 21988; 
  'Mozilla/5.0+(Windows+NT+5.1)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/42.0.2311.90+Safari/537.36' = 21068; 
  'Mozilla/5.0+(iPad;+CPU+OS+7_1_1+like+Mac+OS+X)+AppleWebKit/537.51.2+(KHTML,+like+Gecko)+Version/7.0+Mobile/11D201+Safari/9537.53' = 20777;
  'Mozilla/5.0+(Windows+NT+6.3;+Win64;+x64;+Trident/7.0;+rv:11.0)+like+Gecko' = 20447
  'Mozilla/5.0+(compatible;+MSIE+9.0;+Windows+NT+6.1;+Win64;+x64;+Trident/5.0)' = 20200;
  'Mozilla/5.0+(Linux;+Android+5.0;+SM-G900V+Build/LRX21T)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/42.0.2311.111+Mobile+Safari/537.36' = 20011; 
  'Mozilla/4.0+(compatible;+MSIE+8.0;+Windows+NT+6.1;+Trident/4.0;+SLCC2;+.NET+CLR+2.0.50727;+.NET+CLR+3.5.30729;+.NET+CLR+3.0.30729;+Media+Center+PC+6.0;+.NET4.0C;+.NET4.0E;+InfoPath.3)' = 18427; 
  'Mozilla/4.0+(compatible;+MSIE+8.0;+Windows+NT+6.1;+WOW64;+Trident/4.0;+SLCC2;+.NET+CLR+2.0.50727;+.NET+CLR+3.5.30729;+.NET+CLR+3.0.30729;+Media+Center+PC+6.0;+.NET4.0C;+.NET4.0E;+InfoPath.3)' = 17727; 
  'Mozilla/5.0+(Windows+NT+6.1;+Win64;+x64;+Trident/7.0;+rv:11.0)+like+Gecko' = 17477; 
  'Mozilla/5.0+(iPhone;+CPU+iPhone+OS+7_1_1+like+Mac+OS+X)+AppleWebKit/537.51.2+(KHTML,+like+Gecko)+Version/7.0+Mobile/11D201+Safari/9537.53' = 17312; 
  'Mozilla/5.0+(iPhone;+CPU+iPhone+OS+8_3+like+Mac+OS+X)+AppleWebKit/600.1.4+(KHTML,+like+Gecko)+GSA/5.2.43972+Mobile/12F70+Safari/600.1.4' = 16952; 
  'AppManager+RPT-HTTPClient/0.3-3E' = 16664; 
  'Mozilla/5.0+(Windows+NT+6.1;+WOW64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/41.0.2272.118+Safari/537.36' = 16237; 
  'Mozilla/5.0+(Windows+NT+6.1;+WOW64;+rv:24.0;+GomezAgent+3.0)+Gecko/20100101+Firefox/24.0' = 15416;
  'Mozilla/5.0+(iPad;+CPU+OS+8_1+like+Mac+OS+X)+AppleWebKit/600.1.4+(KHTML,+like+Gecko)+Version/8.0+Mobile/12B410+Safari/600.1.4' = 15268;
  'Mozilla/5.0+(Windows+NT+6.0;+WOW64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/42.0.2311.135+Safari/537.36' = 15189;
  'Mozilla/5.0+(iPhone;+CPU+iPhone+OS+8_1+like+Mac+OS+X)+AppleWebKit/600.1.4+(KHTML,+like+Gecko)+Version/8.0+Mobile/12B411+Safari/600.1.4' = 14946; 
  'Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10.10;+rv:37.0)+Gecko/20100101+Firefox/37.0' = 14878;
  'Mozilla/5.0+(Windows+NT+6.2;+WOW64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/42.0.2311.135+Safari/537.36' = 14785; 
  'Mozilla/5.0+(Windows+NT+5.1;+rv:11.0)+Gecko+Firefox/11.0+(via+ggpht.com+GoogleImageProxy)' = 14628; 
  'Mozilla/5.0+(iPhone;+CPU+iPhone+OS+8_3+like+Mac+OS+X)+AppleWebKit/600.1.4+(KHTML,+like+Gecko)+Mobile/12F70' = 14607; 
  'Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_10_3)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/42.0.2311.135+Safari/537.36' = 14408; 
  'Mozilla/5.0+(Linux;+Android+4.4.2;+en-us;+SAMSUNG+SCH-I545+Build/KOT49H)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Version/1.5+Chrome/28.0.1500.94+Mobile+Safari/537.36' = 14186; 
  'Mozilla/5.0+(Windows+NT+6.3;+WOW64;+Trident/7.0;+TNJB;+rv:11.0)+like+Gecko' = 13952; 
  'Mozilla/5.0+(Windows+NT+6.3;+Win64;+x64;+Trident/7.0;+Touch;+rv:11.0)+like+Gecko' = 13701; 
  'Mozilla/5.0+(Linux;+Android+4.4.2;+en-us;+SAMSUNG+SM-G900T+Build/KOT49H)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Version/1.6+Chrome/28.0.1500.94+Mobile+Safari/537.36' = 12778;
  'Mozilla/5.0+(Windows+NT+6.1;+WOW64;+Trident/7.0;+MDDRJS;+rv:11.0)+like+Gecko' = 12653; 
  'Mozilla/5.0+(compatible;+bingbot/2.0;++http://www.bing.com/bingbot.htm)' = 12455; 
  'Mozilla/5.0+(Windows+NT+6.3;+WOW64;+Trident/7.0;+MDDCJS;+rv:11.0)+like+Gecko' = 12409; 
  'Mozilla/5.0+(iPad;+CPU+OS+8_3+like+Mac+OS+X)+AppleWebKit/600.1.4+(KHTML,+like+Gecko)+GSA/5.2.43972+Mobile/12F69+Safari/600.1.4' = 12077; 
  'Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_10_1)+AppleWebKit/600.2.5+(KHTML,+like+Gecko)+Version/8.0.2+Safari/600.2.5' = 11910; 
  'Mozilla/5.0+(Windows+NT+6.1;+WOW64)+AppleWebKit/534.34+(KHTML,+like+Gecko)+PhantomJS/1.9.7+Safari/534.34' = 11889;
  'Mozilla/5.0+(iPhone;+CPU+iPhone+OS+8_0_2+like+Mac+OS+X)+AppleWebKit/600.1.4+(KHTML,+like+Gecko)+Version/8.0+Mobile/12A405+Safari/600.1.4' = 11777;
  'Mozilla/4.0+(compatible;+MSIE+7.0;+Windows+NT+6.1;+WOW64;+Trident/4.0;+SLCC2;+.NET+CLR+2.0.50727;+.NET4.0C;+.NET4.0E;+.NET+CLR+3.5.30729;+.NET+CLR+3.0.30729;+InfoPath.3)' = 11582;
  'Mozilla/4.0+(compatible;+MSIE+8.0;+Windows+NT+6.1;+Trident/4.0;+SLCC2;+.NET+CLR+2.0.50727;+.NET+CLR+3.5.30729;+.NET+CLR+3.0.30729;+Media+Center+PC+6.0;+.NET4.0C;+.NET4.0E)' = 11465; 
  'Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_10_3)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/42.0.2311.90+Safari/537.36' = 10961; 
  'Mozilla/5.0+(iPad;+CPU+OS+7_0_4+like+Mac+OS+X)+AppleWebKit/537.51.1+(KHTML,+like+Gecko)+Version/7.0+Mobile/11B554a+Safari/9537.53' = 10895; 
  'Mozilla/5.0+(Windows+NT+6.3;+ARM;+Trident/7.0;+Touch;+rv:11.0)+like+Gecko' = 10862; 
  'Mozilla/4.0+(compatible;+MSIE+8.0;+Windows+NT+6.1;+WOW64;+Trident/4.0;+SLCC2;+.NET+CLR+2.0.50727;+.NET+CLR+3.5.30729;+.NET+CLR+3.0.30729;+Media+Center+PC+6.0;+.NET4.0C;+.NET4.0E)' = 10807; 
  'Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_9_5)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/42.0.2311.135+Safari/537.36' = 10801; 
  'Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_9_5)+AppleWebKit/600.4.10+(KHTML,+like+Gecko)+Version/7.1.4+Safari/537.85.13' = 10631; 
  'Mozilla/5.0+(iPad;+CPU+OS+7_1+like+Mac+OS+X)+AppleWebKit/537.51.2+(KHTML,+like+Gecko)+Version/7.0+Mobile/11D167+Safari/9537.53' = 10577; 
  'Mozilla/5.0+(compatible;+MSIE+10.0;+Windows+NT+6.1;+Win64;+x64;+Trident/6.0)' = 10553; 
  'Mozilla/5.0+(Windows+NT+6.3;+WOW64;+Trident/7.0;+MATBJS;+rv:11.0)+like+Gecko' = 10420; 
  'Mozilla/5.0+(Linux;+Android+5.0;+SAMSUNG+SM-G900P+Build/LRX21T)+AppleWebKit/537.36+(KHTML,+like+Gecko)+SamsungBrowser/2.1+Chrome/34.0.1847.76+Mobile+Safari/537.36' = 10398;
  'Mozilla/5.0+(compatible;+MSIE+9.0;+Windows+NT+6.0;+WOW64;+Trident/5.0)' = 10381; 
  'Mozilla/4.0+(compatible;+MSIE+7.0;+Windows+NT+6.1;+Trident/4.0;+SLCC2;+.NET+CLR+2.0.50727;+.NET+CLR+3.5.30729;+.NET+CLR+3.0.30729;+Media+Center+PC+6.0;+.NET4.0C;+.NET4.0E;+InfoPath.3;+Tablet+PC+2.0)' = 10352; 
  'Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10.9;+rv:37.0)+Gecko/20100101+Firefox/37.0' = 10335; 
  'Mozilla/5.0+(Windows+NT+6.1;+WOW64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/41.0.2272.101+Safari/537.36' = 9654; 
  'Mozilla/5.0+(Windows+NT+6.0)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/42.0.2311.90+Safari/537.36' = 9641; 
  'Mozilla/5.0+(iPad;+U;+CPU+OS+3_2+like+Mac+OS+X;+en-us)+AppleWebKit/531.21.10+(KHTML,+like+Gecko)+Version/4.0.4+Mobile/7B367+Safari/531.21.10' = 9590; 
  'Mozilla/5.0+(compatible;+MSIE+9.0;+Windows+NT+6.2;+WOW64;+Trident/6.0)' = 9566; 
  'Mozilla/5.0+(Windows+NT+6.3;+WOW64;+Trident/7.0;+MAGWJS;+rv:11.0)+like+Gecko' = 9509; 
  'Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_9_5)+AppleWebKit/600.3.18+(KHTML,+like+Gecko)+Version/7.1.3+Safari/537.85.12' = 9431; 
  'Mozilla/5.0+(iPad;+CPU+OS+8_1_1+like+Mac+OS+X)+AppleWebKit/600.1.4+(KHTML,+like+Gecko)+Version/8.0+Mobile/12B435+Safari/600.1.4' = 9348; 
  'Mozilla/5.0+(Linux;+Android+4.4.4;+en-us;+SAMSUNG-SM-G900A+Build/KTU84P)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Version/1.6+Chrome/28.0.1500.94+Mobile+Safari/537.36' = 9067; 
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
  'Firefox' = 0;

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

  if ($ua -match 'Firefox\/' -or $ua -match 'Gecko\/' 
  ) {
    $browser = 'Firefox'
    $browser_stats[$browser] += $user_agent_stats[$ua]
  }

}
# http://blogs.technet.com/b/heyscriptingguy/archive/2014/09/28/weekend-scripter-sorting-powershell-hash-tables.aspx

$browser_stats.GetEnumerator()  |   Sort-Object -Property Value -Descending | format-table  -autosize 
