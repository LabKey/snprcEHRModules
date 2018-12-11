package org.labkey.test.tests.snprc_scheduler;

import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.experimental.categories.Category;
import org.labkey.test.BaseWebDriverTest;
import org.labkey.test.TestTimeoutException;
import org.labkey.test.categories.SNPRC;
import org.labkey.test.pages.snprc_scheduler.BeginPage;

import java.util.Collections;
import java.util.List;

import static org.junit.Assert.*;

@Category ({SNPRC.class})
@BaseWebDriverTest.ClassTimeout(minutes = 45)
public class SNPRC_schedulerTest extends BaseWebDriverTest
{
    @Override
    protected void doCleanup(boolean afterTest) throws TestTimeoutException
    {
        _containerHelper.deleteProject(getProjectName(), afterTest);
    }

    @BeforeClass
    public static void setupProject()
    {
        SNPRC_schedulerTest init = (SNPRC_schedulerTest)getCurrentTest();

        init.doSetup();
    }

    private void doSetup()
    {
        _containerHelper.createProject(getProjectName(), null);
    }

    @Before
    public void preTest()
    {
        goToProjectHome();
    }

    @Test
    public void testSnprc_schedulerModule()
    {
        _containerHelper.enableModule("SNPRC_scheduler");
        assertEquals(200, getResponseCode());

        // Verify React page renders
        final String expectedTitle = "Procedure scheduling";
        assertTextPresent(expectedTitle);
        assertTextPresent("Projects");
        assertTextPresent("Timelines");
        assertTextPresent("Animals");
        assertTextPresent("Calendar");
    }

    @Override
    protected BrowserType bestBrowser()
    {
        return BrowserType.CHROME;
    }

    @Override
    protected String getProjectName()
    {
        return "SNPRC_schedulerTest Project";
    }

    @Override
    public List<String> getAssociatedModules()
    {
        return Collections.singletonList("Snprc_scheduler");
    }
}