package org.labkey.snprc_scheduler.security;

import org.labkey.api.security.roles.AbstractRole;


/**
 * Created by thawkins on 1/25/2019.
 */
public class SNPRC_schedulerAdminRole extends AbstractRole
{
    public SNPRC_schedulerAdminRole()
    {
        super("SNPRC Schedule Admins", "Schedule Admins have full authority over SNPRC Timelines and Schedules.",
                SNPRC_schedulerEditorsPermission.class,
                SNPRC_schedulerReadersPermission.class,
                SNPRC_schedulerReviewersPermission.class,
                SNPRC_schedulerAdminPermission.class
        );


    }
}