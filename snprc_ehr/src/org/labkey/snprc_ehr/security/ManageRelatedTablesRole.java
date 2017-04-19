package org.labkey.snprc_ehr.security;

import org.labkey.api.security.roles.AbstractRole;

/**
 * Created by lkacimi on 4/12/2017.
 */
public class ManageRelatedTablesRole extends AbstractRole
{
    public ManageRelatedTablesRole()
    {
        super("SNPRC Related Tables", "This role is required to perform CRUD operations on related tables",
                ManageRelatedTablesPermission.class
        );

    }
}
