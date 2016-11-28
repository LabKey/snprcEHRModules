package org.labkey.snprc_ehr.history;

/**
 * Created by Marty on 11/28/2016.
 */

import org.labkey.api.data.Container;
import org.labkey.api.data.Results;
import org.labkey.api.ehr.history.AbstractDataSource;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;
import org.labkey.api.util.DateUtil;

import java.sql.SQLException;

public class DietDataSource extends AbstractDataSource
{
    public DietDataSource(Module module)
    {
        super("study", "diet", "Diet", "Diet", module);
        setShowTime(true);
    }

    @Override
    protected String getHtml(Container c, Results rs, boolean redacted) throws SQLException
    {
        StringBuilder sb = new StringBuilder();

        if (rs.hasColumn(FieldKey.fromString("code")) && rs.getObject("code") != null)
        {
            addRow(sb, "Diet", rs.getString("code"));
        }

        if (rs.hasColumn(FieldKey.fromString("enddate")) && rs.getObject("enddate") != null)
        {
            addRow(sb, "End Date", DateUtil.formatDate(c, rs.getDate("enddate")));
        }

        return sb.toString();
    }

    private void addRow(StringBuilder sb, String displayLabel, String value)
    {
        sb.append(displayLabel);
        sb.append(": ");
        sb.append(value);
        sb.append("\n");
    }
}

