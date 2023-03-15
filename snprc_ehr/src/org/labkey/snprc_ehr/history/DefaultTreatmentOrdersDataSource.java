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

public class DefaultTreatmentOrdersDataSource extends AbstractDataSource
{
    public DefaultTreatmentOrdersDataSource(Module module)
    {
        super("study", "Treatment Orders", "Medication Ordered", "Therapy", module);
        setShowTime(true);
    }

    @Override
    protected String getHtml(Container c, Results rs, boolean redacted) throws SQLException
    {
        StringBuilder sb = new StringBuilder();

        sb.append(safeAppend(rs, null, "code"));
        sb.append(safeAppend(rs, "Category", "category"));
        sb.append(safeAppend(rs, "Start Date", "startdate"));
        sb.append(safeAppend(rs, "Dosage", "dosage"));
        sb.append(safeAppend(rs, "Units", "dosage_units"));
        sb.append(safeAppend(rs, "Route", "route"));
        sb.append(safeAppend(rs, "Frequency", "frequency/meaning"));
        sb.append(safeAppend(rs, "Duration", "duration"));
        sb.append(safeAppend(rs, "Reason", "reason"));
        sb.append(safeAppend(rs, "Remark", "remark"));
        sb.append(safeAppend(rs, "Description", "description"));
        sb.append(safeAppend(rs, "End Date", "enddate"));

        return sb.toString();
    }


}
