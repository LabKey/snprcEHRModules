package org.labkey.snprc_ehr.dataentry.dataentry;

import org.labkey.api.ehr.dataentry.AbstractDataEntryForm;
import org.labkey.api.ehr.dataentry.DataEntryForm;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.module.Module;
import org.labkey.api.view.HttpView;
import org.labkey.api.view.JspView;
import org.labkey.api.view.WebPartView;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.snprc_ehr.security.ManageGroupMembersPermission;

import java.util.Arrays;

/**
 * Created by lkacimi on 3/14/2017.
 */
public class GroupsCategoriesFormType extends AbstractDataEntryForm
{
    public static final String NAME = "animalGroupCategories";

    public GroupsCategoriesFormType(DataEntryFormContext ctx, Module owner)
    {

        super(ctx, owner, NAME, "Animal Group Categories", "Colony Management", Arrays.<FormSection>asList());

    }

    @Override
    public HttpView createView()
    {
        JspView<DataEntryForm> view = new JspView<>("/org/labkey/snprc_ehr/views/animal_groups.jsp", this);
        view.setTitle(getLabel());
        view.setHidePageTitle(true);
        view.setFrame(WebPartView.FrameType.PORTAL);

        view.addClientDependency(ClientDependency.fromPath("ehr/ehr_ext4_dataEntry"));

        view.addClientDependencies(getClientDependencies());
        return view;
    }

    @Override
    protected boolean canInsert()
    {

        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), ManageGroupMembersPermission.class))
        {
            return false;
        }

        return super.canInsert();
    }


}
