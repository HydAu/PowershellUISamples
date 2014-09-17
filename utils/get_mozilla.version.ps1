pushd 'HKLM:'
cd  '\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
$app_record  = get-childitem . | where-object {$_.Name -match 'Mozilla'}   | select-object -first 1
$app_record_fields  = $app_record.GetValueNames()

if ( -not ($app_record_fields.GetType().BaseType.Name -match  'Array' ) ) {
  write-output 'Unexpected result type'
}
# not good for mixed types 
$results = $app_record_fields | foreach-object { @{'name' = $_; 'expression' = &{$app_record.GetValue($_)}}}; 

$results_lookup =  @{} 
$results | foreach-object {$results_lookup[$_.name] = $_.expression } 
popd 
$results_lookup

