# http://blogs.msdn.com/b/oldnewthing/archive/2014/04/21/10518929.aspx
<#
Raymond says:
add a reference to shell32.dll
where is shell32.dll
c:\Windows\System32\shell32.dll
c:\Windows\winsxs\x86_microsoft-windows-shell32_31bf3856ad364e35_6.1.7601.17514_none_6e3094c9703e06ca\shell32.dll

... more Fusion items 

#>
class Program {
  public static void Main()
  {
    var shell = new Shell32.Shell();
    var recycleBin = shell.NameSpace(10); // CSIDL_BITBUCKET
    var items = recycleBin.Items();
    for (var i = 0; i < items.Count; i++) {
      var item = (Shell32.FolderItem2)items.Item(i);
      System.Console.WriteLine(item.Name);
      System.Console.WriteLine(item.ExtendedProperty(
                                    "System.Recycle.DeletedFrom"));
      System.Console.WriteLine(item.ExtendedProperty(
                                    "System.Recycle.DateDeleted"));
      System.Console.WriteLine(item.Size);
    }
  }
}
