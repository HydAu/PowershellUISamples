using System;
using System.IO;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Xml.Serialization;
using ServiceMonitor;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace ServiceMonitorTests
{
    /// <summary>
    /// Summary description for UnitTest1
    /// </summary>
    [TestClass]
    public class ProfileTests
    {      
        [TestMethod]
        public void TestProfileSerialization()
        {
            var profiles = new List<Profile>
                               {
                                   new Profile {Name = "Default", Services = new List<string> {"testservice1", "testservice2"}},
                                   new Profile {Name = "Default2", Services = new List<string> {"testservice1", "testservice2"}}
                               };            
            StringWriter sw = new StringWriter();
            XmlSerializer xmlser = new XmlSerializer(typeof(List<Profile>));

            xmlser.Serialize(sw, profiles);
            Console.WriteLine(sw.ToString());
            sw.Close();
        }
    }
}
