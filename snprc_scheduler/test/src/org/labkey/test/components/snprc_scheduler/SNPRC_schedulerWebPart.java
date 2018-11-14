package org.labkey.test.components.snprc_scheduler;

import org.labkey.test.Locator;
import org.labkey.test.components.BodyWebPart;
import org.labkey.test.components.html.Input;
import org.labkey.test.pages.LabKeyPage;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;

import static org.labkey.test.components.html.Input.Input;

/**
 * TODO: Component for a hypothetical webpart containing an input and a save button
 * Component classes should handle all timing and functionality for a component
 */
public class SNPRC_schedulerWebPart extends BodyWebPart<SNPRC_schedulerWebPart.ElementCache>
{
    public SNPRC_schedulerWebPart(WebDriver driver)
    {
        this(driver, 0);
    }

    public SNPRC_schedulerWebPart(WebDriver driver, int index)
    {
        super(driver, "Snprc_scheduler", index);
    }

    public SNPRC_schedulerWebPart setInput(String value)
    {
        elementCache().input.set(value);
        // TODO: Methods that don't navigate should return this object
        return this;
    }

    public LabKeyPage clickSave()
    {
        getWrapper().clickAndWait(elementCache().button);
        // TODO: Methods that navigate should return an appropriate page object
        return new LabKeyPage(getDriver());
    }

    @Override
    protected ElementCache newElementCache()
    {
        return new ElementCache();
    }

    protected class ElementCache extends BodyWebPart.ElementCache
    {
        protected final WebElement button = Locator.tag("button").withText("Save").findWhenNeeded(this);
        protected final Input input = Input(Locator.tag("input"), getDriver()).findWhenNeeded(this);
    }
}