using System;
using ExtensionMethods;

class ExtensionMethodTest : Object {
    void ExtensionMethod_Wrapper() {
        this.ExtensionMethod();
    }
    static void Main(string[] args) {
        ExtensionMethodTest o = new ExtensionMethodTest();
        o.ExtensionMethod();
        o.ExtensionMethod_Wrapper();
    }
}