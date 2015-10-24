# this uses reflection to discover that there is redirecton and adjusts handles
# https://social.technet.microsoft.com/Forums/windowsserver/en-US/6c8a9e5d-3103-4f94-af15-75b309fc8360/redirecting-mixed-powershell-pipeline-and-console-object-output
$rt_field_info1 = $host.GetType().GetField('externalHostRef',[Reflection.BindingFlags]('Instance,NonPublic,GetField'))
$object_ref = $rt_field_info1.GetValue($host)
$runtime_property_info1 = $object_ref.GetType().GetProperty('Value',[Reflection.BindingFlags]('Instance,NonPublic,GetProperty'))
$console_host = $runtime_property_info1.GetValue($object_ref,@())
$runtime_property_info2 = $console_host.GetType().GetProperty('IsStandardOutputRedirected',[Reflection.BindingFlags]('Instance,NonPublic,GetProperty'))
[void]$runtime_property_info2.GetValue($console_host,@())

$std_out2 = $console_host.GetType().GetField('StandardOutputWriter',[Reflection.BindingFlags]('Instance,NonPublic,GetField'))
$std_err2 = $console_host.GetType().GetField('StandardErrorWriter',[Reflection.BindingFlags]('Instance,NonPublic,GetField'))
if ($std_out2 -ne $null) {
  $std_out2.SetValue($console_host,[console]::Out)
}
if ($std_err2 -ne $null) {
  $std_err2.SetValue($console_host,[console]::Out)
}
