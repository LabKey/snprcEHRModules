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
package org.labkey.snprc_ehr.snd;

import org.labkey.api.snd.EventTrigger;
import org.labkey.api.snd.EventTriggerFactory;
import org.labkey.snprc_ehr.snd.triggers.BloodDrawTrigger;
import org.labkey.snprc_ehr.snd.triggers.FemaleOnlyTrigger;
import org.labkey.snprc_ehr.snd.triggers.KetamineReactorTrigger;
import org.labkey.snprc_ehr.snd.triggers.MaleOnlyTrigger;
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
            case "Blood Draw":
                trigger = new BloodDrawTrigger();
                break;
            case "Male Only":
                trigger = new MaleOnlyTrigger();
                break;
            case "Female Only":
                trigger = new FemaleOnlyTrigger();
                break;
            case "Ketamine Reactor":
                trigger = new KetamineReactorTrigger();
                break;
            default:
                trigger = null;
        }

        return trigger;
    }
}
