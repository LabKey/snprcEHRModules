package org.labkey.snprc_ehr.security;

import org.labkey.api.security.roles.AbstractRole;


/**
 * Created by lkacimi on 3/28/2017.
 */
public class ManageGroupMembersRole extends AbstractRole
{
    public ManageGroupMembersRole()
    {
        super("SNPRC Group Members", "This role is required in order to manage group categories, groups and group members.",
                ManageGroupMembersPermission.class
        );


    }
}
