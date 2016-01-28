$last_run_report = 'last_run_report.yaml'
pushd $statedir
if (test-path -path $last_run_report) {    
  $file_count = ( Get-ChildItem -Name "$last_run_report.*" -ErrorAction 'Stop' | where-object { $_ -match "${last_run_report}\.\d"}).count
  if ($file_count -gt 0) {
    $file_count..1  | foreach-object { 
      $cnt = $_
      [Console]::Error.WriteLine(("Move ${last_run_report}.{0} ${last_run_report}.{1}" -f $cnt, ($cnt + 1)))
      move-item  "${last_run_report}.${cnt}" -Destination "${last_run_report}.$(($cnt + 1))" -force
    } 
  }
  [Console]::Error.WriteLine(('Move ' + $last_run_report + ' ' + "${last_run_report}.1"))
  move-item $last_run_report -Destination "${last_run_report}.1" -force
}
popd
