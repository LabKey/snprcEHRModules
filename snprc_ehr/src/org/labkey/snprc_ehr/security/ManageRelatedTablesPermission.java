package org.labkey.snprc_ehr.security;

import org.labkey.api.security.permissions.AbstractPermission;

/**
 * Created by lkacimi on 4/12/2017.
 */
public class ManageRelatedTablesPermission extends AbstractPermission
{
    public ManageRelatedTablesPermission()
    {
        super("ManageRelatedTablesPermission", "This is the base permission required to perform CRUD operations on related tables");
    }
}
