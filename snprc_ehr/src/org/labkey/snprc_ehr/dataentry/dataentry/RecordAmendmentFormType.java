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
import org.labkey.api.ehr.dataentry.SimpleFormPanelSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.ehr.security.EHRClinicalEntryPermission;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;

import java.util.Arrays;

/**
 * User: bimber
 * Date: 7/29/13
 * Time: 5:03 PM
 */
public class RecordAmendmentFormType extends TaskForm
{
    public static final String NAME = "RecordAmendment";

    public RecordAmendmentFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "Record Amendment", "Clinical", Arrays.<FormSection>asList(
                new TaskFormSection(),
                new SimpleFormPanelSection("study", "Clinical Remarks", "Amendment", false)
        ));

        for (FormSection s : this.getFormSections())
        {
            s.addConfigSource("ClinicalDefaults");
            s.addConfigSource("RecordAmendment");
        }

        addClientDependency(ClientDependency.supplierFromPath("ehr/model/sources/ClinicalDefaults.js"));
        addClientDependency(ClientDependency.supplierFromPath("ehr/model/sources/RecordAmendment.js"));
    }

    @Override
    protected boolean canInsert()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), EHRClinicalEntryPermission.class))
            return false;

        return super.canInsert();
    }

    @Override
    public boolean isVisible()
    {
        return false;
    }
}
