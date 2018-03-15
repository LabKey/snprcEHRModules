package org.labkey.snprc_ehr.snd;

import org.labkey.api.snd.EventDataTrigger;
import org.labkey.api.snd.EventDataTriggerFactory;
import org.labkey.snprc_ehr.snd.triggers.TestTrigger;

public class SNPRCEventDataTriggerFactory implements EventDataTriggerFactory
{

    @Override
    public EventDataTrigger createTrigger(String category)
    {
        EventDataTrigger trigger;

        switch (category)
        {
            case "TestTrigger":
                trigger = new TestTrigger();
                break;
            default:
                trigger = null;
        }

        return trigger;
    }
}
