# http://msdn.microsoft.com/en-us/library/dd233102%28v=vs.110%29.aspx
# How? set the SkipVerificationInFullTrust property to true in the SecurityRulesAttribute attribute
if ($host.Version.Major -gt 2) {
  
  Write-Host -ForegroundColor 'Yellow' @"
    This code onky Works in W2K3 and below.
    On W7 and further the following exception is thrown
    Exception calling "Replace" with "2" argument(s): 
    "Attempt by security transparent method 'DynamicClass.(System.Management.Automation.ScriptBlock, System.Text.RegularExpressions.Match)' to access security critical type 'System.Management.Automation.ScriptBlock' failed.
    
"@
  Write-Host -ForegroundColor 'Green' 'http://msdn.microsoft.com/en-us/library/dd233102%28v=vs.110%29.aspx'
  return
}

$DebugPreference = 'Continue'
# http://msdn.microsoft.com/en-us/library/system.text.regularexpressions.matchevaluator%28v=vs.110%29.aspx
$delegate = ./get-delegate `
   System.Text.RegularExpressions.MatchEvaluator ([System.Management.Automation.ScriptBlock]{
    # Return a replacement for the matching string...
    "<$($args[0].ToString().ToUpper())>"
    # and count the number of replacements...
    $global:PatternCount++
  })
$global:PatternCount = 0
$re = New-Object System.Text.RegularExpressions.Regex ('s[a-z]')

'Lorem ipsum dolor sit amet, consectetur adipisicing elit' | ForEach-Object { $re.Replace($_,$delegate) }

Write-Output ("Number of replacements:{0}" -f $PatternCount)

# http://seleniumdotnet.blogspot.com/2012/01/wait-for-element-to-load-in-selenium.html
# http://relevantcodes.com/selenium-findelementex-and-iselementpresent/
