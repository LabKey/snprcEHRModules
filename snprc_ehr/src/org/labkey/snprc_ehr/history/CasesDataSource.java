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
public class CasesDataSource extends AbstractDataSource
{
    public CasesDataSource(Module module)
    {
        super("study", "cases", "Case Opened", "Clinical", module);
    }

    @Override
    protected String getHtml(Container c, Results rs, boolean redacted) throws SQLException
    {
        StringBuilder sb = new StringBuilder();

        addStringField(rs, sb, "caseid", "Admit Id");
        addStringField(rs, sb, "category", "Category");
        addStringField(rs, sb, "problem", "PDX");
        addStringField(rs, sb, "sdx", "SDX");
        addStringField(rs, sb, "admitcomplaint", "Admitting Complaint");
        addStringFieldLookup(rs, sb, "displayName", "assignedvet", "Assigned Vet");
        addDateField(c, rs, sb, "enddate", "End Date");

        return sb.toString();
    }

    @Override
    protected Set<String> getColumnNames()
    {
        return PageFlowUtil.set("Id", "date", "enddate", "category", "problem", "sdx", "admitcomplaint", "assignedvet/displayName");
    }
}
