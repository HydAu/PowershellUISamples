
@('Projects','Portals','SitecoreCMS','Jobs','Backups','Staging')  | foreach-object { $path = $_ ; (get-acl -path ('E:\{0}' -f $path) ).Access | where-object {$_.IdentityReference -match 'CARNIVAL\\_msdeploy' }}

# Setting might be also easy http://technet.microsoft.com/en-us/library/hh849810.aspx ,




# http://blogs.technet.com/b/heyscriptingguy/archive/2011/11/26/use-powershell-to-find-out-who-has-permissions-to-a-share.aspx
# http://technet.microsoft.com/en-us/magazine/2008.02.powershell.aspx
$share = 'Projects'
$query = "Associators of {win32_LogicalShareSecuritySetting='$share'}  Where resultclass = win32_sid"



 ( ( Get-WmiObject -Query $query -computername $env:computername) | where-object {$_.AccountName -match '_uatmsdeploy'} ).BinaryRepresentation
