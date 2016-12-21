package org.labkey.snprc_ehr.history;

import org.labkey.api.data.Container;
import org.labkey.api.data.Results;
import org.labkey.api.ehr.history.AbstractDataSource;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;
import org.labkey.api.util.PageFlowUtil;

import java.sql.SQLException;
import java.util.Set;

/**
 * Created by Marty on 12/19/2016.
 */
public class DefaultBloodDrawDataSource extends AbstractDataSource
{
    public DefaultBloodDrawDataSource(Module module)
    {
        super("study", "Blood Draws", "Blood Draw", "Blood Draws", module);
        setShowTime(true);
    }

    @Override
    protected String getHtml(Container c, Results rs, boolean redacted) throws SQLException
    {
        StringBuilder sb = new StringBuilder();

        addFloatWithUnitsField(rs, sb, "quantity", "Total Quantity", "mL");
        addIntegerField(rs, sb, "project", "Charge Id");
        addStringFieldLookup(rs, sb, "displayName", "project", "Project");
        addResearchField(rs, sb);
        addStringField(rs, sb, "remark", "Remark");

        return sb.toString();
    }

    @Override
    protected Set<String> getColumnNames()
    {
        return PageFlowUtil.set("Id", "date", "quantity", "project", "project/displayName", "project/research", "remark");
    }

    protected void addResearchField(Results rs, StringBuilder sb) throws SQLException
    {
        FieldKey fieldKey = FieldKey.fromParts("project", "research");
        if( rs.hasColumn(fieldKey) && rs.getObject(fieldKey) != null)
        {
            addField(sb, "Research", "", rs.getBoolean(fieldKey)?"true":"false");
        }
        else
        {
            addField(sb, "Research", "", "false");
        }
    }
}
