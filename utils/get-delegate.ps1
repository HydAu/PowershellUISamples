<#

$delegate = ./get-delegate `
System.Text.RegularExpressions.MatchEvaluator {
    # Return a replacement for the matching string...
    "<$($args[0].ToString().ToLower())>"
    # and count the number of replacements...
    $global:PatternCount++
}
 
$re = [regex] "[A-Z]"
 
# now transform some text...
 
write-debug $delegate
# testing ...
'Lorem ipsum dolor sit amet, consectetur adipisicing elit'  |
   %{ $re.Replace($_, $delegate) }

## Exception calling "Replace" with "2" argument(s): 
## "Attempt by security transparent method 
## 'DynamicClass.(System.Management.Automation.ScriptBlock, System.Text.RegularExpressions.Match)' 
## to access security critical type 
## 'System.Management.Automation.ScriptBlock' failed.


 
# And display the number of replacements that were done...
"`nNumber of replacements: $PatternCount"
#>
param(
  [type]$type,# TODO Type Assertions 
  [scriptblock]$scriptBlock)

# http://blogs.msdn.com/b/powershell/archive/2006/07/25/678259.aspx
# this is script source call  design 


$DebugPreference = 'Continue'
# Helper function to emit an IL opcode
function emit ($opcode)
{
  if (-not ($op = [System.Reflection.Emit.OpCodes]::($opcode)))
  {
    throw "new-method: opcode '$opcode' is undefined"
  }

  if ($args.Length -gt 0)
  {
    $ilg.Emit($op,$args[0])
  }
  else
  {
    $ilg.Emit($op)
  }
}

# Get the method info for this delegate invoke...
Write-Debug $type.GetTYpe()
$delegateInvoke = $type.GetMethod("Invoke")


Write-Debug $delegateInvoke
# Get the argument type signature for the delegate invoke
$parameters = @( $delegateInvoke.GetParameters())
$returnType = $delegateInvoke.ReturnParameter.ParameterType

Write-Debug $returnType

$argList = New-Object Collections.ArrayList
[void]$argList.Add([scriptblock])
foreach ($p in $parameters) { [void]$argList.Add($p.ParameterType) }

$dynMethod = New-Object -TypeName 'System.Reflection.Emit.DynamicMethod' -ArgumentList @( "",$returnType,$argList.ToArray(),[object],$false)

Write-Debug $dynMethod

$ilg = $dynMethod.GetILGenerator()

# Place the scriptblock on the stack for the method call
# 
emit -opcode 'Ldarg_0'

emit -opcode 'Ldc_I4' ($argList.Count - 1) # Create the parameter array
emit -opcode 'Newarr' ([object])


for ($opCount = 1; $opCount -lt $argList.Count; $opCount++)
{
  emit -opcode 'Dup' # Dup the array reference
  emit -opcode 'Ldc_I4' ($opCount - 1); # Load the index
  emit -opcode 'Ldarg' $opCount # Load the argument
  if ($argList[$opCount].IsValueType) # Box if necessary
  {
    emit -opcode 'Box'
  }
  emit -opcode 'Stelem' ([object]) # Store it in the array
}

# Now emit the call to the ScriptBlock invoke method

Write-Debug '1'


# http://msdn.microsoft.com/en-us/library/system.	management.automation.scriptblock.invokereturnasis(v=vs.85).aspx
# 
emit -opcode 'Call' ([System.Management.Automation.ScriptBlock].GetMethod("InvokeReturnAsIs"))


if ($returnType -eq [void])
{
  # If the return type is void, pop the returned object
  emit -opcode 'Pop'
}

else
{
  # http://msdn.microsoft.com/en-us/library/System.Reflection.Emit.TypeBuilder.GetMethod(v=vs.100).aspx
  # Otherwise emit code to convert the result type which looks
  # like LanguagePrimitives.ConvertTo(value, type)
  # http://msdn.microsoft.com/en-us/library/system.management.automation.languageprimitives.convertto(v=vs.85).aspx
  $signature = [object],[type]
  # $convertMethod = [Management.Automation.LanguagePrimitives].GetMethod("ConvertTo",$signature) 
  $convertMethod = [Management.Automation.LanguagePrimitives].GetMethod("ConvertTo",[type[]]@( [object],[type]))
  $GetTypeFromHandle = [type].GetMethod("GetTypeFromHandle");
  emit -opcode 'Ldtoken' $returnType # And the return type token...
  emit -opcode 'Call' $GetTypeFromHandle
  emit -opcode 'Call' $convertMethod
}


emit -opcode 'Ret'

#
# Now return a delegate from this dynamic method...
#

$dynMethod.CreateDelegate($type,$scriptBlock)
# http://stackoverflow.com/questions/5530522/provide-a-net-method-as-a-delegate-callback
# https://social.technet.microsoft.com/Forums/windowsserver/en-US/399493e0-76c1-41a0-8e2c-320d98c2fdd1/powershell-how-to-create-a-delegate?forum=winserverpowershell

