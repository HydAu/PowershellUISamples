# This example does not work because the class has to implement IWin32Window and it is uclear if this is possible with MemberDefinition 
$guid = [guid]::NewGuid()
$helper_classname = 'win32_window_helper'
$helper_namespace = ("Util_{0}" -f ($guid -replace '-',''))

Add-Type -UsingNamespace @(
  'System.Windows.Forms'
  ) `
   -MemberDefinition @"

    private IntPtr _hWnd;
    private int _numeric;
    private string _timestr;

    public int Numeric
    {
        get { return _numeric; }
        set { _numeric = value; }
    }

    public string TimeStr
    {
        get { return _timestr; }
        set { _timestr = value; }
    }

    public ${helper_classname}(IntPtr handle)
    {
        _hWnd = handle;
    }

    public IntPtr Handle
    {
        get { return _hWnd; }
    }

"@ -ReferencedAssemblies @( 'System.Windows.Forms.dll') `
   -Namespace $helper_namespace -Name $helper_classname -ErrorAction Stop
$helper_typename = ('{0}.{1}' -f $helper_namespace,$helper_classname )


