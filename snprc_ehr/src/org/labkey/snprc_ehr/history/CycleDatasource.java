package org.labkey.snprc_ehr.history;

import org.labkey.api.data.Container;
import org.labkey.api.data.Results;
import org.labkey.api.ehr.history.AbstractDataSource;
import org.labkey.api.module.Module;

import java.sql.SQLException;

public class CycleDatasource extends AbstractDataSource
{
    public CycleDatasource(Module module)
    {
        super("study", "estrousCyclePivot", "Cycle", "Cycle", module);
        setShowTime(true);
    }

    @Override
    protected String getHtml(Container c, Results rs, boolean redacted) throws SQLException
    {
        StringBuilder sb = new StringBuilder();

        addStringField(rs, sb, "tumescence_index::observations", "Tumescence Index");
        addStringField(rs, sb, "vaginal_bleeding::observations", "Vaginal Bleeding");
        addStringField(rs, sb, "purple_color::observations", "Purple Color");
        addStringField(rs, sb, "carrying_infant::observations", "Carrying Infant");
        addStringField(rs, sb, "male_status::observations", "Male Status");
        addStringField(rs, sb, "male_id::observations", "Male Id");
        addStringField(rs, sb, "cycle_location::observations", "Cycle Location");
        addStringField(rs, sb, "observer_emp_num::observations", "Observer");

        return sb.toString();
    }
}
