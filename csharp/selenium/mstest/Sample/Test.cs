 using System;
using System.Linq.Expressions;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Microsoft.Activities.UnitTesting;
using Moq;

using OpenQA.Selenium;
using OpenQA.Selenium.Remote;
using OpenQA.Selenium.Support.UI;
using OpenQA.Selenium.Firefox;
using OpenQA.Selenium.IE;
using System.Configuration;
using System.Configuration.Install;

// TODO : App.config
namespace SeleniumTests
{


    [TestClass]
    public class SeleniumTest
    {


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


        private static IWebDriver driver;
        private static StringBuilder verificationErrors = new StringBuilder();

        [ClassCleanup()]
        public static void MyClassCleanup()
        {
            try
            {
                driver.Quit();
            }
            catch (Exception)
            {
                // Ignore errors if unable to close the browser
            }
            Assert.AreEqual("", verificationErrors.ToString());
        }

        [TestInitialize()]
        public void MyTestInitialize()
        {
            string url = ReadSetting("url");
            String browser_selection  = ReadSetting("browser");
		DesiredCapabilities capability = null;
            if (browser_selection.IndexOf("firefox") == 0 ){
               capability = DesiredCapabilities.Firefox();
            }
            if (browser_selection.IndexOf("chrome") == 0 ){
               capability = DesiredCapabilities.Chrome();
            }
            if (browser_selection.IndexOf("IE") == 0 ){
               capability = DesiredCapabilities.InternetExplorer();
            }

            driver = new RemoteWebDriver(new Uri("http://localhost:4444/wd/hub"), capability ) ;
            // String phantomjs_executable_folder = ReadSetting("phantomjs_executable_path");
            // driver = new OpenQA.Selenium.PhantomJS.PhantomJSDriver(phantomjs_executable_folder);

            driver.Url = "http://www.google.com/";
            driver.Manage().Timeouts().ImplicitlyWait(TimeSpan.FromSeconds(10));
            verificationErrors = new StringBuilder();

        }

        [TestCleanup()]
        public void MyTestCleanup()
        {

        }

        [TestMethod]
        [TestCategory("Category")]
        public void Test()
        {

            // Arrange
            // Act
            driver.Navigate().GoToUrl(ReadSetting("baseURL"));
IJavaScriptExecutor js = driver as IJavaScriptExecutor;

String script = @"


function createCookie(name,value,days) {
    if (days) {
        var date = new Date();
        date.setTime(date.getTime()+(days*24*60*60*1000));
        var expires = ; expires=+date.toGMTString();
    }
    else var expires = '';
    document.cookie = name+'='+value+expires+'; path=/';
}

function readCookie(name) {
    var nameEQ = name + '=';
    var ca = document.cookie.split(';');
    for(var i=0;i < ca.length;i++) {
        var c = ca[i];
        while (c.charAt(0)==' ') c = c.substring(1,c.length);
        if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
    }
    return null;
}

function eraseCookie(name) {
    createCookie(name,'',-1);
}

// finally invoke 

var cookies = document.cookie.split(';');
for (var i = 0; i < cookies.length; i++) {
  eraseCookie(cookies[i].split(=)[0]);
}
";

script = "return document.title" ;
string title = (string)js.ExecuteScript(script);
   
            // WebDriverWait wait = new WebDriverWait(driver, TimeSpan.FromSeconds(10)) ;
            Assert.IsTrue(driver.Title.IndexOf(ReadSetting("title")) > -1, driver.Title);
        }

    }
}


