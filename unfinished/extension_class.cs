using System;
using System.Text;
using System.Reflection;
using System.Runtime.CompilerServices;
namespace ExtensionMethods {
  public static class Extensions {
    public static DateTime StartOfWeek(this DateTime dt, DayOfWeek startOfWeek) {
      int diff = dt.DayOfWeek - startOfWeek;
      if (diff < 0) {
        diff += 7;
      }
      return dt.AddDays(-1 * diff).Date;
    }

    public static void DisplayDefiningAssembly(this object obj)
    {
        Console.WriteLine(obj.GetType().Name);
        Console.WriteLine(Assembly.GetAssembly(obj.GetType()));
    }
  }
}
