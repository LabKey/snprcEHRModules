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
public class DefaultPregnanciesDataSource extends AbstractDataSource
{
    public DefaultPregnanciesDataSource(Module module)
    {
        super("study", "pregnancyConfirmation", "Estimated Date of Conception", "Pregnancy", module);
    }

    @Override
    protected String getHtml(Container c, Results rs, boolean redacted) throws SQLException
    {
        StringBuilder sb = new StringBuilder();

        addStringField(rs, sb, "sire", "Sire");
        addStringFieldLookup(rs, sb, "description", "termCode", "Termination");
        addDateField(c, rs, sb, "confirmDate", "Confirm Date");
        addDateField(c, rs, sb, "termDate", "Delivery Date");

        return sb.toString();
    }

    @Override
    protected Set<String> getColumnNames()
    {
        return PageFlowUtil.set("Id", "date", "sire", "termCode/description", "confirmDate", "termDate");
    }
}
