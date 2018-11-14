/*
 * Copyright (c) 2018 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.labkey.snprc_ehr.snd.triggers;

import org.labkey.api.data.Container;
import org.labkey.api.query.ValidationException;
import org.labkey.api.security.User;
import org.labkey.api.snd.Event;
import org.labkey.api.snd.EventData;
import org.labkey.api.snd.EventTrigger;
import org.labkey.api.snd.TriggerAction;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class MaleOnlyTrigger implements EventTrigger
{
    private static final String expectedGender = "M";

    @Override
    public void onInsert(Container c, User u, TriggerAction triggerAction, Map<String, Object> extraContext)
    {
        Event event = triggerAction.getEvent();
        EventData eventData = triggerAction.getEventData();

        List<ValidationException> errors = new ArrayList<>();
        boolean genderMatches = TriggerHelper.verifyGender(c, triggerAction.getEvent().getSubjectId(), expectedGender, errors);

        if (errors.size() > 0)
        {
            event.setException(errors.get(0));
        }

        if (!genderMatches)
        {
            eventData.setException(event, new ValidationException("This package cannot be performed on an animal that is not a male"));
        }
    }

    @Override
    public void onUpdate(Container c, User u, TriggerAction triggerAction, Map<String, Object> extraContext)
    {
        onInsert(c, u, triggerAction, extraContext);
    }
}