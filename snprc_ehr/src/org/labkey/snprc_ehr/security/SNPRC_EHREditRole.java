package org.labkey.snprc_ehr.security;

import org.labkey.api.security.roles.AbstractRole;


/**
 * Created on 3/1/2019. tjh
 */
public class SNPRC_EHREditRole extends AbstractRole
{
    public SNPRC_EHREditRole()
    {
        super("SNPRC Edit Role", "This role is required to perform table updates",
                SNPRC_ERHEditPermission.class
        );

    }
}
