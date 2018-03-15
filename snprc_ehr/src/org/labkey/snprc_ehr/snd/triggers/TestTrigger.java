package org.labkey.snprc_ehr.snd.triggers;

import org.labkey.api.data.Container;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.security.User;
import org.labkey.api.snd.Event;
import org.labkey.api.snd.EventData;
import org.labkey.api.snd.EventDataTrigger;
import org.labkey.api.snd.Package;

import java.util.List;

public class TestTrigger implements EventDataTrigger
{
    @Override
    public void onInsert(Container c, User u, EventData eventData, Event event, List<Package> pkgs, BatchValidationException errors)
    {

    }

    @Override
    public void onUpdate(Container c, User u, EventData eventData, Event event, List<Package> pkgs, BatchValidationException errors)
    {

    }

    @Override
    public Integer getOrder()
    {
        return null;
    }

    @Override
    public void setOrder(Integer order)
    {

    }
}
