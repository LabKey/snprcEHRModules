package org.labkey.snprc_ehr.snd;

import org.labkey.api.snd.EventDataTrigger;
import org.labkey.api.snd.EventTriggerFactory;
import org.labkey.snprc_ehr.snd.triggers.BloodDrawTrigger;
import org.labkey.snprc_ehr.snd.triggers.FemaleOnlyTrigger;
import org.labkey.snprc_ehr.snd.triggers.MaleOnlyTrigger;
import org.labkey.snprc_ehr.snd.triggers.TestTrigger;

public class SNPRCEventTriggerFactory implements EventTriggerFactory
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
            case "Blood Draw":
                trigger = new BloodDrawTrigger();
                break;
            case "Male Only":
                trigger = new MaleOnlyTrigger();
                break;
            case "Female Only":
                trigger = new FemaleOnlyTrigger();
                break;
            default:
                trigger = null;
        }

        return trigger;
    }
}
