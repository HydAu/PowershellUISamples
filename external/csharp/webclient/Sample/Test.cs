using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Security.Cryptography.X509Certificates;
using System.Net.Security;
using System.Net;

using System.Linq.Expressions;
using Microsoft.VisualStudio.TestTools.UnitTesting;
// using Microsoft.Activities.UnitTesting;

using System.Configuration;
using System.Configuration.Install;



// TODO : App.config
namespace TestWebServices
{


    [TestClass]
    public class WebServiceTest
    {
        private static StringBuilder verificationErrors = new StringBuilder();

        static string ReadSetting(string key)
        {
            string result = null;
            try
            {
                var appSettings = ConfigurationManager.AppSettings;
                result = appSettings[key] ?? "Not Found";
                Console.WriteLine(result);
            }
            catch (ConfigurationErrorsException)
            {
                Console.WriteLine("Error reading app settings");
            }
            return result;
        }


        [ClassCleanup()]
        public static void MyClassCleanup()
        {
            try
            {
            }
            catch (Exception)
            {
                // Ignore errors if unable to close the browser
            }
            Assert.AreEqual("", verificationErrors.ToString());
        }

        private static bool RemoteServerCertificateValidationCallback(object sender,
X509Certificate certificate, X509Chain chain, SslPolicyErrors sslPolicyErrors)
        {
            return true;
        }

        [TestInitialize()]
        public void MyTestInitialize()
        {
            ServicePointManager.ServerCertificateValidationCallback = new
RemoteCertificateValidationCallback(RemoteServerCertificateValidationCallback);

        }

        [TestCleanup()]
        public void MyTestCleanup()
        {

        }

        [TestMethod]
        [TestCategory("First")]
        public void Test_1()
        {

            var cmwClient = new TestWebServices.ServiceReference1.CoreWebServiceClient("WSHttpBinding_ICoreWebService");
            cmwClient.ClientCredentials.UserName.UserName = "Administrator";
            cmwClient.ClientCredentials.UserName.Password = "e15HlFmH";
            var taskData = new Dictionary<string, object>();
            taskData["title"] = "Hello, world";
            taskData["description"] = "Ws task";
            cmwClient.TaskCreate(null, taskData);

            cmwClient.Close();  // Arrange
            // Act
            // Assert 
        }

        [TestMethod]
        [TestCategory("Second")]
        public void Test_2()
        {

            // Arrange
            // Act
            // Assert 
        }

    }
}


