package org.labkey.test.pages.snprc_scheduler;

import org.labkey.test.Locator;
import org.labkey.test.WebDriverWrapper;
import org.labkey.test.WebTestHelper;
import org.labkey.test.pages.LabKeyPage;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.WebElement;

public class BeginPage extends LabKeyPage<BeginPage.ElementCache>
{

    public BeginPage(WebDriverWrapper driver)
    {
        super(driver);
    }

    public static BeginPage beginAt(WebDriverWrapper driver)
    {
        return beginAt(driver, driver.getCurrentContainerPath());
    }

    public static BeginPage beginAt(WebDriverWrapper driver, String containerPath)
    {
        driver.beginAt(WebTestHelper.buildURL("snprc_scheduler", containerPath, "begin"));
        //driver.waitForElement(Locator.byClass("modal-open"));

        JavascriptExecutor js;
        js = (JavascriptExecutor) driver;
        try
        {
            //sleep(3000);
            //re-enable buttons
            js.executeScript("document.getElementsByClassName('modal-backdrop')[0].style.display=\"none\";");
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
        return new BeginPage(driver);
    }


    @Override
    protected ElementCache newElementCache()
    {
        return new ElementCache();
    }

    protected class ElementCache extends LabKeyPage.ElementCache
    {
        protected final WebElement helloMessage = Locator.tagWithName("div", "helloMessage").findWhenNeeded(this);
    }

    public void beginPage_Tests()
    {

        final String expectedTitle = "Procedure scheduling";
        assertTextPresent(expectedTitle);

        //Accordian rendered tests
        assertTextPresent("Projects");
        assertTextPresent("Timelines");
        assertTextPresent("Animals");
    }
}
