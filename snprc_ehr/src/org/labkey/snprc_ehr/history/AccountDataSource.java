package org.labkey.snprc_ehr.history;

import org.labkey.api.data.Container;
import org.labkey.api.data.Results;
import org.labkey.api.ehr.history.AbstractDataSource;
import org.labkey.api.module.Module;
import org.labkey.api.util.PageFlowUtil;

import java.sql.SQLException;
import java.util.Set;

public class AccountDataSource extends AbstractDataSource
{
    public AccountDataSource(Module module)
    {
        super("study", "animalAccounts", "Accounts", "Accounts", module);
    }

    @Override
    protected String getHtml(Container c, Results rs, boolean redacted) throws SQLException
    {
        StringBuilder sb = new StringBuilder();

        addStringField(rs, sb, "account", "Account Id");
        addStringFieldLookup(rs, sb, "description", "account", "Account");
        addDateField(c, rs, sb, "enddate", "End Date");

        return sb.toString();
    }

    @Override
    protected Set<String> getColumnNames()
    {
        return PageFlowUtil.set("Id", "date", "enddate", "account", "account/description");
    }
}
