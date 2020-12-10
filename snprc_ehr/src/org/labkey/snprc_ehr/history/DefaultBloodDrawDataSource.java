/*
 * Copyright (c) 2016-2017 LabKey Corporation
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
package org.labkey.snprc_ehr.history;

import org.labkey.api.data.Container;
import org.labkey.api.data.Results;
import org.labkey.api.ehr.history.AbstractDataSource;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;
import org.labkey.api.util.PageFlowUtil;

import java.sql.SQLException;
import java.util.Set;

/**
 * Created by Marty on 12/19/2016.
 */
public class DefaultBloodDrawDataSource extends AbstractDataSource
{
    public DefaultBloodDrawDataSource(Module module)
    {
        super("study", "Blood", "Blood Draw", "Blood Draws", module);
        setShowTime(true);
    }

    @Override
    protected String getHtml(Container c, Results rs, boolean redacted) throws SQLException
    {
        StringBuilder sb = new StringBuilder();

        addFloatWithUnitsField(rs, sb, "quantity", "Total Quantity", "mL");
        addIntegerField(rs, sb, "project", "Charge Id");
        addStringFieldLookup(rs, sb, "displayName", "project", "Project");
        addResearchField(rs, sb);
        addStringField(rs, sb, "remark", "Remark");

        return sb.toString();
    }

    @Override
    protected Set<String> getColumnNames()
    {
        return PageFlowUtil.set("Id", "date", "quantity", "project", "project/displayName", "project/research", "remark");
    }

    protected void addResearchField(Results rs, StringBuilder sb) throws SQLException
    {
        FieldKey fieldKey = FieldKey.fromParts("project", "research");
        if( rs.hasColumn(fieldKey) && rs.getObject(fieldKey) != null)
        {
            addField(sb, "Research", "", rs.getBoolean(fieldKey)?"true":"false");
        }
        else
        {
            addField(sb, "Research", "", "false");
        }
    }
}
