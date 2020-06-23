package org.labkey.snprc_ehr.security;

import org.labkey.api.security.roles.AbstractRole;


/**
 * Created on 6/19/2020. tjh
 */
public class SNPRCColonyAdminRole extends AbstractRole
{
    public SNPRCColonyAdminRole()
    {
        super("SNPRC Colony Admin", "This role is required to perform colony admin tasks, such as, adding animals to the colony.",
                SNPRC_ERHEditPermission.class,
                ManageLookupTablesPermission.class,
                SNPRCColonyAdminPermission.class
        );

    }
}
