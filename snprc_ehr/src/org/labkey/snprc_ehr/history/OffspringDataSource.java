package org.labkey.snprc_ehr.history;

import org.labkey.api.data.Container;
import org.labkey.api.data.Results;
import org.labkey.api.ehr.history.AbstractDataSource;
import org.labkey.api.module.Module;

import java.sql.SQLException;

/**
 * Created by Marty on 12/8/2016.
 */
public class OffspringDataSource extends AbstractDataSource
{
    public OffspringDataSource(Module module)
    {
        super("study", "demographicsOffspring", "Offspring Birth", "Offspring", module);
        setShowTime(true);
    }

    @Override
    protected String getHtml(Container c, Results rs, boolean redacted) throws SQLException
    {
        StringBuilder sb = new StringBuilder();

        sb.append(safeAppend(rs, "Offspring ID", "Offspring"));
        sb.append(safeAppend(rs, "Sex", "sex"));
        sb.append(safeAppend(rs, "Sire", "sire"));
        sb.append(safeAppend(rs, "Dam", "dam"));

        return sb.toString();
    }
}
