/*
 * Copyright (c) 2017 LabKey Corporation
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

import org.labkey.api.ehr.dataentry.AbstractDataEntryForm;
import org.labkey.api.ehr.dataentry.DataEntryForm;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.module.Module;
import org.labkey.api.query.DetailsURL;
import org.labkey.api.view.HttpView;
import org.labkey.api.view.JspView;
import org.labkey.api.view.NavTree;
import org.labkey.api.view.WebPartView;
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

        super(ctx, owner, NAME, "Animal Group Management", "Colony Management", Arrays.<FormSection>asList());

    }

    @Override
    public HttpView createView()
    {
        JspView<DataEntryForm> view = new JspView<>("/org/labkey/snprc_ehr/views/AnimalGroups.jsp", this);
        view.setTitle(getLabel());
        view.setHidePageTitle(true);
        view.setFrame(WebPartView.FrameType.PORTAL);

        view.addClientDependencies(getClientDependencies());
        return view;
    }

    @Override
    protected boolean canInsert()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), ManageGroupMembersPermission.class))
            return false;
        else
            return super.canInsert();
    }

    @Override
    public NavTree appendNavTrail(NavTree root, String title)
    {
        root.addChild("Group Members", DetailsURL.fromString("/animalgroups/GroupCategories.view", getCtx().getContainer()).getActionURL());
        root.addChild(title == null ? "Group Members" : title);
        return root;
    }
}
