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

import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;

import java.util.Arrays;

/**
 * User: bimber
 * Date: 7/29/13
 * Time: 5:03 PM
 */
public class IStatFormType extends TaskForm
{
    public static final String NAME = "iStat";

    public IStatFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "iStat Results", "Lab Results", Arrays.<FormSection>asList(
                new TaskFormSection(),
                new IStatPanelForm(),
                new LabworkFormSection("study", "iStat", "iStat", true)
        ));

        for (FormSection s : getFormSections())
        {
            s.addConfigSource("Labwork");
            s.addConfigSource("iStat");
        }

        addClientDependency(ClientDependency.supplierFromPath("snprc_ehr/model/sources/iStat.js"));
        addClientDependency(ClientDependency.supplierFromPath("snprc_ehr/window/IStatImportWindow.js"));
    }
}
