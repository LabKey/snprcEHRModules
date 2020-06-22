package org.labkey.snprc_ehr.security;

import org.labkey.api.security.permissions.AbstractPermission;

/**
 * Created on 6/19/2020. tjh
 */
public class SNPRCColonyAdminPermission extends AbstractPermission
{
    public SNPRCColonyAdminPermission()
    {
        super("SNPRCColonyAdminPermission", "This role is required to perform colony admin tasks, such as, adding animals to the colony.");
    }
}
