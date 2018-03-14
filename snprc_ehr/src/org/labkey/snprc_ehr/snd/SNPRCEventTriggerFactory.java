package org.labkey.snprc_ehr.snd;

import org.labkey.api.snd.EventTrigger;
import org.labkey.api.snd.EventTriggerFactory;
import org.labkey.snprc_ehr.snd.triggers.TestTrigger;

public class SNPRCEventTriggerFactory implements EventTriggerFactory
{

    @Override
    public EventTrigger createTrigger(String category)
    {
        EventTrigger trigger;

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
