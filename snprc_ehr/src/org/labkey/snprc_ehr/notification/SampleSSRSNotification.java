package org.labkey.snprc_ehr.notification;

/**
 * Created by: jeckels
 * Date: 6/29/16
 */
public class SampleSSRSNotification extends AbstractSSRSNotification
{
    @Override
    public String getName()
    {
        return "SampleSSRS";
    }

    @Override
    public String getCategory()
    {
        return "SSRS";
    }

    @Override
    public String getCronString()
    {
        return "0 0 6 * * ?";
    }

    @Override
    public String getScheduleDescription()
    {
        return "every day at 6AM";
    }

    @Override
    public String getDescription()
    {
        return "SSRS-based notification 1";
    }

}
