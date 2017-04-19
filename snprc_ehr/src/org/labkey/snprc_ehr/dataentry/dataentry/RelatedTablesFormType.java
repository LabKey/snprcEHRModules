package org.labkey.snprc_ehr.dataentry.dataentry;

import org.labkey.api.ehr.dataentry.AbstractDataEntryForm;
import org.labkey.api.ehr.dataentry.DataEntryForm;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.module.Module;
import org.labkey.api.view.HttpView;
import org.labkey.api.view.JspView;
import org.labkey.api.view.WebPartView;

import java.util.Arrays;

/**
 * Created by lkacimi on 4/12/2017.
 */
public class RelatedTablesFormType extends AbstractDataEntryForm
{
    public static final String NAME = "RelatedTables";

    public RelatedTablesFormType(DataEntryFormContext ctx, Module owner)
    {

        super(ctx, owner, NAME, "Related Tables", "Related Tables", Arrays.<FormSection>asList());

    }

    @Override
    public HttpView createView()
    {
        JspView<DataEntryForm> view = new JspView<>("/org/labkey/snprc_ehr/views/RelatedTables.jsp", this);
        view.setTitle(getLabel());
        view.setHidePageTitle(true);
        view.setFrame(WebPartView.FrameType.PORTAL);

        view.addClientDependencies(getClientDependencies());
        return view;
    }

}
