package org.labkey.test.pages;

import org.labkey.test.BaseWebDriverTest;
import org.labkey.test.WebTestHelper;

public class SNPRCAnimalHistoryPage extends AnimalHistoryPage
{
    public SNPRCAnimalHistoryPage(BaseWebDriverTest test)
    {
        super(test);
    }

    public static AnimalHistoryPage beginAt(BaseWebDriverTest test)
    {
        return beginAt(test, test.getCurrentContainerPath());
    }

    public static AnimalHistoryPage beginAt(BaseWebDriverTest test, String containerPath)
    {
        test.beginAt(WebTestHelper.buildURL("snprc_ehr", containerPath, "animalHistory"));
        return new AnimalHistoryPage(test);
    }
}
