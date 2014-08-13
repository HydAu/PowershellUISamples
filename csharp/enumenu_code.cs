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

public delegate bool PropEnumProcEx( IntPtr hWnd, IntPtr lpszString, int hData, int dwData );
public delegate bool CallBackPtr( IntPtr hWnd,  int lParam);
public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr parameter);

public class EnumReport
{
private static bool bHasButton= false;
public static String CommandLine    = String.Empty;
public static int ProcessID         = 0;
private static String sDialogText   = String.Empty;
public static string GetText(IntPtr hWnd) {
	int length       = GetWindowTextLength(hWnd);
	StringBuilder sb = new StringBuilder(length + 1);
	GetWindowText(hWnd, sb, sb.Capacity);
	return sb.ToString();
}


[DllImport("user32.dll")]
[return : MarshalAs(UnmanagedType.Bool)]
public static extern bool EnumChildWindows(IntPtr hWndParent, EnumWindowsProc lpEnumFunc, IntPtr lParam);

[DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);

[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
static extern int GetWindowTextLength(IntPtr hWnd);

[DllImport("user32.dll", SetLastError = true)]
public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out IntPtr lpdwProcessId);

[DllImport("user32.dll")]
public static extern int EnumPropsEx(IntPtr hWnd, PropEnumProcEx lpEnumFunc,  int lParam);

[DllImport("user32.dll")]
public static extern int EnumWindows(CallBackPtr callPtr, int lPar);

[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
static extern IntPtr GetProp(IntPtr hWnd, string lpString);

// [return : MarshalAs(UnmanagedType.Bool)]


[return : MarshalAs(UnmanagedType.SysUInt)]
[DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = false)]
static extern IntPtr SendMessage(IntPtr hWnd, UInt32 Msg, IntPtr wParam, IntPtr lParam);

[DllImport("user32.dll")]
static extern bool CloseWindow(IntPtr hWnd);
[DllImport("user32.dll", SetLastError = true)]
private static extern bool GetWindowInfo(IntPtr hwnd, ref WINDOWINFO pwi);
// http://www.wasm.ru/forum/viewtopic.php?pid=312006
// http://msdn.microsoft.com/en-us/library/ms632610%28v=vs.85%29.aspx
[StructLayout(LayoutKind.Sequential)]
struct WINDOWINFO {
	public uint cbSize;
	public RECT rcWindow;
	public RECT rcClient;
	public uint dwStyle;
	// http://msdn.microsoft.com/en-us/library/ms632600%28v=vs.85%29.aspx
	// WS_DLGFRAME
	// WS_POPUP
	public uint dwExStyle;
	// http://msdn.microsoft.com/en-us/library/ff700543%28v=vs.85%29.aspx
	public uint dwWindowStatus;
	public uint cxWindowBorders;
	public uint cyWindowBorders;
	public ushort atomWindowType;
	public ushort wCreatorVersion;

	public WINDOWINFO(Boolean ?   filler)   :   this()
		// Allows automatic initialization of "cbSize" with
		// "new WINDOWINFO(null/true/false)".
	{
		cbSize = (UInt32)(Marshal.SizeOf(typeof( WINDOWINFO )));
	}

}

[StructLayout(LayoutKind.Sequential)]
public struct RECT {
	private int _Left;
	private int _Top;
	private int _Right;
	private int _Bottom;

	public RECT(RECT Rectangle) : this(Rectangle.Left, Rectangle.Top, Rectangle.Right, Rectangle.Bottom)
	{
	}
	public RECT(int Left, int Top, int Right, int Bottom)
	{
		_Left = Left;
		_Top = Top;
		_Right = Right;
		_Bottom = Bottom;
	}

	public int X {
		get { return _Left; }
		set { _Left = value; }
	}
	public int Y {
		get { return _Top; }
		set { _Top = value; }
	}
	public int Left {
		get { return _Left; }
		set { _Left = value; }
	}
	public int Top {
		get { return _Top; }
		set { _Top = value; }
	}
	public int Right {
		get { return _Right; }
		set { _Right = value; }
	}
	public int Bottom {
		get { return _Bottom; }
		set { _Bottom = value; }
	}
	public int Height {
		get { return _Bottom - _Top; }
		set { _Bottom = value - _Top; }
	}
	public int Width {
		get { return _Right - _Left; }
		set { _Right = value + _Left; }
	}
	public Point Location {
		get { return new Point(Left, Top); }
		set {
			_Left = value.X;
			_Top = value.Y;
		}
	}
	public Size Size {
		get { return new Size(Width, Height); }
		set {
			_Right = value.Width + _Left;
			_Bottom = value.Height + _Top;
		}
	}

	public static implicit operator Rectangle(RECT Rectangle)
	{
		return new Rectangle(Rectangle.Left, Rectangle.Top, Rectangle.Width, Rectangle.Height);
	}
	public static implicit operator RECT(Rectangle Rectangle)
	{
		return new RECT(Rectangle.Left, Rectangle.Top, Rectangle.Right, Rectangle.Bottom);
	}
	public static bool operator ==(RECT Rectangle1, RECT Rectangle2)
	{
		return Rectangle1.Equals(Rectangle2);
	}
	public static bool operator !=(RECT Rectangle1, RECT Rectangle2)
	{
		return !Rectangle1.Equals(Rectangle2);
	}

	public override string ToString()
	{
		return "{Left: " + _Left + "; " + "Top: " + _Top + "; Right: " + _Right + "; Bottom: " + _Bottom + "}";
	}

	public override int GetHashCode()
	{
		return ToString().GetHashCode();
	}

	public bool Equals(RECT Rectangle)
	{
		return Rectangle.Left == _Left && Rectangle.Top == _Top && Rectangle.Right == _Right && Rectangle.Bottom == _Bottom;
	}

	public override bool Equals(object Object)
	{
		if (Object is RECT)
			return Equals((RECT)Object);
		else if (Object is Rectangle)
			return Equals(new RECT((Rectangle)Object));

		return false;
	}
}


public static bool Report( IntPtr hWnd,  int lParam)
{

	IntPtr lngPid  =  System.IntPtr.Zero;

	GetWindowThreadProcessId(hWnd, out lngPid );
	int PID = Convert.ToInt32(/* Marshal.ReadInt32 */ lngPid.ToString() );

	string s  = "Save As|Opening";

	string res =  String.Empty;
	Regex r = new Regex( s,
			     RegexOptions.ExplicitCapture | RegexOptions.IgnoreCase );
	string sToken =  GetText(hWnd);
	MatchCollection m = r.Matches( sToken);
	if ( sToken != null && m.Count != 0 ) {
		EnumPropsEx(hWnd, EnumPropsExManaged, 0 );

		bHasButton = false;
		GetChildWindows(hWnd);

		if (bHasButton) {

				Console.WriteLine("Window process ID is " + PID.ToString() );
				Console.WriteLine("Window handle is "     + hWnd);
				Console.WriteLine("Window title is "      + sToken  );
				Console.WriteLine("Window match "         +  m.Count.ToString());
                         UInt32 WM_CLOSE = 0x10;
                         SendMessage(hWnd, WM_CLOSE, IntPtr.Zero, IntPtr.Zero);
		}

	}
	return true;
}


// http://msdn.microsoft.com/en-us/library/ms633566%28v=VS.85%29.aspx
// http://msdn.microsoft.com/en-us/library/ms633561%28v=vs.85%29.aspx#listing_properties
// http://source.winehq.org/source/include/winuser.h
public static bool EnumPropsExManaged( IntPtr hWnd, IntPtr lpszString, int hData, int dwData ) {

	String myManagedString = Marshal.PtrToStringAnsi(lpszString );
	// code deleted
	return true;
}

public static List<IntPtr> GetChildWindows(IntPtr parent){
	List<IntPtr> result = new List<IntPtr>();
	GCHandle listHandle = GCHandle.Alloc(result);
	try
	{
		EnumWindowsProc childProc = new EnumWindowsProc(EnumWindow);
		EnumChildWindows(parent, childProc, GCHandle.ToIntPtr(listHandle));

		System.IntPtr[] sArray = new System.IntPtr[result.Count];
		result.CopyTo(sArray, 0);

		foreach ( System.IntPtr s in sArray) {

			string sChT =  GetText(s);
                        string s2 = "&Save";
			string res =  String.Empty;
			Regex r = new Regex( s2,
					     RegexOptions.ExplicitCapture | RegexOptions.IgnoreCase );

			MatchCollection m = r.Matches( sChT);
			if (sChT != null && m.Count != 0 ) {
					Console.WriteLine("Matches button [{0}] text : \"{1}\"" , s, sChT );
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


/// <summary>
/// Collect Window Handle information of Child Windows.
/// </summary>
private static bool EnumWindow(IntPtr handle, IntPtr pointer) {
	GCHandle gch = GCHandle.FromIntPtr(pointer);
	List<IntPtr> list = gch.Target as List<IntPtr>;
	if (list == null)
		throw new InvalidCastException("GCHandle Target could not be cast as List<IntPtr>");
	list.Add(handle);
	return true;
}

public static void Main(){
	CallBackPtr callBackPtr = new CallBackPtr(EnumReport.Report);
	EnumReport.EnumWindows(callBackPtr, 0);

}

}