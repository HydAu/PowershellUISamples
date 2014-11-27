# TODO: finish the syntax
# [NUnit.Framework.Assert]::IsInstanceOfType($profiles , new-object System.Type( FirefoxProfile[]))
[NUnit.Framework.StringAssert]::AreEqualIgnoringCase($profiles.GetType().ToString(),'OpenQA.Selenium.Firefox.FirefoxProfile[]')


# [NUnit.Framework.StringAssert]::Contains('www.urbandictionary.com',$selenium.url,{})

