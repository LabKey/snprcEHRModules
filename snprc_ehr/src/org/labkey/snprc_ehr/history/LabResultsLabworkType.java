/*
 * Copyright (c) 2015 LabKey Corporation
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

import org.labkey.api.data.Results;
import org.labkey.api.ehr.history.SortingLabworkType;
import org.labkey.api.query.FieldKey;
import org.labkey.api.util.PageFlowUtil;

import java.sql.SQLException;
import java.util.Set;

/**
 * Created by bimber on 1/23/2015.
 */
public class LabResultsLabworkType extends SortingLabworkType
{
    public LabResultsLabworkType()
    {
        //terry - is 'Lab Results' what you used for test_type?
        super("Lab Results", "study", "Lab Results", "Lab Results");
        _resultField = "result";
    }

    /**
     * Specify the columns you want returned here
     */
    @Override
    protected Set<String> getColumnNames()
    {
        return PageFlowUtil.set(_idField, _dateField, _runIdField, _testIdField, _resultField);
    }

    @Override
    protected String getLine(Results rs, boolean redacted) throws SQLException
    {
        StringBuilder sb = new StringBuilder();
        String result = rs.getString(FieldKey.fromString(_resultField));
        String testId = rs.getString(FieldKey.fromString(_testIdField));

        if (testId != null)
        {
            sb.append("<td>");
            sb.append(testId);
            sb.append("</td><td>");

            if (result != null)
                sb.append(result);

            sb.append("</td>");
        }

        return sb.toString();
    }
}
