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
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class DefaultTreatmentOrdersDataSource extends AbstractDataSource
{
    public DefaultTreatmentOrdersDataSource(Module module)
    {
        super("study", "treatment_order", "Medication Ordered", "Therapy", module);
        setShowTime(true);
    }

    @Override
    protected String getHtml(Container c, Results rs, boolean redacted) throws SQLException
    {
        StringBuilder sb = new StringBuilder();

        sb.append(safeAppend(rs, null, "code"));
        sb.append(safeAppend(rs, "Category", "category"));
        sb.append(safeAppendDateAndTime(rs, "Start Date", "date"));
        sb.append(safeAppend(rs, "Amount", "amount"));
        sb.append(safeAppend(rs, "Units", "amount_units"));
        sb.append(safeAppend(rs, "Route", "route"));
        sb.append(safeAppend(rs, "Frequency", "frequency"));
        sb.append(safeAppend(rs, "Duration", "duration"));
        sb.append(safeAppend(rs, "Reason", "reason"));
        sb.append(safeAppend(rs, "Remark", "remark"));
        sb.append(safeAppend(rs, "Description", "description"));
        sb.append(safeAppendDateAndTime(rs, "End Date", "enddate"));

        return sb.toString();
    }
    protected String safeAppendDateAndTime(Results rs, String label, String field) throws SQLException {
        FieldKey fk = FieldKey.fromString(field);
        String result = "";
        if (rs.hasColumn(fk) && rs.getObject(fk) != null) {
            String date = rs.getString(fk);
            String time = LocalDateTime.parse(date, DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.S")).format(DateTimeFormatter.ofPattern("MM-dd-yyyy H:mm a"));
            result = (label == null ? "" : label + ": ") + time + "\n";
        }

        return PageFlowUtil.filter(result);
    }


}
