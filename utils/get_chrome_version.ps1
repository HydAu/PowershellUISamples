pushd 'HKLM:'
cd '/SOFTWARE/Wow6432Node/Microsoft/Windows/CurrentVersion/Uninstall/Google Chrome'
@('DisplayName', 'Version' ) | foreach-object {get-itemproperty -name $_ -path 'HKLM:/SOFTWARE/Wow6432Node/Microsoft/Windows/CurrentVersion/Uninstall/Google Chrome'}
popd

