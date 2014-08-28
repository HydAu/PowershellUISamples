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
            DesiredCapabilities capability = DesiredCapabilities.Firefox();
            //  driver = new RemoteWebDriver(new Uri("http://localhost:4444/wd/hub"), DesiredCapabilities.Firefox()) ;
            String phantomjs_executable_folder = ReadSetting("phantomjs_executable_path");
            driver = new OpenQA.Selenium.PhantomJS.PhantomJSDriver(phantomjs_executable_folder);

            driver.Url = "http://localhost:8011/";
            driver.Manage().Timeouts().ImplicitlyWait(TimeSpan.FromSeconds(10));
            verificationErrors = new StringBuilder();

        }

        [TestCleanup()]
        public void MyTestCleanup()
        {

        }

        [TestMethod]
        [TestCategory("US")]
        public void Test_1()
        {

            // Arrange
            // Act
            driver.Navigate().GoToUrl(ReadSetting("baseURL_GROUP1"));
            // WebDriverWait wait = new WebDriverWait(driver, TimeSpan.FromSeconds(10)) ;
            Assert.IsTrue(driver.Title.IndexOf("Carnival Cruise Lines") > -1, driver.Title);
        }

        [TestMethod]
        [TestCategory("UK")]
        public void Test_2()
        {

            // Arrange
            // Act

            driver.Navigate().GoToUrl(ReadSetting("baseURL_GROUP1"));
            //Find the Log In link and create an object so we can use it
            IWebElement queryBox = driver.FindElements(By.ClassName("header"))[0];
            queryBox.Click();
            // 
            driver.FindElement(By.PartialLinkText("To join the fun"));
            // Assert.IsTrue(), driver.Title);
        }


        [TestMethod]
        [TestCategory("US")]
        public void Test_3()
        {

            // Arrange
            // Act
            driver.Navigate().GoToUrl(ReadSetting("baseURL_GROUP2"));
            // WebDriverWait wait = new WebDriverWait(driver, TimeSpan.FromSeconds(10)) ;
            Assert.IsTrue(driver.Title.IndexOf("Carnival Cruise Lines") > -1, driver.Title);
        }

        [TestMethod]
        [TestCategory("UK")]
        public void Test_4()
        {

            // Arrange
            // Act

            driver.Navigate().GoToUrl(ReadSetting("baseURL_GROUP1"));
            //Find the Log In link and create an object so we can use it
            IWebElement queryBox = driver.FindElement(By.ClassName("login-link"));
            queryBox.Click();

            // 
            driver.FindElement(By.PartialLinkText("To join the fun"));
            // Assert.IsTrue(), driver.Title);
        }

        [TestMethod]
        [TestCategory("US")]
        public void Test_5()
        {

            // Arrange
            // Act
            driver.Navigate().GoToUrl(ReadSetting("baseURL_GROUP2"));
            // WebDriverWait wait = new WebDriverWait(driver, TimeSpan.FromSeconds(10)) ;
            Assert.IsTrue(driver.Title.IndexOf("Carnival Cruise Deals") > -1, driver.Title);
        }


    }
}
