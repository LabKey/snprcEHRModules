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

import java.sql.SQLException;

public class CycleDatasource extends AbstractDataSource
{
    public CycleDatasource(Module module)
    {
        super("study", "estrousCyclePivot", "Cycle", "Cycle", module);
        setShowTime(true);
    }

    @Override
    protected String getHtml(Container c, Results rs, boolean redacted) throws SQLException
    {
        StringBuilder sb = new StringBuilder();

        addStringField(rs, sb, "tumescence_index::observations", "Tumescence Index");
        addStringField(rs, sb, "vaginal_bleeding::observations", "Vaginal Bleeding");
        addStringField(rs, sb, "purple_color::observations", "Purple Color");
        addStringField(rs, sb, "carrying_infant::observations", "Carrying Infant");
        addStringField(rs, sb, "male_status::observations", "Male Status");
        addStringField(rs, sb, "male_id::observations", "Male Id");
        addStringField(rs, sb, "cycle_location::observations", "Cycle Location");
        addStringField(rs, sb, "observer_emp_num::observations", "Observer");

        return sb.toString();
    }
}
