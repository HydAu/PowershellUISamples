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
namespace ExtensionMethods {
  public static class Extensions {
    public static DateTime StartOfWeek(this DateTime dt, DayOfWeek startOfWeek) {
      int diff = dt.DayOfWeek - startOfWeek;
      if (diff < 0) {
        diff += 7;
      }
      return dt.AddDays(-1 * diff).Date;
    }
  }
}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll','System.Data.dll','System.Xml.dll'

try {
[DateTime]$dt = [DateTime]::Now.StartOfWeek([System.DayOfWeek]::Monday)  } catch [Exception] {
write-output  $_.Exception.Message
}


$dt 
