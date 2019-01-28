package org.labkey.snprc_scheduler.security;

import org.labkey.api.security.permissions.AbstractPermission;

/**
 * Created by thawkins on 1/25/2019.
 */
public class SNPRC_schedulerReviewersPermission extends AbstractPermission
{
    public SNPRC_schedulerReviewersPermission()
    {
        super("SNPRC_schedulerReviewerPermission", "This permission grants a user the ability to approve/decline SNPRC scheduler Timeline changes.");
    }

}