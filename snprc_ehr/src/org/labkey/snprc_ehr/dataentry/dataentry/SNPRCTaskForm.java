package org.labkey.snprc_ehr.dataentry.dataentry;

import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.module.Module;

import java.util.ArrayList;
import java.util.List;

public class SNPRCTaskForm extends TaskForm
{
    public SNPRCTaskForm(DataEntryFormContext ctx, Module owner, String name, String label, String category, List<FormSection> sections)
    {
        super(ctx, owner, name, label, category, sections);
        setDisplayReviewRequired(true);  // Shows submit for review button
    }

    @Override
    protected List<String> getButtonConfigs()
    {
        List<String> defaultButtons = new ArrayList<String>();
        defaultButtons.add("SAVEDRAFT");
        defaultButtons.add("SUBMIT");
        defaultButtons.add("REVIEW");

        return defaultButtons;
    }

    @Override
    protected List<String> getMoreActionButtonConfigs()
    {
        return super.getMoreActionButtonConfigs();
    }
}