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
import java.time.format.DateTimeFormatter;

public class DefaultTreatmentOrdersDataSource extends AbstractDataSource
{
    private static final DateTimeFormatter DISPLAY_FORMAT = DateTimeFormatter.ofPattern("MM-dd-yyyy H:mm a");

    public DefaultTreatmentOrdersDataSource(Module module)
    {
        super("study", "treatment_order", "Medication Ordered", "Therapy", module);
        setShowTime(true);
    }

    @Override
    protected String getHtml(Container c, Results rs, boolean redacted) throws SQLException
    {

        String sb = safeAppend(rs, null, "code") +
                safeAppend(rs, "Category", "category") +
                safeAppendDateAndTime(rs, "Start Date", "date") +
                safeAppend(rs, "Amount", "amount") +
                safeAppend(rs, "Units", "amount_units") +
                safeAppend(rs, "Route", "route") +
                safeAppend(rs, "Frequency", "frequency") +
                safeAppend(rs, "Duration", "duration") +
                safeAppend(rs, "Reason", "reason") +
                safeAppend(rs, "Remark", "remark") +
                safeAppend(rs, "Description", "description") +
                safeAppendDateAndTime(rs, "End Date", "enddate");

        return sb;
    }
    protected String safeAppendDateAndTime(Results rs, String label, String field) throws SQLException {
        FieldKey fk = FieldKey.fromString(field);
        String result = "";
        if (rs.hasColumn(fk) && rs.getObject(fk) != null) {
            // Read the value as a Timestamp rather than round-tripping through rs.getString(): the string
            // form is driver-specific (fractional seconds, and a trailing offset for timestamptz on pgjdbc),
            // so parsing it against a fixed pattern is fragile across databases.
            String time = rs.getTimestamp(fk).toLocalDateTime().format(DISPLAY_FORMAT);
            result = (label == null ? "" : label + ": ") + time + "\n";
        }

        return PageFlowUtil.filter(result);
    }


}
