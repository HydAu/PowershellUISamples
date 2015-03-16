function Get-FolderSize

{

  begin { $fso = New-Object -ComObject Scripting.FileSystemObject }

  process {

    $path = $input.fullname

    $folder = $fso.GetFolder($path)

    $size = $folder.size

    [pscustomobject]@{ 'Name' = $path; 'Size' = ($size / 1gb) } } }

pushd 'C:'
cd '\'
Get-ChildItem -Directory -Recurse -EA 0 | Get-FolderSize | sort size -Descending | Out-GridView
popd
