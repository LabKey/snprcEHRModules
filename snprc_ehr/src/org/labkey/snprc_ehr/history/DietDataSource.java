package org.labkey.snprc_ehr.history;

/**
 * Created by Marty on 11/28/2016.
 */

import org.labkey.api.data.Container;
import org.labkey.api.data.Results;
import org.labkey.api.ehr.history.AbstractDataSource;
import org.labkey.api.module.Module;

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

        addStringFieldLookup(rs, sb, "meaning", "code", "Diet");
        addStringField(rs, sb, "code", "SNOMED");
        addDateField(c, rs, sb, "enddate", "End Date");

        return sb.toString();
    }
}

