package org.labkey.test.tests.snprc_scheduler;

import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.experimental.categories.Category;
import org.labkey.test.BaseWebDriverTest;
import org.labkey.test.TestTimeoutException;
import org.labkey.test.categories.SNPRC;
import org.labkey.test.pages.snprc_scheduler.BeginPage;
import org.labkey.test.util.ApiPermissionsHelper;
import org.labkey.test.util.PermissionsHelper;

import java.util.Arrays;
import java.util.List;

import static org.junit.Assert.assertEquals;

@Category({SNPRC.class})
@BaseWebDriverTest.ClassTimeout(minutes = 45)
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
    }

    @Before
    public void preTest()
    {
        goToProjectHome();
    }


    @Test
    public void test_ReaderAccess()
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
    public void test_EditorAccess()
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
    public void test_NoAccessToPage()
    {
        impersonate(BAD_USER.getEmail());
        // Verify React page does not render for non-special user roles
        BeginPage.beginAt(this, getProjectName());
        assertEquals("Invalid user has access to Begin.view", 403, getResponseCode());

        clickButton("Stop Impersonating");
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