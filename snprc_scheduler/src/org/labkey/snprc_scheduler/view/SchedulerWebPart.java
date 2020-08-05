package org.labkey.snprc_scheduler.view;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.labkey.api.view.JspView;

public class SchedulerWebPart extends JspView
{
    private static final Logger _log = LogManager.getLogger(SchedulerWebPart.class);

    public SchedulerWebPart()
    {
        super("/org/labkey/snprc_scheduler/view/schedule.jsp", null);

        setTitle("SNPRC Scheduler");

    }
}
