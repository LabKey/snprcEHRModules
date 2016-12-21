package org.labkey.snprc_ehr.history;

import org.labkey.api.data.Container;
import org.labkey.api.data.Results;
import org.labkey.api.ehr.history.AbstractDataSource;
import org.labkey.api.module.Module;
import org.labkey.api.util.PageFlowUtil;

import java.sql.SQLException;
import java.util.Set;

/**
 * Created by Marty on 12/20/2016.
 */
public class DefaultAssignmentDataSource extends AbstractDataSource
{
    public DefaultAssignmentDataSource(Module module)
    {
        super("study", "Assignment", "Assignment", "Assignments", module);
    }

    @Override
    protected String getHtml(Container c, Results rs, boolean redacted) throws SQLException
    {
        StringBuilder sb = new StringBuilder();

        addStringField(rs, sb, "protocol", "Protocol");
        addStringFieldLookup(rs, sb, "description", "assignmentStatus", "Status");
        addDateField(c, rs, sb, "enddate", "End Date");

        return sb.toString();
    }

    @Override
    protected Set<String> getColumnNames()
    {
        return PageFlowUtil.set("Id", "date", "protocol", "assignmentStatus/description", "enddate");
    }
}
