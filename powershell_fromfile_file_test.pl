use Net::SSH::Perl;
use Data::Dumper;

my $hostname = '192.168.56.101';
my $username = 'bitnami';
my $password = 'bayview_123';
$hostname = '192.168.56.102';
$username = 'cyg_server';

my $shell_command = <<'END_COMMAND';
#################################
# BEGIN OF CYGWIN SHELL COMMAND #
#################################
if [ -e '/cygdrive/c/Windows/system32/WindowsPowerShell/v1.0/PowerShell.exe' ]
then

# Generate the Powershell script to run under PowerShell.exe

# NOTE http://ss64.com/ps/set-executionpolicy.html
# The default execution policy of PowerShell seems to be Restricted, meaning it won't run any script files 
# it is limited to just an interactive command console. 
# If the 'Turn on Script Exe ution' group policy is set to 'Not Configured' one can
# pass  the -ExecutionPolicy option to modify the setting for the session.
# However  if the group policy is set, overriding it won't be possible.
#


cat << END_POWERSHELL_SCRIPT  > /cygdrive/c/Users/Administrator/Desktop/powershell_command_check.$$.ps1
##############################
# BEGIN OF POWERSHELL  SCRIPT#
##############################

write-output "Starting with installig a big module" 
import-module WebAdministration
write-output "Continue after installig a big module" 
Get-Website -Name "Default Web Site"

# Confirm the Provider  allows navigation in IIS namespace
pushd "IIS:\\Sites\\Default Web Site"

\$WebSiteAlias = "Test"
\$IISPath = "..\\\$WebSiteAlias"

if (Test-Path \$IISPath) { Write-Host "Web Site '\$WebSiteAlias' exists." }

\$IISPath = "IIS:\\AppPools"
cd \$IISPath
\$AppPoolAlias  = "Test" 
if (Test-Path ".\\\$AppPoolAlias") { Write-Host "Application Pool '\$AppPoolAlias'  exists." }

##############################
# END OF POWERSHELL  SCRIPT  #
##############################


END_POWERSHELL_SCRIPT

echo Invoking powershell.exe to run a provided powershell script  on windows host

/cygdrive/c/Windows/system32/WindowsPowerShell/v1.0/PowerShell.exe -ExecutionPolicy RemoteSigned -File "c:\\Users\\Administrator\\Desktop\\powershell_command_check.$$.ps1"

# 
else
echo The PowerShell is not installed on this  windows host 
fi

#################################
# END OF CYGWIN SHELL COMMAND   #
#################################

END_COMMAND

my $ssh_command = '/bin/bash -s';
my $ssh = Net::SSH::Perl->new( $hostname, debug => 0 );
$ssh->login( $username, $password );

my ( $stdout, $stderr, $exitcode ) = $ssh->cmd( $ssh_command, $shell_command );
print STDERR Dumper \[ $stdout, $stderr, $exitcode ];

1;

__END__


