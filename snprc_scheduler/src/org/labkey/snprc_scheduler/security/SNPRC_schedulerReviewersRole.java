package org.labkey.snprc_scheduler.security;

import org.labkey.api.security.roles.AbstractRole;


/**
 * Created by thawkins on 1/25/2019.
 */
public class SNPRC_schedulerReviewersRole extends AbstractRole
{
    public SNPRC_schedulerReviewersRole()
    {
        super("SNPRC Schedule Reviewers", "This role is required to approve/decline changes to SNPRC Timelines and Schedules.",
                SNPRC_schedulerReadersPermission.class,
                SNPRC_schedulerReviewersPermission.class
        );


    }
}