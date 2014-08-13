/*
Copyright (c) 2006, 2014 Serguei Kouzmine

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/
using System;
using System.Drawing;
using System.IO;
using System.Threading;
using System.Diagnostics;
// http://msdn.microsoft.com/en-us/library/aa288468%28v=vs.71%29.aspx
using System.Runtime.InteropServices;
using System.ComponentModel;
using System.Windows.Forms;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Text;
using System.Text.RegularExpressions;
using System.Reflection;

public delegate bool PropEnumProcEx(IntPtr hWnd, IntPtr lpszString, int hData, int dwData);
public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr parameter);

public class EnumReport
{
    private static bool bHasButton = false;
    public static String CommandLine = String.Empty;
    public static int ProcessID = 0;
    private static String sDialogText = String.Empty;
    public static string GetText(IntPtr hWnd)
    {
        int length = GetWindowTextLength(hWnd);
        StringBuilder sb = new StringBuilder(length + 1);
        GetWindowText(hWnd, sb, sb.Capacity);
        return sb.ToString();
    }


    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool EnumChildWindows(IntPtr hWndParent, EnumWindowsProc lpEnumFunc, IntPtr lParam);

    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);

    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    static extern int GetWindowTextLength(IntPtr hWnd);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out IntPtr lpdwProcessId);

    [DllImport("user32.dll")]
    public static extern int EnumPropsEx(IntPtr hWnd, PropEnumProcEx lpEnumFunc, int lParam);

    [DllImport("user32.dll")]
    public static extern int EnumWindows(CallBackPtr callPtr, int lPar);

    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    static extern IntPtr GetProp(IntPtr hWnd, string lpString);

    [return: MarshalAs(UnmanagedType.SysUInt)]
    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = false)]
    static extern IntPtr SendMessage(IntPtr hWnd, UInt32 Msg, IntPtr wParam, IntPtr lParam);

    public static bool Report(IntPtr hWnd, int lParam)
    {

        IntPtr lngPid = System.IntPtr.Zero;
        GetWindowThreadProcessId(hWnd, out lngPid);
        int PID = Convert.ToInt32(/* Marshal.ReadInt32 */ lngPid.ToString());

        string s = "Save As|Opening";

        string res = String.Empty;
        Regex r = new Regex(s,
                     RegexOptions.ExplicitCapture | RegexOptions.IgnoreCase);
        string sToken = GetText(hWnd);
        MatchCollection m = r.Matches(sToken);
        if (sToken != null && m.Count != 0)
        {
            EnumPropsEx(hWnd, EnumPropsExManaged, 0);
            bHasButton = false;
            GetChildWindows(hWnd);

            if (bHasButton)
            {
                Console.WriteLine("Window process ID is " + PID.ToString());
                Console.WriteLine("Window handle is " + hWnd);
                Console.WriteLine("Window title is " + sToken);
                Console.WriteLine("Window match " + m.Count.ToString());
                UInt32 WM_CLOSE = 0x10;
                SendMessage(hWnd, WM_CLOSE, IntPtr.Zero, IntPtr.Zero);
            }

        }
        return true;
    }


    // http://msdn.microsoft.com/en-us/library/ms633566%28v=VS.85%29.aspx
    // http://msdn.microsoft.com/en-us/library/ms633561%28v=vs.85%29.aspx#listing_properties
    // http://source.winehq.org/source/include/winuser.h
    public static bool EnumPropsExManaged(IntPtr hWnd, IntPtr lpszString, int hData, int dwData)
    {

        String myManagedString = Marshal.PtrToStringAnsi(lpszString);
        // code deleted
        return true;
    }

    public static List<IntPtr> GetChildWindows(IntPtr parent)
    {
        List<IntPtr> result = new List<IntPtr>();
        GCHandle listHandle = GCHandle.Alloc(result);
        try
        {
            EnumWindowsProc childProc = new EnumWindowsProc(EnumWindow);
            EnumChildWindows(parent, childProc, GCHandle.ToIntPtr(listHandle));

            System.IntPtr[] sArray = new System.IntPtr[result.Count];
            result.CopyTo(sArray, 0);

            foreach (System.IntPtr s in sArray)
            {
                string sChT = GetText(s);
                string s2 = "&Save";
                string res = String.Empty;
                Regex r = new Regex(s2,
                             RegexOptions.ExplicitCapture | RegexOptions.IgnoreCase);

                MatchCollection m = r.Matches(sChT);
                if (sChT != null && m.Count != 0)
                {
                    Console.WriteLine("Matches button [{0}] text : \"{1}\"", s, sChT);
                    bHasButton = true;

                    sDialogText = sChT;
                }
            }
        }
        finally
        {
            if (listHandle.IsAllocated)
                listHandle.Free();
        }
        return result;
    }

    private static bool EnumWindow(IntPtr handle, IntPtr pointer)
    {
        GCHandle gch = GCHandle.FromIntPtr(pointer);
        List<IntPtr> list = gch.Target as List<IntPtr>;
        if (list == null)
            throw new InvalidCastException("cast exception");
        list.Add(handle);
        return true;
    }

    public static void Main()
    {
        EnumReport.EnumWindows(EnumReport.Report, 0);
    }
}