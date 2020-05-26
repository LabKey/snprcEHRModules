/*
 * Copyright (c) 2017-2019 LabKey Corporation
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
package org.labkey.snprc_ehr;

import org.jetbrains.annotations.NotNull;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerFilter;
import org.labkey.api.data.DbSchema;
import org.labkey.api.data.TableInfo;
import org.labkey.api.ldk.table.CustomPermissionsTable;
import org.labkey.api.query.SimpleUserSchema;
import org.labkey.api.security.User;
import org.labkey.api.security.permissions.DeletePermission;
import org.labkey.api.security.permissions.InsertPermission;
import org.labkey.api.security.permissions.Permission;
import org.labkey.api.security.permissions.UpdatePermission;
import org.labkey.snprc_ehr.security.ManageGroupMembersPermission;
import org.labkey.snprc_ehr.security.ManageLookupTablesPermission;

/**
 * Created by lkacimi on 5/4/2017.
 */
public class SNPRC_EHRUserSchema extends SimpleUserSchema
{
    public SNPRC_EHRUserSchema(User user, Container container, DbSchema dbschema)
    {
        super(SNPRC_EHRSchema.NAME, null, user, container, dbschema);
    }

    public SNPRC_EHRUserSchema(User user, Container container)
    {
        super(SNPRC_EHRSchema.NAME, null, user, container, SNPRC_EHRSchema.getInstance().getSchema());
    }

    @Override
    protected TableInfo createWrappedTable(String name, @NotNull TableInfo schemaTable, ContainerFilter cf)
    {
        String nameLowercased = name.toLowerCase();
        switch(nameLowercased){
            case SNPRC_EHRSchema.TABLE_VALID_VETS:
            case SNPRC_EHRSchema.TABLE_VALID_BIRTH_CODES:
            case SNPRC_EHRSchema.TABLE_VALID_DEATH_CODES:
            case SNPRC_EHRSchema.TABLE_VALID_INSTITUTIONS:
                return getCustomPermissionTable(createSourceTable(nameLowercased), cf, ManageLookupTablesPermission.class);
            case SNPRC_EHRSchema.TABLE_GROUP_CATEGORIES:
            case SNPRC_EHRSchema.TABLE_ANIMAL_GROUPS:
                return getCustomPermissionTable(createSourceTable(nameLowercased), cf, ManageGroupMembersPermission.class);
        }

        return super.createWrappedTable(name, schemaTable, cf);
    }


    private TableInfo getCustomPermissionTable(TableInfo schemaTable, ContainerFilter cf, Class<? extends Permission> perm)
    {
        CustomPermissionsTable ret = new CustomPermissionsTable(this, schemaTable, cf);
        ret.addPermissionMapping(InsertPermission.class, perm);
        ret.addPermissionMapping(UpdatePermission.class, perm);
        ret.addPermissionMapping(DeletePermission.class, perm);

        return ret.init();
    }


}
