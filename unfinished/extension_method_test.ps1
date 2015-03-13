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

# https://www.google.com/search?q=msbuild+copy+all+reference+assemblies+to+output&ie=utf-8&oe=utf-8
Add-Type -TypeDefinition @"
using System;
using ExtensionMethods;

class ExtensionMethodTest : Object
{
    void TestExtension()
    {
        this.DisplayDefiningAssembly();
    }
}
"@ -ReferencedAssemblies 'C:\developer\sergueik\powershell_ui_samples\unfinished\obj\Debug\extension_class.dll'

$o = new-object -Type 'ExtensionMethodTest'
$o.DisplayDefiningAssembly();
$o.TestExtension();
try {


  } catch [Exception] {
write-output  $_.Exception.Message
}

