/*
 * Copyright (c) 2016 LabKey Corporation
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
package org.labkey.snprc_ehr.dataentry.dataentry;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.SimpleFormPanelSection;
import org.labkey.api.view.template.ClientDependency;

/**
 * User: bimber
 * Date: 1/17/14
 * Time: 3:48 PM
 */
public class PathologyNotesFormPanelSection extends SimpleFormPanelSection
{
    public PathologyNotesFormPanelSection()
    {
        super("ehr", "encounter_summaries", "Notes", false);

        addClientDependency(ClientDependency.supplierFromPath("ehr/buttons/encounterButtons.js"));
        addClientDependency(ClientDependency.supplierFromPath("ehr/model/sources/EncounterChild.js"));
        setLocation(EHRService.FORM_SECTION_LOCATION.Tabs);

        addConfigSource("Encounter");
        addConfigSource("EncounterChild");
    }
}
