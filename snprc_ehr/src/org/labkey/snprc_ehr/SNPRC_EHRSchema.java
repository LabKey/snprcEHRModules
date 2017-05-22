/*
 * Copyright (c) 2014 LabKey Corporation
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

import org.labkey.api.data.DbSchema;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.dialect.SqlDialect;

public class SNPRC_EHRSchema
{
    public static final String NAME = "snprc_ehr";
    private static final SNPRC_EHRSchema _instance = new SNPRC_EHRSchema();

    public static final String TABLE_VALID_INSTITUTIONS = "validinstitutions";
    public static final String TABLE_VALID_VETS = "validvets";
    public static final String TABLE_VALID_BIRTH_CODES = "valid_birth_code";
    public static final String TABLE_VALID_DEATH_CODES = "valid_death_code";
    public static final String TABLE_GROUP_CATEGORIES = "animal_group_categories";
    public static final String TABLE_ANIMAL_GROUPS = "animal_groups";


    private SNPRC_EHRSchema()
    {
        // private constructor to prevent instantiation from
        // outside this class: this singleton should only be
        // accessed via org.labkey.snprc_ehr.SNPRC_EHRSchema.getInstance()
    }

    public static SNPRC_EHRSchema getInstance()
    {
        return _instance;
    }

    public TableInfo getTableInfoAnimalGroupCategories()
    {
        return getSchema().getTable("animal_group_categories");
    }

    public TableInfo getTableInfoAnimalGroups()
    {
        return getSchema().getTable("animal_groups");
    }

    public TableInfo getTableInfoSpecies()
    {
        return getSchema().getTable("species");
    }

    public TableInfo getTableInfoValidInstitutions()
    {
        return getSchema().getTable("validInstitutions");
    }


    public TableInfo getTableInfoValidVets()
    {
        return getSchema().getTable("validVets");
    }

    public DbSchema getSchema()
    {
        return DbSchema.get(NAME);
    }

    public SqlDialect getSqlDialect()
    {
        return getSchema().getSqlDialect();
    }

    public DbSchema getStudySchema()
    {
        return DbSchema.get("study");
    }

}
