  if ($host.Version.Major -gt 2) {
    Write-Host @"
This code onky Works in W2K3 and below.
On W7 and further the following exception is thrown
Exception calling "Replace" with "2" argument(s): 
"Attempt by security transparent method 'DynamicClass.(System.Management.Automation.ScriptBlock, System.Text.RegularExpressions.Match)' to access security critical type 'System.Management.Automation.ScriptBlock' failed.
"@
return
  }
$DebugPreference = 'Continue'

$delegate = ./get-delegate `
System.Text.RegularExpressions.MatchEvaluator ([System.Management.Automation.ScriptBlock]{
    # Return a replacement for the matching string...
    "<$($args[0].ToString().ToUpper())>"
    # and count the number of replacements...
    $global:PatternCount++
})
$global:PatternCount = 0 
$re = new-object System.Text.RegularExpressions.Regex( 's[a-z]' )
  
'Lorem ipsum dolor sit amet, consectetur adipisicing elit' | foreach-object { $re.Replace($_, $delegate) }

write-output ("Number of replacements:{0}" -f $PatternCount )
