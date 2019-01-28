package org.labkey.snprc_scheduler.security;

import org.labkey.api.security.roles.AbstractRole;


/**
 * Created by thawkins on 9/12/2018.
 */
public class SNPRC_schedulerEditorsRole extends AbstractRole
{
    public SNPRC_schedulerEditorsRole()
    {
        super("SNPRC Schedule editors", "Schedule editors may read and edit SNPRC Timelines and Schedules.",
                SNPRC_schedulerEditorsPermission.class,
                SNPRC_schedulerReadersPermission.class
        );


    }
}