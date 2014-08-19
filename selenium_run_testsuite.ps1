# 

# http://stackoverflow.com/questions/570117/why-is-reflectiononlyassemblyresolve-not-executed-when-trying-to-assembly-reflec


[string] $fileToLoad = 'C:\temp\mstest\WebDriverFramework.dll';

[System.Reflection.AssemblyName ]$assamblyName = [System.Reflection.AssemblyName]::GetAssemblyName($fileToLoad);
# [System.Reflection.Assembly]::Load($assamblyName)
# [System.Reflection.Assembly]::LoadWithPartialName( $fileToLoad )

[System.Reflection.Assembly]::ReflectionOnlyLoadFrom($fileToLoad )


# [System.Reflection.Assembly]::Load('WebDriverFramework')

<#
 Exception calling "LoadWithPartialName" with "1" argument(s): 
"The given assembly name or codebase was invalid. (Exception from HRESULT: 0x80131047)"
 #>

$testSuite = [System.Reflection.Assembly]::ReflectionOnlyLoadFrom("C:\temp\mstest\CarnivalTestScripts.dll")

 
[void][System.Reflection.Assembly]::ReflectionOnlyLoadFrom( 'C:\temp\mstest\WebDriverFramework.dll' );

[void][System.Reflection.Assembly]::ReflectionOnlyLoadFrom("C:\temp\mstest\CarnivalUS.Core.dll")
[void] [System.Reflection.Assembly]::ReflectionOnlyLoadFrom("C:\temp\mstest\CarnivalUK.Core.dll")
# [void][System.Reflection.Assembly]::LoadWithPartialName("CarnivalUS.Core.dll")
# [void][System.Reflection.Assembly]::LoadWithPartialName("CarnivalTestScripts.dll")
# [void][System.Reflection.Assembly]::LoadWithPartialName("CarnivalTestScripts.dll")
$testSuite = [System.Reflection.Assembly]::ReflectionOnlyLoadFrom("C:\temp\mstest\CarnivalTestScripts.dll")

try {
$types = $testSuite.GetTypes()
$types | format-list | out-null
} 
catch [System.Reflection.ReflectionTypeLoadException] {

 write-output $_.Exception.GetType().FullName; 
  write-output $_.Exception.Message
   $_.Exception.LoaderExceptions | foreach-object {write-output $_}
<# 

Cannot resolve dependency to assembly 'WebDriverFramework, Version=0.0.16.0,
Culture=neutral, PublicKeyToken=null' because it has not been preloaded. When
using the ReflectionOnly APIs, dependent assemblies must be pre-loaded or
loaded on demand through the ReflectionOnlyAssemblyResolve event.
#>
}
<#
return
#>
$methods = $testSuite.GetTypes().GetMethods()
$methods | select-object -first 3 | get-member

$methods| select-object -first 3 | foreach-object {$_.GetCustomAttributes  } 
return
<#

$testMethods = $methods | 
    Where { 
        $_.GetCustomAttributesData() | 
            Where { $_.AttributeType.FullName -like "*.TestAttribute" } 
    }
$testDocumentation = $testMethods | 
    Select DeclaringType, Name, @{
        Name = "Description"
        Expression = { 
            $descriptionAttribute = $_.GetCustomAttributesData() |
                Where { $_.AttributeType.FullName -like "*.DescriptionAttribute"}
            Write-Output $descriptionAttribute.ConstructorArguments[0].Value
        }
    }
#>
