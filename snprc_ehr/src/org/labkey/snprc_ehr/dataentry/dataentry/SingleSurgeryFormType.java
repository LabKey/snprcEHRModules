/*
 * Copyright (c) 2016-2018 LabKey Corporation
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
import org.labkey.api.ehr.dataentry.BloodDrawFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.EncounterForm;
import org.labkey.api.ehr.dataentry.ExtendedAnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.NonStoreFormSection;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.ehr.security.EHRSurgeryEntryPermission;
import org.labkey.api.module.Module;
import org.labkey.api.module.ModuleLoader;
import org.labkey.api.security.PrincipalType;
import org.labkey.api.security.SecurityManager;
import org.labkey.api.security.UserPrincipal;
import org.labkey.api.view.template.ClientDependency;

import java.util.Arrays;
import java.util.List;

/**
 * User: bimber
 * Date: 7/29/13
 * Time: 5:03 PM
 */
public class SingleSurgeryFormType extends EncounterForm
{
    public static final String NAME = "Surgery";

    public SingleSurgeryFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "Surgery", "Surgery", Arrays.<FormSection>asList(
                new NonStoreFormSection("Instructions", "Instructions", "ehr-surgeryinstructionspanel", Arrays.asList(ClientDependency.supplierFromPath("ehr/panel/SurgeryInstructionsPanel.js"))),
                new TaskFormSection(),
                new ClinicalEncountersFormPanelSection("Surgery"),
                new ExtendedAnimalDetailsFormSection(),
                new EncounterChildFormSection("ehr", "encounter_participants", "Staff", false),
                new EncounterChildFormSection("ehr", "encounter_summaries", "Narrative", true),
                new EncounterMedicationsFormSection("study", "Drug Administration", "Medications/Treatments Given", true),
                new EncounterMedicationsFormSection("study", "Treatment Orders", "Medication/Treatment Orders", false),
                new EncounterChildFormSection("study", "weight", "Weight", false, "EHR.data.WeightClientStore", Arrays.asList(ClientDependency.supplierFromPath("ehr/data/WeightClientStore.js")), null),
                new BloodDrawFormSection(false, EHRService.FORM_SECTION_LOCATION.Tabs),
                new EncounterChildFormSection("ehr", "snomed_tags", "Diagnostic Codes", true)
        ));

//        if (ctx.getContainer().getActiveModules().contains(ModuleLoader.getInstance().getModule("onprc_billing")))
//        {
//            addSection(new EncounterChildFormSection("onprc_billing", "miscCharges", "Misc. Charges", false, "EHR.data.MiscChargesClientStore", Arrays.asList(ClientDependency.supplierFromPath("ehr/data/MiscChargesClientStore.js")), null));
//        }

        addClientDependency(ClientDependency.supplierFromPath("ehr/model/sources/Surgery.js"));
        addClientDependency(ClientDependency.supplierFromPath("ehr/window/OpenSurgeryCasesWindow.js"));
        addClientDependency(ClientDependency.supplierFromPath("ehr/panel/SurgeryDataEntryPanel.js"));
        setDisplayReviewRequired(true);
        setJavascriptClass("EHR.panel.SurgeryDataEntryPanel");

        for (FormSection s : this.getFormSections())
        {
            s.addConfigSource("Encounter");
            s.addConfigSource("Surgery");
        }
    }

    @Override
    protected List<String> getButtonConfigs()
    {
        List<String> ret = super.getButtonConfigs();
        ret.add("OPENSURGERYCASES");

        return ret;
    }

    @Override
    protected boolean canInsert()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), EHRSurgeryEntryPermission.class))
            return false;

        return super.canInsert();
    }

    @Override
    protected Integer getDefaultAssignedTo()
    {
        UserPrincipal up = SecurityManager.getPrincipal(SurgeryFormType.DEFAULT_GROUP, getCtx().getContainer(), true);
        return up != null && up.getPrincipalType() == PrincipalType.GROUP ? up.getUserId() : null;
    }

    @Override
    protected Integer getDefaultReviewRequiredPrincipal()
    {
        UserPrincipal up = SecurityManager.getPrincipal(SurgeryFormType.DEFAULT_GROUP, getCtx().getContainer(), true);
        return up != null && up.getPrincipalType() == PrincipalType.GROUP ? up.getUserId() : null;
    }
}
