# uses console 
# technet.microsoft.com/en-us/library/ff730938.aspx
$host | get-member
#[System.Management.Automation.Internal.Host.InternalHost]$g = $host
$g = $host
$g.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") ; write-output $x

# TODO : draw a div with prompt on the page
<#
https://customer.onlinelic.in/ForgotPwd.htm
http://testing-ground.scraping.pro/captcha?fsubmit
http://scraping.pro/example-captcha-solver-java/
#>