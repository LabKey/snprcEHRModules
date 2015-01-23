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
