#Copyright (c) 2015 Serguei Kouzmine
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.

# you have to load extension class first .
Add-Type -Path 'C:\developer\sergueik\powershell_ui_samples\unfinished\obj\Debug\extension_class.dll'

# you can copy 
# http://www.java2s.com/Tutorial/CSharp/0140__Class/Addingextensionmethodforint.htm
# https://www.google.com/search?q=msbuild+copy+all+reference+assemblies+to+output&ie=utf-8&oe=utf-8
Add-Type -TypeDefinition @"
using System;
using ExtensionMethods;

public class ExtensionMethodTest : Object {
    public void ExtensionMethod_Wrapper(){
        this.ExtensionMethod();
    }

    public static void Main(string[] args) {
        ExtensionMethodTest o = new ExtensionMethodTest();
        o.ExtensionMethod();
        o.ExtensionMethod_Wrapper();
    }
}
"@ -ReferencedAssemblies 'C:\developer\sergueik\powershell_ui_samples\unfinished\obj\Debug\extension_class.dll'

$o = New-Object -Type 'ExtensionMethodTest'


try {
  $o.ExtensionMethod();

} catch [exception]{
  # this will fail with 
  Write-Output $_.Exception.Message

}



try {
  # this will fail with 
  $o.ExtensionMethod_Wrapper();

} catch [exception]{
  Write-Output $_.Exception.Message
}
