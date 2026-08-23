/*
 * Copyright (c) 2016-2026 LabKey Corporation
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
import java.time.format.DateTimeFormatterBuilder;
import java.time.temporal.ChronoField;

public class DefaultTreatmentOrdersDataSource extends AbstractDataSource
{
    // Postgres may omit fractional seconds when they are zero.
    private static final DateTimeFormatter DATE_TIME_PARSER = new DateTimeFormatterBuilder()
            .appendPattern("yyyy-MM-dd HH:mm:ss")
            .optionalStart()
            .appendFraction(ChronoField.NANO_OF_SECOND, 1, 9, true)
            .optionalEnd()
            .toFormatter();

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
            String date = rs.getString(fk);
            String time = LocalDateTime.parse(date, DATE_TIME_PARSER).format(DateTimeFormatter.ofPattern("MM-dd-yyyy H:mm a"));
            result = (label == null ? "" : label + ": ") + time + "\n";
        }

        return PageFlowUtil.filter(result);
    }


}
