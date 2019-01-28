package org.labkey.snprc_scheduler.security;

import org.labkey.api.security.permissions.AbstractPermission;

/**
 * Created by thawkins on 1/25/2019.
 */
public class SNPRC_schedulerAdminPermission extends AbstractPermission
{
    public SNPRC_schedulerAdminPermission()
    {
        super("SNPRC_schedulerAdminPermission", "This permission grants user full authority over SNPRC scheduler data.");
    }

}


