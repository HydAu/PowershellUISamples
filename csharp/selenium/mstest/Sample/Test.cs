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
using OpenQA.Selenium.Firefox;
using OpenQA.Selenium.Support.UI;
using OpenQA.Selenium.IE;

// TODO : App.config 
namespace SeleniumTests
{


    [TestClass]
    public class SeleniumTest
    {

	private static IWebDriver driver;
	private static StringBuilder verificationErrors;
        private string baseURL;
        private bool acceptNextAlert = true;


        [ClassCleanup()]
        public static void MyClassCleanup() { 
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
          DesiredCapabilities capability = DesiredCapabilities.Firefox();
          // driver = new RemoteWebDriver(
          // new Uri("http://172.26.4.45:4444/hub/"), capability );
            driver = new FirefoxDriver();
         driver.Url =  baseURL = "http://www.wikipedia.org";
         driver.Manage().Timeouts().ImplicitlyWait( TimeSpan.FromSeconds(10 )) ;
         verificationErrors = new StringBuilder();

        }

        [TestCleanup()]
        public void MyTestCleanup() { 

	}

        [TestMethod]
        public void Test_1()
        {

            // Arrange
            // Act
            driver.Navigate().GoToUrl(baseURL + "/");
            WebDriverWait wait = new WebDriverWait(driver, TimeSpan.FromSeconds(10)) ;

            //Find the Element and create an object so we can use it
            IWebElement queryBox = driver.FindElement(By.Id("searchInput"));
            queryBox.Clear();
            //Work with the Element that's on the page
            queryBox.SendKeys("Selenium");
			queryBox.SendKeys(Keys.ArrowDown);
            queryBox.Submit();
            driver.FindElement(By.LinkText("Selenium (software)")).Click();

            // Assert
            Assert.IsTrue(driver.Title.IndexOf("Selenium (software)") > -1, driver.Title);
        }

        private bool IsElementPresent(By by)
        {
            try
            {
                driver.FindElement(by);
                return true;
            }
            catch (NoSuchElementException)
            {
                return false;
            }
        }
        
        private bool IsAlertPresent()
        {
            try
            {
                driver.SwitchTo().Alert();
                return true;
            }
            catch (NoAlertPresentException)
            {
                return false;
            }
        }
        
        private string CloseAlertAndGetItsText() {
            try {
                IAlert alert = driver.SwitchTo().Alert();
                string alertText = alert.Text;
                if (acceptNextAlert) {
                    alert.Accept();
                } else {
                    alert.Dismiss();
                }
                return alertText;
            } finally {
                acceptNextAlert = true;
            }
        }

    }
}
