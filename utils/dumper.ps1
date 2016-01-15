# https://communities.vmware.com/docs/DOC-17938
# http://www.leeholmes.com/blog/2009/11/23/hex-dumper-in-powershell/
function Dumper {
	<#
	.SYNOPSIS  A nested hashtable/array Data Dumper for Powershell.
	.DESCRIPTION A Data Dumper for Powershell nested hashtable/array structures
	  similar to what Perl's Data::Dumper does. Traverses an arbitrarily deep,
	  nested [hashtable] and/or [array] tree. Output is a [string]ified
	  representation of the tree in native powershell format or optionally, in
	  perl's dumper format. Converts anything it finds ToString()s or
	  GetType().ToString() so it is not a full featured Freeze/Thaw type utility.
	  It does not handle circular references and you will end up stuck in an infinite
	  loop so keep this in mind. This has only been tested to work with PS v2.0
	  but probably works with earlier versions as well.
	.NOTES  Author:  Lance Braswell (http://www.linkedin.com/in/lancebraswell)
	  Twitter: @lance_braswell
	.PARAMETER AsPerl
	  When set, the output format is suitable for a perl eval "$string" operation.
	.PARAMETER ShowType
	  When set, the $Object.GetType().ToString() value of embedded objects is used
	  to represent them instead of the $Object.ToString() value.
	.EXAMPLE
	  PS> Dumper @(1,2,3,4)
	.EXAMPLE
	  PS> $array = @(1,2,3,4)
	  PS> Dumper $array
	.EXAMPLE
	  PS> $hash = @{ "a" = "1"; "arr1" = @{ "aye" = "ayeval"; "bee" = "beeval"; `
	                 "cee" = "ceeval" }; "c "= "3"; "arr2" = $array }
	  PS> Dumper $hash
	.EXAMPLE
	  PS> Connect-VIServer "myvc"
	  PS> Dumper @{ "vms" = @( Get-VM ); "datastores" = @( Get-Datastore ) }
	.EXAMPLE
	  Go from PS to PS:
	  PS> $string = Dumper @("zero","one","two",3,4)
	  PS> Invoke-Expression $string
	  PS> $VAR1[2]
      two
	.EXAMPLE
	  Go from PS to perl:
	  PS> Dumper -AsPerl @("zero","one","two",3,4) | `
	       perl.exe -e '$/=undef;$s=<>;$v=eval"$s";print $v->[2];'
	  two
	  PS> Dumper -AsPerl @("zero","one","two",3,4) | `
	       perl.exe -MData::Dumper -e '$/=undef;$s=<>;$v=eval"$s";print Dumper($v);'
	#>
	
	[CmdletBinding()]
	param(
	[parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
	[PSObject]$Object,
	[switch]$AsPerl   = $false,
	[switch]$ShowType = $false
	)
	
	# Seems strange not to declare. Must be a better way.
	$outputStrategy = $null
	
	# Note that there is some space formatting done in
	# here to balance things out.
	if ( $AsPerl ) {
		$outputStrategy = New-Object -TypeName PSObject -Property @{
			_assignStr      = ' = '
			_hashOpenStr    = '{'
			_hashCloseStr   = '}'
			_hashAssignStr  = ' => '
			_hashPairSepStr = ','
			_arrOpenStr     = '['
			_arrCloseStr    = ']'
			_arrSepStr      = ','
			_newlineStr     = "\\n"
		}
	} else { # AsPowershell format
		$outputStrategy = New-Object -TypeName PSObject -Property @{
			_assignStr      = ' = '
			_hashOpenStr    = '@{'
			_hashCloseStr   = ' }'
			_hashAssignStr  = ' = '
			_hashPairSepStr = ';'
			_arrOpenStr     = '@('
			_arrCloseStr    = ' )'
			_arrSepStr      = ','
			_newlineStr     = '``n'
		}
	}
	
	# Helper functions
	function _Get-Offset-String ( $offsetLen = 0, $char = " " ) {
		[string] $offsetStr = ""
		if ( $offsetLen -gt 0 ) {
			1..$offsetLen | %{ $offsetStr += $char }
		}
		return $offsetStr
	}
	
	# Note that $outputStrategy, $showType, and $AsPerl are set outside
	# and before this interior function is used. This recursive function
	# is entered as we descend into the tree. The recurse points are called
	# out in the comments below.
	function _Dumper-Recurse ( $Object ) {
	
		# This seems redundant but is done to compact the representations
		# of the output strategy below. Hopefully at a small penalty of speed
		# and memory usage.
		$assignStr      = $outputStrategy._assignStr
		$hashOpenStr    = $outputStrategy._hashOpenStr
		$hashCloseStr   = $outputStrategy._hashCloseStr
		$hashAssignStr  = $outputStrategy._hashAssignStr
		$hashPairSepStr = $outputStrategy._hashPairSepStr
		$arrOpenStr     = $outputStrategy._arrOpenStr
		$arrCloseStr    = $outputStrategy._arrCloseStr
		$arrSepStr      = $outputStrategy._arrSepStr
		$newlineStr     = $outputStrategy._newlineStr
	
		[string] $dumperStr = ""
		$offsetLen          = 0

		# Note that a PS switch statement is not suitable for this because
		# of how it works with [array]s. switch ( $Object ) will enumerate
		# an $Oject of type [array] such that it's not possible to use
		# $Object.GetType() or '-is' to evaluate it in the switch.
		# Also note the use of `n throughout to carve up our output.
	
		# Hashtable
		if ( $Object -is [hashtable] ) {
	
			$dumperStr += $hashOpenStr + "`n"
			$offsetLen += $hashOpenStr.Length
			$offsetStr  = _Get-Offset-String $offsetLen
		
			foreach ( $pair in $Object.GetEnumerator() ){
				$dumperStr    += $offsetStr + "'$( $pair.Key )'" + $hashAssignStr
				$offsetKeyLen  = $offsetLen + ("'$( $pair.Key )'" + $hashAssignStr).Length
				$offsetKeyStr  = _Get-Offset-String $offsetKeyLen
				
				# Recursion is here
				$childStr = _Dumper-Recurse $pair.Value
				
				# Add in current offset from this level
				$childArr   = [regex]::Split($childStr, "`n")
				$childStr   = [string]::Join("`n$( $offsetKeyStr )", $childArr)
				$dumperStr += $childStr + $hashPairSepStr + "`n"
			}
			# Except remove the trailing SepStr if present
			$dumperStr = [regex]::Replace($dumperStr, "$hashPairSepStr`n$", "`n")
			$dumperStr += $hashCloseStr
			
		# Array
		} elseif ( $Object -is [array] ) {
			
			$dumperStr += $arrOpenStr + "`n"
			$offsetLen += $arrOpenStr.Length
			$offsetStr  = _Get-Offset-String $offsetLen
			
			foreach ( $value in $Object.GetEnumerator() ) {
				# Recursion is here
				$childStr   = _Dumper-Recurse $value
			
				# Add in current offset from this level
				$childArr   = [regex]::Split($childStr, "`n")
				$childStr   = [string]::Join("`n$( $offsetStr )", $childArr)
				$dumperStr += $offsetStr + $childStr + $arrSepStr + "`n"
			}
			# Except remove the trailing SepStr if present
			$dumperStr  = [regex]::Replace($dumperStr, "$arrSepStr`n$", "`n")
			$dumperStr += $arrCloseStr
			
		# Otherwise represent $Object as a string or type.
		} else {
			[string] $objectStr = ""
			if ( $showType ) {
				try {
					$objectStr = $Object.GetType().ToString()
				}
				# Not sure about this one
				catch {
					$objectStr = "`$null"
				}
			} else {	
				try {
					$objectStr = $Object.ToString()
				}
				catch {
					try {
						$objectStr = $Object.GetType().ToString()
					}
					# catch all is here. Only thing I can figure is it must
					# be the $null object at this point.
					catch {
						$objectStr = "`$null"
					}
				}
			}
			# Since we are relying on '`n' to nest our recursions, we better
			# escape that in case there are any embedded instances in our data.
			$objectStr  = [regex]::Replace($objectStr, "`n", $newlineStr)
			$dumperStr += "'$( $objectStr )'"
		}
		# Payload
		return $dumperStr
	}
	
	## Main ##
	
	# Homage to Perl
	$startStr = "`$VAR1 =";
	
	# Recursively build our $dumperStr string
	[string] $dumperStr = _Dumper-Recurse $Object
	
	return "$( $startStr )`n" + $dumperStr + "`n"
}

## Some "unit testing". Uncomment Block everything from this line to the end and put
## it in a separate script or paste it in to a window with Dumper.psm1 loaded.
## The names below are made up. You will want to use your own VC for
## Connect-VIServer of course.
#
#Connect-VIServer -Server sjc-vc1 | Out-Null
#
#"Creating an `$array with embedded newlines" | Out-Host
#$array = 1,2,"A string with`nsome embedded newlines`n",4,5
#"Dumper it as PS:" | Out-Host
#Dumper $array
#
#"Taking same `$array, Dumper it as PS, then use Invoke-Expression to go from a `$string back to PS" | Out-Host
#$string = Dumper $array
#"`$string is of Type:" | Out-Host
#$string.GetType()
#Invoke-Expression $string
#"IEX'd `$string"
#"`$VAR1 is of Type:" | Out-Host
#$VAR1.GetType()
#"`$VAR1 looks like:" | Out-Host
#$VAR1
#
#"Creating a `$hash with a nested hash and a nested `$array from above" | Out-Host 
#$hash = @{ "a" = "1"; `
#           "baby" = @{ aye = "ayeval"; 
#		               beeeeeeee = "beeval"; `
#                       "cee" = "ceeval" }; `
#           c = "3"; d = $array }
#		
#"Dumper it as PS:" | Out-Host
#Dumper $hash
#
#"Creating an AofHofA and AofA" | Out-Host
#$array2 = @( $hash, 2, 3, 4, $array )
#
#"Dumper it as PS:" | Out-Host
#Dumper $array2
#
#"Dumper it as Perl:" | Out-Host
#Dumper -AsPerl $array2
#
#"Use PowerCLI to build a tree of VMs and Datastores" | Out-Host
#
#"Dumper it as PS:" | Out-Host
#Dumper @{ "vms" = @( Get-VM ); "datastores" = @( Get-Datastore ) }
#
#"Dumper it as Perl:" | Out-Host
#Dumper -AsPerl @{ "vms" = @( Get-VM ); "datastores" = @( Get-Datastore ) }
#
#"Dumper it as Perl, eval `"`$string`" it with perl, use perl's Data::Dumper to examine it. Compare with the above:" | Out-Host
#Dumper -AsPerl @{ "vms" = @( Get-VM ); "datastores" = @( Get-Datastore ) } `
#	| perl.exe -MData::Dumper -e '$/=undef;$s=<>;$v=eval"$s";print Dumper($v);'
#
## Unit testing output from the above:
#@"
#Creating an $array with embedded newlines
#Dumper it as PS:
#$VAR1 =
#@(
#  '1',
#  '2',
#  'A string with``nsome embedded newlines``n',
#  '4',
#  '5'
# )
#
#Taking same $array, Dumper it as PS, then use Invoke-Expression to go from a $string back to PS
#$string is of Type:
#
#IsPublic IsSerial Name                                     BaseType
#-------- -------- ----                                     --------
#True     True     String                                   System.Object
#IEX'd $string
#$VAR1 is of Type:
#True     True     Object[]                                 System.Array
#$VAR1 looks like:
#1
#2
#A string with``nsome embedded newlines``n
#4
#5
#Creating a $hash with a nested hash and a nested $array from above
#Dumper it as PS:
#$VAR1 =
#@{
#  'a' = '1';
#  'c' = '3';
#  'd' = @(
#          '1',
#          '2',
#          'A string with``nsome embedded newlines``n',
#          '4',
#          '5'
#         );
#  'baby' = @{
#             'aye' = 'ayeval';
#             'cee' = 'ceeval';
#             'beeeeeeee' = 'beeval'
#            }
# }
#
#Creating an AofHofA and AofA
#Dumper it as PS:
#$VAR1 =
#@(
#  @{
#    'a' = '1';
#    'c' = '3';
#    'd' = @(
#            '1',
#            '2',
#            'A string with``nsome embedded newlines``n',
#            '4',
#            '5'
#           );
#    'baby' = @{
#               'aye' = 'ayeval';
#               'cee' = 'ceeval';
#               'beeeeeeee' = 'beeval'
#              }
#   },
#  '2',
#  '3',
#  '4',
#  @(
#    '1',
#    '2',
#    'A string with``nsome embedded newlines``n',
#    '4',
#    '5'
#   )
# )
#
#Dumper it as Perl:
#$VAR1 =
#[
# {
#  'a' => '1',
#  'c' => '3',
#  'd' => [
#          '1',
#          '2',
#          'A string with\\nsome embedded newlines\\n',
#          '4',
#          '5'
#         ],
#  'baby' => {
#             'aye' => 'ayeval',
#             'cee' => 'ceeval',
#             'beeeeeeee' => 'beeval'
#            }
# },
# '2',
# '3',
# '4',
# [
#  '1',
#  '2',
#  'A string with\\nsome embedded newlines\\n',
#  '4',
#  '5'
# ]
#]
#
#Use PowerCLI to build a tree of VMs and Datastores
#Dumper it as PS:
#$VAR1 =
#@{
#  'datastores' = @(
#                   'sjc-1-vmhost-template',
#                   'sjc-1-vmhost-nfs5',
#                   'sjc-1-vmhost-nfs4',
#                   'sjc-1-vmhost-nfs3',
#                   'sjc-1-vmhost-nfs2',
#                   'sjc-1-vmhost-nfs1',
#                   'sjc-1-vmhost-8-local',
#                   'sjc-1-vmhost-7-local',
#                   'sjc-1-vmhost-6-local',
#                   'sjc-1-vmhost-5-local',
#                   'sjc-1-vmhost-4-local',
#                   'sjc-1-vmhost-3-local',
#                   'sjc-1-vmhost-1-local'
#                  );
#  'vms' = @(
#            'sjc-vm-001',
#            'sjc-vm-002',
#            'sjc-vm-003',
#            'sjc-vm-004',
#            'sjc-vm-005',
#            'sjc-vm-006',
#            'sjc-vm-007'
#           )
# }
#
#Dumper it as Perl:
#$VAR1 =
#{
# 'datastores' => [
#                  'sjc-1-vmhost-template',
#                  'sjc-1-vmhost-nfs5',
#                  'sjc-1-vmhost-nfs4',
#                  'sjc-1-vmhost-nfs3',
#                  'sjc-1-vmhost-nfs2',
#                  'sjc-1-vmhost-nfs1',
#                  'sjc-1-vmhost-8-local',
#                  'sjc-1-vmhost-7-local',
#                  'sjc-1-vmhost-6-local',
#                  'sjc-1-vmhost-5-local',
#                  'sjc-1-vmhost-4-local',
#                  'sjc-1-vmhost-3-local',
#                  'sjc-1-vmhost-1-local'
#                 ],
# 'vms' => [
#           'sjc-vm-001',
#           'sjc-vm-002',
#           'sjc-vm-003',
#           'sjc-vm-004',
#           'sjc-vm-005',
#           'sjc-vm-006',
#           'sjc-vm-007'
#          ]
#}
#
#Dumper it as Perl, eval "$string" it with perl, use perl's Data::Dumper to examine it. Compare with the above:
#$VAR1 = {
#          'datastores' => [
#                            'sjc-1-vmhost-template',
#                            'sjc-1-vmhost-nfs5',
#                            'sjc-1-vmhost-nfs4',
#                            'sjc-1-vmhost-nfs3',
#                            'sjc-1-vmhost-nfs2',
#                            'sjc-1-vmhost-nfs1',
#                            'sjc-1-vmhost-8-local',
#                            'sjc-1-vmhost-7-local',
#                            'sjc-1-vmhost-6-local',
#                            'sjc-1-vmhost-5-local',
#                            'sjc-1-vmhost-4-local',
#                            'sjc-1-vmhost-3-local',
#                            'sjc-1-vmhost-1-local'
#                          ],
#          'vms' => [
#                     'sjc-vm-001',
#                     'sjc-vm-002',
#                     'sjc-vm-003',
#                     'sjc-vm-004',
#                     'sjc-vm-005',
#                     'sjc-vm-006',
#                     'sjc-vm-007'
#                   ]
#        };
#
#
#PS E:\lbraswel>
#"@ > Out-Null
