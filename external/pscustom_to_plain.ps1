function ConvertTo-PsCustomObjectFromHashtable {
  param(
    [Parameter(
      Position = 0,
      Mandatory = $true,
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true
    )] [object[]]$hashtable
  );

  begin { $i = 0; }

  process {
    foreach ($myHashtable in $hashtable) {
      if ($myHashtable.GetType().Name -eq 'hashtable') {
        $output = New-Object -TypeName PsObject;
        Add-Member -InputObject $output -MemberType ScriptMethod -Name AddNote -Value {
          Add-Member -InputObject $this -MemberType NoteProperty -Name $args[0] -Value $args[1];
        };
        $myHashtable.Keys | Sort-Object | % {
          $output.AddNote($_,$myHashtable.$_);
        }
        $output;
      } else {
        Write-Warning "Index $i is not of type [hashtable]";
      }
      $i += 1;
    }
  }
}

function ConvertTo-HashtableFromPsCustomObject {
  param(
    [Parameter(
      Position = 0,
      Mandatory = $true,
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true
    )] [object[]]$psCustomObject
  );

  process {
    foreach ($myPsObject in $psObject) {
      $output = @{};
      $myPsObject | Get-Member -MemberType *Property | % {
        $output.($_.Name) = $myPsObject.($_.Name);
      }
      $output;
    }
  }
}


$x = @{'a' = @(1,2,3); 'b' = @{'e'= 10;};}
$s = $x | convertto-json
$z = $s | convertfrom-json
