# http://blogs.technet.com/b/bspieth/archive/2013/02/19/configure-the-iis-6-smtp-server-with-wmi-and-powershell.aspx
# https://social.technet.microsoft.com/Forums/windowsserver/en-US/ee211ac0-a2d0-4c93-900b-ceb1d10dd554/powershell-script-to-change-smtp-configuration?prof=required
# http://blogs.technet.com/b/bspieth/archive/2013/02/19/configure-the-iis-6-smtp-server-with-wmi-and-powershell.aspx
# https://social.technet.microsoft.com/Forums/windowsserver/en-US/ee211ac0-a2d0-4c93-900b-ceb1d10dd554/powershell-script-to-change-smtp-configuration?prof=required


# NOTE: this script only displays the entries when they are configured. 
# As often with Active Directory the results on a vanilla or partically-configured system are not well defined as  the Active Directory may have a lot of entries missing 

# http://poshcode.org/1942
function assert {
  [CmdletBinding()]
  param(
    [Parameter(Position = 0,ParameterSetName = 'Script',Mandatory = $true)]
    [scriptblock]$Script,
    [Parameter(Position = 0,ParameterSetName = 'Condition',Mandatory = $true)]
    [bool]$Condition,
    [Parameter(Position = 1,Mandatory = $true)]
    [string]$message)

  $message = "ASSERT FAILED: $message"
  if ($PSCmdlet.ParameterSetName -eq 'Script') {
    try {
      $ErrorActionPreference = 'STOP'
      $success = & $Script
    } catch {
      $success = $false
      $message = "$message`nEXCEPTION THROWN: $($_.Exception.GetType().FullName)"
    }
  }
  if ($PSCmdlet.ParameterSetName -eq 'Condition') {
    try {
      $ErrorActionPreference = 'STOP'
      $success = $Condition
    } catch {
      $success = $false
      $message = "$message`nEXCEPTION THROWN: $($_.Exception.GetType().FullName)"
    }
  }

  # show_exception

  if (!$success) {

    $stack =  ("From:{0}`r`nScript:{1}`r`nLine:{2}`r`nFunction:{3}" -f $Script,(Get-PSCallStack)[1].ScriptName,(Get-PSCallStack)[1].ScriptLineNumber,(Get-PSCallStack)[1].FunctionName)
    Write-Host $message 
    Write-Host $stack

    if ($action -ne 'Ignore') {
      throw $message
    }
  }
}





$configuration_provider = get-wmiobject -namespace 'root/MicrosoftIISv2' -computername '.' -Query 'Select * from IIsSmtpServerSetting'

#
# assert -Script { ($configuration_provider.'Name'   -match 'SmtpSvc/1') } -Message "Unexpected moloe ${color}"
assert -Condition ($configuration_provider.'Name'   -match 'SmtpSvc/1') -Message "Unexpected color: ${color}" 
# quotes challenge 


$actual_value = $configuration_provider.'SmartHost'
$property = 'SmartHost'
$expected_value = 'dmz-smtp.carnival.com'
write-host -foregroundcolor 'green' "Probing ${property} to match ${expected_value}"
assert -Condition ($actual_value  -eq $expected_value) -Message "Unexpected '${property}': ${actual_value}"

$property = 'MasqueradeDomain'
$actual_value = $configuration_provider.'MasqueradeDomain'
$expected_value  =  'carnival.com'
write-host -foregroundcolor 'green' "Probing ${property} to match ${expected_value}"
assert -Condition ($actual_value  -eq $expected_value) -Message "Unexpected '${property}': ${actual_value}"


$property = "StartMode of 'SMTPSVC'"
$expected_value  =  'auto'
$actual_value =  (Get-WmiObject -Query 'Select StartMode From Win32_Service Where Name="SMTPSVC"').'StartMode'
write-host -foregroundcolor 'green' "Probing ${property} to match ${expected_value}"
assert -Condition ($actual_value  -eq $expected_value) -Message "Unexpected ${property}: ${actual_value}"


$property = 'FullyQualifiedDomainName'
$expected_value  =  $env:computername
$actual_value = $configuration_provider.'FullyQualifiedDomainName'
write-host -foregroundcolor 'green' "Probing ${property} to match ${expected_value}"
assert -Condition ($actual_value  -match $expected_value) -Message "Unexpected ${property}: ${actual_value}"



$property = 'Name'
$expected_value  =  'SmtpSvc'
$actual_value = $configuration_provider.'Name'
write-host -foregroundcolor 'green' "Probing ${property} to match ${expected_value}"
assert -Condition ($actual_value  -match $expected_value) -Message "Unexpected ${property}: ${actual_value}"

write-host -foregroundcolor 'green'  'Probing ADSI provider'
$name = $actual_value
try {
$SMTPServer = [ADSI]"IIS://localhost/${name}"
assert -Condition ($SMTPServer.Name  -ne  $null) -Message "issue with ADSI provider"
} catch [Exception] {
}
write-host -foregroundcolor 'green'  'All done'
return 


# http://blogs.technet.com/b/bspieth/archive/2013/02/19/configure-the-iis-6-smtp-server-with-wmi-and-powershell.aspx
# Set-Service "SMTPSVC" -StartupType Automatic -ErrorAction SilentlyContinue
