using System;
using System.Text;
using System.Reflection;
using System.Runtime.CompilerServices;
// Origin http://www.java2s.com/Tutorial/CSharp/0140__Class/Addingextensionmethodforint.htm
namespace ExtensionMethods
{
    public static class Extensions
    {
        public static void ExtensionMethod(this object obj)
        {
            Console.WriteLine("This extension method will attempt to display  defining assembly of the bound class:");
            // TODO: move try catch here
            // Console.WriteLine(obj.GetType().Name);
            // Console.WriteLine(Assembly.GetAssembly(obj.GetType()));
        }
    }
}
