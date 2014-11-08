package com.mycompany.app;

import java.io.File;
import java.util.concurrent.TimeUnit;
import org.apache.commons.io.FileUtils;
import org.openqa.selenium.By;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.OutputType;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import org.openqa.selenium.TakesScreenshot;
import org.openqa.selenium.WebDriver; 

public class App
{  public static void main(String[] args) {
  
  
//  System.setProperty("webdriver.chrome.driver", "C:\\java\\selenium\\chromedriver.exe"); 
   WebDriver driver =  new FirefoxDriver();
//    WebDriver driver =  new ChromeDriver();
  try{
   
   driver.manage().timeouts().pageLoadTimeout(50, TimeUnit.SECONDS);
   driver.manage().timeouts().implicitlyWait(20, TimeUnit.SECONDS);   
   driver.get("http://www.carnival.com/");
   WebDriverWait wait = new WebDriverWait(driver, 30);

  // http://assertselenium.com/2013/01/29/webdriver-wait-commands/

  wait.until(ExpectedConditions.elementToBeClickable(By.className("logo")));
  wait.until(ExpectedConditions.visibilityOfElementLocated(By.className("logo")));
  String value1 = "dest";
  String css_selector1 = "a[data-param=' +$value1 + ']";
  driver.findElement(By.cssSelector(css_selector1)).click();
   

 //take a screenshot
File scrFile = ((TakesScreenshot)driver).getScreenshotAs(OutputType.FILE);

//save the screenshot in png format on the disk.
FileUtils.copyFile(scrFile, new File(System.getProperty("user.dir") + "\\screenshot.png"));   
  
  }
  
  catch(Exception ex){
   
   System.out.println(ex.toString());
   
  }
  finally{
   
   driver.close();
   driver.quit();
  }
 }

}
