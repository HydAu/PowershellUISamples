package com.mycompany.app;

import java.util.concurrent.TimeUnit;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.firefox.FirefoxDriver;

public class Test
{  public static void main(String[] args) {
  
  
//  System.setProperty("webdriver.chrome.driver", "C:\\java\\selenium\\chromedriver.exe"); 
//   WebDriver driver =  new FirefoxDriver();
    WebDriver driver =  new ChromeDriver();
  try{
   
   driver.manage().timeouts().pageLoadTimeout(50, TimeUnit.SECONDS);
   driver.manage().timeouts().implicitlyWait(20, TimeUnit.SECONDS);   
   driver.get("http://www.carnival.com/");
   
   
//  driver.findElement(By.xpath("//input[starts-with(@onblur,'field')]")).sendKeys("Sagar Salunke");
   
   
   
   Thread.sleep(1000);

// driver.close();
   
  
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
