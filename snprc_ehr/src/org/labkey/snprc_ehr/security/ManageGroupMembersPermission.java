package org.labkey.snprc_ehr.security;

import org.labkey.api.security.permissions.AbstractPermission;

/**
 * Created by lkacimi on 3/28/2017.
 */
public class ManageGroupMembersPermission extends AbstractPermission
{
    public ManageGroupMembersPermission()
    {
        super("ManageGroupMembersPermission", "This is the base permission required to be able to manage group categories and group members");
    }

}
