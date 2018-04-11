package org.labkey.snprc_ehr.snd.triggers;

import org.labkey.api.data.Container;
import org.labkey.api.ehr.EHRDemographicsService;
import org.labkey.api.ehr.demographics.AnimalRecord;
import org.labkey.api.query.ValidationException;
import org.labkey.api.security.User;
import org.labkey.api.snd.Event;
import org.labkey.api.snd.EventData;
import org.labkey.api.snd.EventTrigger;
import org.labkey.api.snd.TriggerAction;

import java.util.List;
import java.util.Map;

public class KetamineReactorTrigger implements EventTrigger
{

    @Override
    public void onInsert(Container c, User u, TriggerAction triggerAction, Map<String, Object> extraContext)
    {
        Event event = triggerAction.getEvent();
        EventData eventData = triggerAction.getEventData();
        String subjectId = triggerAction.getEvent().getSubjectId();

        AnimalRecord ar = EHRDemographicsService.get().getAnimal(c, subjectId);
        if (ar == null)
        {
            event.setEventException(new ValidationException("Animal Id not found", ValidationException.SEVERITY.ERROR));
        }
        else
        {
            List<Map<String, Object>> flags = ar.getActiveFlags();
            for (Map<String, Object> flag : flags)
            {
                if (flag.containsKey("flag/value"))
                {
                    if (flag.get("flag/value").equals("Ketamine reactor"))
                    {
                        eventData.setException(event, new ValidationException("Animal " + subjectId + " has a ketamine allergy."));
                        break;
                    }
                }
            }
        }
    }

    @Override
    public void onUpdate(Container c, User u, TriggerAction triggerAction, Map<String, Object> extraContext)
    {
        onInsert(c, u, triggerAction, extraContext);
    }

    @Override
    public Integer getOrder()
    {
        return null;
    }
}
