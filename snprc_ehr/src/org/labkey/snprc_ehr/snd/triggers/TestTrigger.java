package org.labkey.snprc_ehr.snd.triggers;

import org.labkey.api.data.Container;
import org.labkey.api.security.User;
import org.labkey.api.snd.EventTrigger;
import org.labkey.api.snd.TriggerAction;

import java.util.Map;

public class TestTrigger implements EventTrigger
{
    @Override
    public void onInsert(Container c, User u, TriggerAction triggerAction, Map<String, Object> extraContext)
    {

    }

    @Override
    public void onUpdate(Container c, User u, TriggerAction triggerAction, Map<String, Object> extraContext)
    {

    }

    @Override
    public Integer getOrder()
    {
        return 1;
    }
}
