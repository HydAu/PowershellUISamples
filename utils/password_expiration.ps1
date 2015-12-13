# https://social.technet.microsoft.com/Forums/windows/en-US/e4e96a5e-3b28-4673-8c61-d4abdf8f2426/win-7-setting-the-option-password-never-expires-for-a-specific-local-user?forum=winserverpowershell 
$username = 'vagrant'
# http://virtualization.modern.ie/vhd/virtualmachine_instructions.pdf
$o = [adsi]"WinNT://${env:computername}/${username}"
$o.UserFlags.value = $o.UserFlags.value -bor 0x10000
$o.CommitChanges()
