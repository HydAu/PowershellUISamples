# http://knowledgeoftheday001.blogspot.com/2013/05/powershell-get-credential-at-command.html

[bool]$status = $true
[string]$path = '/SOFTWARE/Microsoft/PowerShell/1/ShellIds'
[string]$hive = 'HKLM:'
[string]$name = 'ConsolePrompting'

pushd $hive
cd $path
try {
  $result = Get-ItemProperty -Name $name -Path ('{0}/{1}' -f $hive,$path) -ErrorAction 'SilentlyContinue'
  # $result
} catch [exception]{
  Write-Host '!'
  Write-Host $_.Exception.Message
  $status = $false

}

if (-not $status) {
  New-ItemProperty -Value $true -Name $name -Path ('{0}/{1}' -f $hive,$path) -ErrorAction 'SilentlyContinue'
}

if ($status) {
  # $result.ToString()
  [string]$ConsolePrompting = $null
  try {
    $ConsolePrompting = $result.ConsolePrompting
  } catch [exception]{

  }
  if (($ConsolePrompting -ne $null) -and ($ConsolePrompting -ne '')) {
    Write-Output ('$ConsolePrompting :  {0}' -f $ConsolePrompting)
  } else {
    Write-Host ('Property does not exist or value is blank')
    New-ItemProperty -Value $true -Name $name -Path ('{0}/{1}' -f $hive,$path)
    # New-ItemProperty : Requested registry access is not allowed.
    Get-Credential -Message 'Test' -UserName 'sergueik'
    Remove-ItemProperty -Name $name -Path ('{0}/{1}' -f $hive,$path) -ErrorAction 'SilentlyContinue'

  }
}
if (-not $status) {
  Remove-ItemProperty -Name $name -Path ('{0}/{1}' -f $hive,$path) -ErrorAction 'SilentlyContinue'
}

popd

# get-credential -Message 'Test' -username 'sergueik'
