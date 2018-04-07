package org.labkey.snprc_ehr.snd.triggers;

import org.labkey.api.data.Container;
import org.labkey.api.query.ValidationException;
import org.labkey.api.security.User;
import org.labkey.api.snd.Event;
import org.labkey.api.snd.EventData;
import org.labkey.api.snd.EventDataTrigger;
import org.labkey.api.snd.TriggerAction;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class FemaleOnlyTrigger implements EventDataTrigger
{
    private static final String expectedGender = "F";

    @Override
    public void onInsert(Container c, User u, TriggerAction triggerAction, Map<String, Object> extraContext)
    {
        Event event = triggerAction.getIncomingEvent();
        EventData eventData = triggerAction.getIncomingEventData();

        List<ValidationException> errors = new ArrayList<>();
        boolean genderMatches = TriggerHelper.verifyGender(c, triggerAction.getIncomingEvent().getSubjectId(), expectedGender, errors);

        if (errors.size() > 0)
        {
            event.setEventException(errors.get(0));
        }

        if (!genderMatches)
        {
            eventData.setException(event, new ValidationException("This package cannot be performed on an animal that is not a female"));
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
