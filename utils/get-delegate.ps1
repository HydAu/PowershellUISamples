# http://blogs.msdn.com/b/powershell/archive/2006/07/25/678259.aspx
# Alternatives 
# http://stackoverflow.com/questions/5530522/provide-a-net-method-as-a-delegate-callback
# https://social.technet.microsoft.com/Forums/windowsserver/en-US/399493e0-76c1-41a0-8e2c-320d98c2fdd1/powershell-how-to-create-a-delegate?forum=winserverpowershell

param(
  [type]$for_type,# TODO Type Assertions 
  [scriptblock]$scriptBlock)

# Helper function to emit an IL opcode
function emit ($opcode)
{
  # Verify  if the opcode is a valid IL
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

# Get the method info for this type
# http://msdn.microsoft.com/en-us/library/system.delegate_methods%28v=vs.110%29.aspx
# http://msdn.microsoft.com/en-us/library/a89hcwhh%28v=vs.110%29.aspx
$delegateInvoke = $for_type.GetMethod('Invoke')

# Get the argument type signature for the delegate invoke
$parameters = @( $delegateInvoke.GetParameters())
$returnType = $delegateInvoke.ReturnParameter.ParameterType

$argument_list = New-Object -TypeName 'System.Collections.ArrayList'
[void]$argument_list.Add([scriptblock])
$parameters | foreach-object {
$parameter = $_ 
[void]$argument_list.Add($parameter.ParameterType) 
}

[bool]$restrictedSkipVisibility = $true
# http://msdn.microsoft.com/en-us/library/bb348332%28v=vs.110%29.aspx
$dynamic_method = New-Object -TypeName 'System.Reflection.Emit.DynamicMethod' -ArgumentList @( '', $returnType, $argument_list.ToArray(), [System.Object], $restrictedSkipVisibility)
$ilg = $dynamic_method.GetILGenerator()

# Place the scriptblock on the stack for the method call
emit -opcode 'Ldarg_0'
emit -opcode 'Ldc_I4' ($argument_list.Count - 1) # Create the parameter array
emit -opcode 'Newarr' ([object])


for ($cnt = 1; $cnt -lt $argument_list.Count; $cnt++)
{
  emit -opcode 'Dup' # Dup the array reference
  emit -opcode 'Ldc_I4' ($cnt - 1); # Load the index
  emit -opcode 'Ldarg' $cnt # Load the argument
  # Box if necessary
  if ($argument_list[$cnt].IsValueType) {
    emit -opcode 'Box'
  }
  emit -opcode 'Stelem' ([Object]) # Store it in the array
}


# Emit the call to the ScriptBlock invoke method
# http://msdn.microsoft.com/en-us/library/system.management.automation.scriptblock.invokereturnasis(v=vs.85).aspx
emit -opcode 'Call' ([System.Management.Automation.ScriptBlock].GetMethod('InvokeReturnAsIs'))


# If the return type is void, pop the returned object
# Otherwise emit code to convert the result type
if ($returnType -eq [void]) {
   emit -opcode 'Pop'
} else {
  # http://msdn.microsoft.com/en-us/library/system.management.automation.languageprimitives.convertto(v=vs.85).aspx
  $convertMethod = [Management.Automation.LanguagePrimitives].GetMethod('ConvertTo', [type[]]@([object],[type]))
  $GetTypeFromHandle = [type].GetMethod('GetTypeFromHandle')
  # And the return type token...
  emit -opcode 'Ldtoken' $returnType 
  emit -opcode 'Call' $GetTypeFromHandle
  emit -opcode 'Call' $convertMethod
}
emit -opcode 'Ret'

#
# Now return a delegate from this dynamic method...
#

$dynamic_method.CreateDelegate($for_type,$scriptBlock)


