package org.labkey.snprc_ehr.history;

import org.labkey.api.data.Container;
import org.labkey.api.data.Results;
import org.labkey.api.ehr.history.AbstractDataSource;
import org.labkey.api.module.Module;
import org.labkey.api.util.PageFlowUtil;

import java.sql.SQLException;
import java.util.Set;

/**
 * Created by Marty on 12/21/2016.
 */
public class DefaultDepartureDataSource extends AbstractDataSource
{
    public DefaultDepartureDataSource(Module module)
    {
        super("study", "Departure", "Departure", "Arrival/Departure", module);
    }

    @Override
    protected String getHtml(Container c, Results rs, boolean redacted) throws SQLException
    {
        StringBuilder sb = new StringBuilder();

        addStringFieldLookup(rs, sb, "description", "dispositionType", "Disposition Type");

        return sb.toString();
    }

    @Override
    protected Set<String> getColumnNames()
    {
        return PageFlowUtil.set("Id", "date", "dispositionType/description");
    }
}
