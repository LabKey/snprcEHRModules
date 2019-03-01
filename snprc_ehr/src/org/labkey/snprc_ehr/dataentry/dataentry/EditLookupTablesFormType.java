package org.labkey.snprc_ehr.dataentry.dataentry;


import org.labkey.api.ehr.dataentry.AbstractDataEntryForm;
import org.labkey.api.ehr.dataentry.DataEntryForm;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.module.Module;
import org.labkey.api.view.HttpView;
import org.labkey.api.view.JspView;
import org.labkey.snprc_ehr.security.ManageLookupTablesPermission;

import java.util.Arrays;

/**
 * Created by thawkins on 2/27/2019.
 */
public class EditLookupTablesFormType extends AbstractDataEntryForm
{
    public static final String NAME = "LookupTables";

    public EditLookupTablesFormType(DataEntryFormContext ctx, Module owner)
    {

        super(ctx, owner, NAME, "Manage Lookup Tables", "Lookup Tables", Arrays.<FormSection>asList());
    }

    @Override
    protected boolean canInsert()
    {

        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), ManageLookupTablesPermission.class))
        {
            return false;
        }

        return super.canInsert();
    }

    @Override
    public HttpView createView()
    {
        JspView<DataEntryForm> view = new JspView<>("/org/labkey/snprc_ehr/views/EditLookupTables.jsp", this);
        view.setTitle(getLabel());
        view.setHidePageTitle(true);
        view.addClientDependencies(getClientDependencies());
        return view;
    }

}
