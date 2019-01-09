package org.labkey.test.tests.snprc_scheduler;

import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.experimental.categories.Category;
import org.junit.runners.MethodSorters;
import org.labkey.remoteapi.CommandException;
import org.labkey.remoteapi.Connection;
import org.labkey.remoteapi.query.Filter;
import org.labkey.remoteapi.query.Row;
import org.labkey.remoteapi.query.Rowset;
import org.labkey.remoteapi.query.SelectRowsCommand;
import org.labkey.remoteapi.query.SelectRowsResponse;
import org.labkey.remoteapi.query.Sort;
import org.labkey.test.BaseWebDriverTest;
import org.labkey.test.TestTimeoutException;
import org.labkey.test.categories.SNPRC;
import org.labkey.test.pages.snprc_scheduler.BeginPage;
import org.labkey.test.util.ApiPermissionsHelper;
import org.labkey.test.util.PermissionsHelper;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static junit.framework.TestCase.assertTrue;
import static org.junit.Assert.assertEquals;
import static org.labkey.remoteapi.query.Filter.Operator.EQUAL;

@Category({SNPRC.class})
@BaseWebDriverTest.ClassTimeout(minutes = 45)
@FixMethodOrder(MethodSorters. NAME_ASCENDING)
public class SNPRC_schedulerTest extends BaseWebDriverTest
{
    private final String PROJECTNAME = "SNPRC_schedulerTest Project";

    protected static TestUser READER_USER = new TestUser("reader@foo.bar", SecurityGroup.READER, SecurityRole.READER);
    protected static TestUser EDITOR_USER = new TestUser("editor@foo.bar", SecurityGroup.EDITOR, SecurityRole.EDITOR);
    protected static TestUser BAD_USER = new TestUser("bad_user@foo.bar", SecurityGroup.NO_ACCESS, SecurityRole.NO_ACCESS);
    protected ApiPermissionsHelper _permissionsHelper = new ApiPermissionsHelper(this);

    @BeforeClass
    public static void setupProject()
    {
        SNPRC_schedulerTest init = (SNPRC_schedulerTest) getCurrentTest();

        init.doSetup();
    }


    @Override
    protected void doCleanup(boolean afterTest) throws TestTimeoutException
    {
        _containerHelper.deleteProject(getProjectName(), afterTest);
    }

    private void doSetup()
    {
        goToProjectHome();

        _containerHelper.createProject(getProjectName(), null);
        _containerHelper.enableModule("SNPRC_scheduler");

        // create users
        READER_USER.setUserId(_userHelper.createUser(READER_USER.getEmail(), false, true).getUserId().intValue());
        EDITOR_USER.setUserId(_userHelper.createUser(EDITOR_USER.getEmail(), false, true).getUserId().intValue());
        BAD_USER.setUserId(_userHelper.createUser(BAD_USER.getEmail(), false, true).getUserId().intValue());

        // create groups
        _permissionsHelper.createProjectGroup(SecurityGroup.READER.name, getProjectName());
        _permissionsHelper.createProjectGroup(SecurityGroup.EDITOR.name, getProjectName());

        // add users to groups
        _permissionsHelper.addUserToProjGroup(READER_USER.getEmail(), PROJECTNAME, SecurityGroup.READER.name);
        _permissionsHelper.addUserToProjGroup(EDITOR_USER.getEmail(), PROJECTNAME, SecurityGroup.EDITOR.name);

        // set folder permission for groups
        _permissionsHelper.addMemberToRole(SecurityGroup.READER.name, "Reader", PermissionsHelper.MemberType.group);
        _permissionsHelper.addMemberToRole(SecurityGroup.EDITOR.name, "Editor", PermissionsHelper.MemberType.group);

        // add groups to roles
        _permissionsHelper.addMemberToRole(SecurityGroup.READER.name, SecurityRole.READER.name, PermissionsHelper.MemberType.group);
        _permissionsHelper.addMemberToRole(SecurityGroup.EDITOR.name, SecurityRole.EDITOR.name, PermissionsHelper.MemberType.group);

        setup_sndData();
    }

    @Before
    public void preTest()
    {
        goToProjectHome();
    }


    public void setup_sndData()
    {
        executeAsyncScript(SetupScripts.ADD_PKG1);
        executeAsyncScript(SetupScripts.ADD_PKG2);
        executeAsyncScript(SetupScripts.ADD_PKG3);
        executeAsyncScript(SetupScripts.ADD_PROJECT1);
    }

    @Test
    public void test0_ReaderAccess()
    {
        // Verify React page renders for READER_ROLE
        impersonate(READER_USER.getEmail());

        BeginPage page = BeginPage.beginAt(this, getProjectName());
        int responseCode = getResponseCode();

        assertEquals("SNPRC_schedulerReaderRole doesn't have access to Begin.view", 200, responseCode);

        if (responseCode == 200)
        {
            page.beginPage_Tests();
            stopImpersonating();
        }
        else // no access - assume 403
        {
            clickButton("Stop Impersonating");
        }
    }

    @Test
    public void test1_EditorAccess()
    {
        // Verify React page renders for EDITOR_ROLE
        impersonate(EDITOR_USER.getEmail());
        ;

        BeginPage page = BeginPage.beginAt(this, getProjectName());
        int responseCode = getResponseCode();

        assertEquals("SNPRC_schedulerEditorRole doesn't have access to Begin.view", 200, responseCode);
        if (responseCode == 200)
        {
            page.beginPage_Tests();
            stopImpersonating();
        }
        else // no access - assume 403
        {
            clickButton("Stop Impersonating");
        }
    }

    @Test
    public void test2_NoAccessToPage()
    {
        impersonate(BAD_USER.getEmail());
        // Verify React page does not render for non-special user roles
        BeginPage.beginAt(this, getProjectName());
        assertEquals("Invalid user has access to Begin.view", 403, getResponseCode());

        clickButton("Stop Impersonating");
    }


    @Test
    public void test3_addTimelineData()
    {
        TimelineScripts ts = new TimelineScripts();

        String testProjectObjectId = getTestProjectObjectId();
        ArrayList<Map<String, Integer>> projectItems = getProjectItems(testProjectObjectId);

        // Verify READER_ROLE cannot insert timeline data
        impersonate(READER_USER.getEmail());
        {
            goToProjectHome();
            //BeginPage page = BeginPage.beginAt(this, getProjectName());
            runScriptExpectedFail(ts.addTimelineScript(testProjectObjectId, projectItems));
            stopImpersonating();
        }
        // Verify EDITOR_ROLE can insert timeline data
        impersonate(EDITOR_USER.getEmail());
        {
            goToProjectHome();
            runScript(ts.addTimelineScript(testProjectObjectId, projectItems));
            stopImpersonating();
        }
    }

    @Test
    public void test4_getTimelineData()
    {
        impersonate(READER_USER.getEmail());

        goToProjectHome();
        TimelineScripts ts = new TimelineScripts();
        runScript(ts.getTimelineScript(getTestProjectObjectId()));
        stopImpersonating();
    }

    @Test
    public void test5_deleteTimelineData()
    {
        impersonate(EDITOR_USER.getEmail());

        goToProjectHome();
        TimelineScripts ts = new TimelineScripts();
        runScript(ts.deleteTimelineScript(getTestProjectObjectId(), getTestTimelineObjectId()));
        stopImpersonating();
    }


    @Override
    protected BrowserType bestBrowser()
    {
        return BrowserType.CHROME;
    }

    @Override
    protected String getProjectName()
    {
        return PROJECTNAME;
    }

    @Override
    public List<String> getAssociatedModules()
    {
        //return Collections.singletonList("Snprc_scheduler");
        return Arrays.asList("ehr", "snprc_ehr", "snprc_scheduler", "SND");
    }

    private String getTestProjectObjectId()
    {
        Connection cn = createDefaultConnection(false);
        SelectRowsCommand selectCmd = new SelectRowsCommand("snd", "Projects");
        Filter f1 = new Filter("ProjectId", SetupScripts.PROJECT_ID, EQUAL);
        Filter f2 = new Filter("RevisionNum", SetupScripts.REVISION_NUM, EQUAL);
        selectCmd.addFilter(f1);
        selectCmd.addFilter(f2);

        String projectObjectId = "";

        SelectRowsResponse response = null;
        try
        {
            response = selectCmd.execute(cn, getCurrentContainerPath());
            Rowset rows = response.getRowset();
            for (Row row : rows)
            {
                projectObjectId = row.getValue("ObjectId").toString();
            }

        }
        catch (IOException | CommandException e)
        {
            // ignore
        }

        return projectObjectId;
    }

    private ArrayList<Map<String, Integer>> getProjectItems(String parentObjectId)
    {
        ArrayList<Map<String, Integer>> projectItems = new ArrayList<>();

        Connection cn = createDefaultConnection(false);
        SelectRowsCommand selectCmd = new SelectRowsCommand("snd", "ProjectItems");
        Filter f = new Filter("ParentObjectId", parentObjectId, EQUAL);
        selectCmd.addFilter(f);
        selectCmd.addSort("ProjectItemId", Sort.Direction.ASCENDING);

        try
        {
            SelectRowsResponse response = selectCmd.execute(cn, getCurrentContainerPath());

            Rowset rows = response.getRowset();
            Map<String, Integer> rowMap = null;

            for (Row row : rows)
            {
                rowMap = new HashMap<>();
                rowMap.put("ProjectItemId", Integer.parseInt(row.getValue("ProjectItemId").toString()));
                rowMap.put("SuperPkgId", Integer.parseInt(row.getValue("SuperPkgId").toString()));
                projectItems.add(rowMap);
            }

        }
        catch (IOException | CommandException e)
        {
            // ignore
        }

        return projectItems;

    }

    private String getTestTimelineObjectId()
    {
        Map<String, Integer> projectItems = new HashMap<>();
        String timelineObjectId = "";

        Connection cn = createDefaultConnection(false);
        SelectRowsCommand selectCmd = new SelectRowsCommand("snprc_scheduler", "Timeline");
        Filter f1 = new Filter("TimelineId", TimelineScripts.TIMELINE_ID, EQUAL);
        Filter f2 = new Filter("RevisionNum", TimelineScripts.REVISION_NUM, EQUAL);
        selectCmd.addFilter(f1);
        selectCmd.addFilter(f2);

        try
        {
            SelectRowsResponse response = selectCmd.execute(cn, getCurrentContainerPath());

            Rowset rows = response.getRowset();

            // timelineId/RevisionNum is unique - only one row should be returned
            for (Row row : rows)
            {
                timelineObjectId = row.getValue("ObjectId").toString();
            }

        }
        catch (IOException | CommandException e)
        {
            // ignore
        }

        return timelineObjectId;

    }

    private void runScript(String script)
    {
        String result = (String) executeAsyncScript(script);
        assertEquals("JavaScript API failure.", "Success!", result);
    }

    private void runScriptExpectedFail(String script)
    {
        String result = (String) executeAsyncScript(script);
        assertTrue("JavaScript API error condition failure.", result.toLowerCase().contains("\"success\" : false"));
    }

    public enum SecurityRole
    {
        EDITOR("SNPRC Schedule editors"),
        READER("SNPRC Schedule readers"),
        NO_ACCESS("No Access");

        private final String name;

        SecurityRole(String name)
        {
            this.name = name;
        }

        public String toString()
        {
            return name;
        }

    }

    public enum SecurityGroup
    {
        EDITOR("SNPRC Schedule editors group"),
        READER("SNPRC Schedule readers group"),
        NO_ACCESS("No Access group");

        private final String name;

        SecurityGroup(String name)
        {
            this.name = name;
        }

        public String toString()
        {
            return name;
        }
    }

    public static class TestUser
    {
        private final String _email;
        private final SecurityGroup _group;
        private final SecurityRole _role;
        private Integer _userId = null;


        public TestUser(String email, SecurityGroup group, SecurityRole role)
        {
            _email = email;
            _group = group;
            _role = role;
        }

        public String getEmail()
        {
            return _email;
        }

        public Integer getUserId()
        {
            return _userId;
        }

        public void setUserId(Integer userId)
        {
            _userId = userId;
        }

        public SecurityGroup getGroup()
        {
            return _group;
        }

        public SecurityRole getRole()
        {
            return _role;
        }

    }
}