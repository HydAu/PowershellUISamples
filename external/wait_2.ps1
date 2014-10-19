# https://groups.google.com/forum/#!topic/selenium-users/MaJLFpv5wfE
<#
static void Main(string[] args)

{

checkSite("http://cccoins.blogspot.com/");

checkSite("http://realsestateinsurance.blogspot.com/");

           

 

}

static void checkSite(String url)

{

IWebDriver driver = new FirefoxDriver();

try

{

Console.WriteLine("Open site.");

driver.Manage().Timeouts().ImplicitlyWait(TimeSpan.FromSeconds(15));

driver.Navigate().GoToUrl("http://www.w-global.com/index.php/tools-gadgets/online-sitemap-generator");

driver.SwitchTo().Frame("c-analyzer");

IWebElement url_parse = driver.FindElement(By.Name("inputurl"));

url_parse.SendKeys(url);

url_parse = driver.FindElement(By.Name("createtxt"));

url_parse.Click();

url_parse = driver.FindElement(By.Id("frqncy"));

var selectElement = new SelectElement(url_parse);

selectElement.SelectByValue("always");

url_parse = driver.FindElement(By.Id("onlonc"));

url_parse.Click();

Console.WriteLine("Start parse.");

                

             

IWebElement ready_button =

driver.FindElement(

By.XPath(".//*[@id='page']/table[2]/tbody/tr/td[1]/table/tbody/tr[3]/td[2]/div/div/a"));

ready_button.Click();

url_parse = driver.FindElement(By.XPath(".//*[@id='smaptxt']/div[2]/textarea"));

String urls = url_parse.GetAttribute("value");

string[] stringList = urls.Split("\r\n".ToCharArray());

Console.WriteLine("Done");

foreach (string s in stringList)

{

Console.WriteLine(s);

}

}

catch (Exception ee)

{

Console.WriteLine(ee.ToString());

String s = ee.ToString();

}

finally

{

driver.Close();

}

}

#>