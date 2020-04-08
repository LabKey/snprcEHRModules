/*
 * Copyright (c) 2019 LabKey Corporation
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
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;

import java.util.ArrayList;
import java.util.List;

public class SNPRCTaskForm extends TaskForm
{
    public SNPRCTaskForm(DataEntryFormContext ctx, Module owner, String name, String label, String category, List<FormSection> sections)
    {
        super(ctx, owner, name, label, category, sections);
        setDisplayReviewRequired(true);  // Shows submit for review button
        addClientDependency(ClientDependency.supplierFromPath("snprc_ehr/buttons/customDataEntryButtons.js"));
    }

    @Override
    protected List<String> getButtonConfigs()
    {
        List<String> defaultButtons = new ArrayList<String>();
        defaultButtons.add("SAVEDRAFT");
        defaultButtons.add("SUBMIT");
        //defaultButtons.add("REVIEW");
        defaultButtons.add("SNPRC_REVIEW");

        return defaultButtons;
    }

    @Override
    protected List<String> getMoreActionButtonConfigs()
    {
        return super.getMoreActionButtonConfigs();
    }
}
