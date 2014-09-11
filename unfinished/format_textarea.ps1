<#
$env:ENVIRONMENT='DEV'
$env:build_log = 'test.properties'
$DebugPreference = 'Continue';
#>
param (

  [string] $environment_variable_name = ''  ,
  [String] $build_log = '' 
  # use no-colliding $build_log name
)


if ($build_log -eq '') {
  $build_log = $env:BUILD_LOG
}

if ($environment_variable_name -eq '') {
  $environment_variable_name = $env:ENVIRONMENT_VARIABLE_NAME
}

# Handle debug flag 
[string]$debug_flag = '' 
if (($env:DEBUG -ne '') -and ($env:DEBUG -ne $null) -and ($env:DEBUG -match 'true'))  {
$debug_flag = '-debug'
$DebugPreference = 'Continue'
}

function write_variable  {

param (
       [string] $variable_name, 
       [System.Management.Automation.PSReference] $variable_ref, 
       [string] $build_log 
 )

try {
  $data = ''
  write-debug ( 'variable type = {0}' -f ( $variable_ref.Value.GetType() ) )
if ($variable_ref.Value.GetType() -match 'Object\[\]') {
  $data = ($variable_ref.Value -join ',')
} else  {
  $data = $variable_ref.Value
}

write-output ('{0}={1}' -f $variable_name,  $data) | out-file -FilePath $build_log -Encoding ascii -Force -append
} catch [InvalidArgumentExcdption] {

}

}

pushd env:
[string]$environment_variable = (
 dir | where-object {$_.name -match $environment_variable_name }  | select-object -property Value ).Value
popd 
write-output "Processing ${environment_variable_name} build parameter (raw):`n`n-------`n${environment_variable}`n-------`n"



$status_codes_formatted = ($environment_variable -replace "`n", ',') 
write-output "[1]Collapsed Lines:""${status_codes_formatted}"""


if ($status_codes_formatted -match ( "{0}='(.+)'" -f $environment_variable_name )) {
$regex = new-object System.Text.RegularExpressions.Regex(("({0})=`'(.+)`'" -f $environment_variable_name ))
$result = ($regex.Match($status_codes_formatted)).Groups[2]
$status_codes_formatted = $result.Value
}

write-output "[2]Sanitized:""${status_codes_formatted}"""

$status_codes_formatted = $status_codes_formatted -replace ',,' , ','
$status_codes_formatted = $status_codes_formatted -replace ",$" , ''

write-output "[3]Removed blanks:""${status_codes_formatted}"""


write_variable $environment_variable_name ( [ref]$status_codes_formatted ) $build_log
exit 0
